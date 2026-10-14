# Organic Maps

Checked: **2026-10-02**. Native-device behavior has not been verified.

## Plugin status and identity

**Organic Maps is not implemented in map_launcher.** Support is requested in [issue 111](https://github.com/mattermoran/map_launcher/issues/111). The formats below describe provider interfaces, not plugin capabilities.

Organic Maps is an active offline map/navigation product, not another spelling of MAPS.ME. Official identities: [Android `app.organicmaps`](https://play.google.com/store/apps/details?id=app.organicmaps), [Apple ID `1567437057`](https://apps.apple.com/app/id1567437057), primary native scheme `om`. The [Android API](https://github.com/organicmaps/api-android/blob/f813cc11ee7262a1b33f64aade4443843c83c9ea/README.md) additionally recognizes `.beta`, `.debug`, and `.web` package variants; they must not be mistaken for the production Play app. [iOS API store fallback](https://github.com/organicmaps/api-ios/blob/045dbce7756dfc116be3469f939eda5455b151fe/api/OrganicMapsAPI.swift) confirms the Apple identity.

`om://map` supports pins and legacy `om://route` supports explicit two-point directions in the pinned source. The legacy API has no destination-only/current-location route or waypoint contract. The advertised v2 API conflicts with the inspected app parser, as detailed below.

## Sources and versions

- Official [API/test page](https://omaps.app/api), undated, checked on the date above.
- App source pinned at [b90c786](https://github.com/organicmaps/organicmaps/tree/b90c786f839d930dcf16590acd9f97201cc988b4); GitHub reports committer date 2026-10-02.
- Android release snapshot: [2026.09.29-32-android](https://github.com/organicmaps/organicmaps/releases/tag/2026.09.29-32-android), published 2026-09-29, commit [b20d141](https://github.com/organicmaps/organicmaps/commit/b20d1417eef1e3c63a447ac8658db4307a066024). Store rollout/version may differ; no iOS release parity inferred.
- Official external-app helper repositories: [Android f813cc1](https://github.com/organicmaps/api-android/tree/f813cc11ee7262a1b33f64aade4443843c83c9ea), [iOS 045dbce](https://github.com/organicmaps/api-ios/tree/045dbce7756dfc116be3469f939eda5455b151fe), both 2026-05-17. Their code is a launch wrapper, not an embedded map SDK or REST service. Android README says basic API supported since 2022-07-26; this is not a claim every newer parameter existed then.

## Coordinate and encoding conventions

All native API coordinate pairs below are **latitude,longitude**, decimal geographical degrees, not projected meters or longitude-first GeoJSON. [Parser validation](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/libs/map/mwm_url.cpp#L76-L96) uses valid latitude −90…90 and longitude −180…180 before Mercator conversion. Use WGS84 GPS coordinates. No public precision or URL byte limit is specified. Percent-encode each query value once; preserve ordered/repeated keys rather than building a dictionary that drops duplicate `ll`. Encode literal `+` as `%2B`, ampersands and Unicode labels, and nested callback URLs. A successfully parsed point at a polar extreme is not a guarantee of useful map/routing coverage.

## Pin/map API

`om://map?...` and `https://omaps.app/map?...` are shown on the [official test page](https://omaps.app/api). Detailed semantics below are **source-derived** from [map/common parser](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/libs/map/mwm_url.cpp#L270-L423) and [iOS v1 documentation](https://github.com/organicmaps/api-ios/blob/045dbce7756dfc116be3469f939eda5455b151fe/README.md#L219-L249).

| Parameter | Requiredness, type, defaults and rules |
| --- | --- |
| `ll` | At least one valid comma-separated decimal pair required. Repeat for multiple pins; no explicit maximum. Invalid point values are skipped; if none survive, URL is invalid. |
| `n` | Optional name string for preceding `ll`, empty default. Before any valid point, invalidates request. |
| `id` | Optional opaque identifier or encoded URL for preceding `ll`, empty default. Before any point, invalidates request. Returned in pin callback; a URL can be opened by “More Info”. Not a required provider place ID. |
| `s` | Optional style string for preceding point; absent means unspecified style. Parser accepts arbitrary strings; misplaced `s` is ignored rather than invalidating. No closed style enum is imposed by this parser; rendered fallback must be checked against the client/style resources. |
| `z` | Optional double zoom; parser storage default `0.0` (unspecified). Viewport zoom applies to a single pin, not a multi-pin extent. No parser-enforced range; do not confuse with clear-coordinate link's 1…20 range below. |
| `v` | Optional integer; helpers send `1`. Parse failure stores `0`; parser does not enforce a fixed allowed version. Not a switch enabling v2 routes. |
| `appname` | Optional display-title string; empty default. |
| `backurl` | Optional callback base URL/scheme. Parser appends `://` if that substring is absent. No authenticated return channel implied. |
| `balloonaction` | Optional presence flag; **any value**, including empty or `0`, enables opening/return action on balloon click. Omitted defaults false. |
| `cll` | Optional common center pair. Parsed but do not assume it overrides a pin-derived viewport on every client. |

The [Android helper's style enum](https://github.com/organicmaps/api-android/blob/f813cc11ee7262a1b33f64aade4443843c83c9ea/lib/src/main/java/app/organicmaps/api/Point.java) emits `placemark-red`, `placemark-blue`, `placemark-purple`, `placemark-yellow`, `placemark-pink`, `placemark-brown`, `placemark-green`, `placemark-orange`. It describes null style as the default violet circle. This helper enum is narrower than the parser's arbitrary string acceptance and does not establish a complete renderer style set.

Single-pin example (no callback):

```text
om://map?v=1&ll=59.3293,18.0686&n=Stockholm
```

## Legacy directions API is ordered and requires both endpoints

Source: [route dispatch/required pattern](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/libs/map/mwm_url.cpp#L142-L157), [parameter parser](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/libs/map/mwm_url.cpp#L353-L395), [public route examples](https://omaps.app/api).

```text
om://route?sll=59.3293,18.0686&saddr=Start&dll=59.3421,18.0520&daddr=End&type=pedestrian
```

| Parameter, in required relative order | Contract |
| --- | --- |
| `sll` | Required valid start coordinate pair. No current-location sentinel or omitted-origin default. |
| `saddr` | Required key, string start name; empty value accepted by parser. |
| `dll` | Required valid destination pair. |
| `daddr` | Required key, string destination name; empty value accepted by parser. |
| `type` | Required string, case-insensitive: `vehicle`, `pedestrian`, `bicycle`, `transit`. No default. |

Exactly two route points must result. Unexpected/out-of-order keys are ignored while parser waits for the next required key; they do not satisfy the missing field. Thus `sll,dll,saddr,daddr,type` fails despite containing all names. Extra unrelated keys such as `v` need not be adjacent, but the five required keys must be consumed in order. No waypoints, avoidances, route geometry, start-navigation flag, or route completion callback in this legacy contract. HTTPS equivalent uses `https://omaps.app/route`.

## Documented v2 contract is not implemented in inspected app source

The [API/test page](https://omaps.app/api) and [iOS README](https://github.com/organicmaps/api-ios/blob/045dbce7756dfc116be3469f939eda5455b151fe/README.md#L241-L249) advertise `om://v2/dir` (preview) and `om://v2/nav` (start navigation when ready). Examples also use `https://omaps.app/v2/dir`.

| Advertised parameter | Evidence and unresolved details |
| --- | --- |
| `origin` | Coordinate pair or literal `currentLocation`; README says explicit-coordinate origin previews first for confirmation. Formal requiredness/default unspecified. |
| `destination` | Coordinate pair. Examples supply it; formal requiredness/error behavior unspecified. |
| `origin_name`, `destination_name` | Display strings in examples, optionality/limits not formally specified. |
| `waypoints` | Pipe-separated coordinate pairs in examples; order meaningful. No maximum documented. |
| `waypoint_names` | Pipe-separated display names; no escaping rule for an embedded pipe or list-count mismatch defined. |
| `waypoint_callbacks` | Pipe-separated encoded URLs, advertised on test page. Callback timing, authentication, results, requiredness and mismatch handling not defined. |
| `callback` | Encoded final callback URL in test-page example; no verified completion semantics. |
| `mode` | Example establishes `drive`; no complete accepted-value set, default, or current binary validation documented. Do not import v1's `vehicle`/`pedestrian` names. |

**Contradictory primary evidence:** both [current app dispatcher](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/libs/map/mwm_url.cpp#L128-L239) and [2026.09.29 release dispatcher](https://github.com/organicmaps/organicmaps/blob/b20d1417eef1e3c63a447ac8658db4307a066024/libs/map/mwm_url.cpp#L128-L239) recognize `map`, `route`, `search`, `crosshair`, `menu`, `settings`, `oauth2`, then encoded/clear-coordinate links. Neither recognizes `v2`; `/dir` and `/nav` are not route actions there. [iOS route adapter](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/iphone/Maps/Core/DeepLink/Strategies/DeepLinkRouteStrategyAdapter.mm) still consumes two points. Therefore these examples are **not integration-ready for the inspected native pipeline**. No device failure is claimed; vendor clarification or a later implemented release is needed before advertising v2.

An independent inbound-path check found no earlier v2 translator in either inspected revision. Android's [URL processor](https://github.com/organicmaps/organicmaps/blob/b20d1417eef1e3c63a447ac8658db4307a066024/android/app/src/main/java/app/organicmaps/intent/Factory.java#L66-L97) sends the intent URL directly to the native parser. iOS [universal-link handling and dispatch](https://github.com/organicmaps/organicmaps/blob/b20d1417eef1e3c63a447ac8658db4307a066024/iphone/Maps/Core/DeepLink/DeepLinkHandler.swift#L111-L148) only substitutes the website prefix; its [parser bridge](https://github.com/organicmaps/organicmaps/blob/b20d1417eef1e3c63a447ac8658db4307a066024/iphone/CoreApi/CoreApi/DeepLink/DeepLinkParser.mm#L23-L29) forwards the resulting URL before any route adapter runs. A browser-loaded HTTPS page could separately translate URLs through website logic; that behavior was not inspected or ruled out. Store binaries may differ from these source revisions.

## Other native actions

Source: [dispatcher](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/libs/map/mwm_url.cpp#L158-L197), [search/common/highlight parameters](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/libs/map/mwm_url.cpp#L397-L440), [Android execution](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/android/app/src/main/java/app/organicmaps/intent/Factory.java), [iOS execution](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/iphone/Maps/Core/DeepLink/DeepLinkHandler.swift).

| Action | Parameters and platform differences |
| --- | --- |
| `om://search` | Required nonempty `query` string; optional `locale` string (empty default, no parser enum), `cll=lat,lon`, `appname`. Optional `map` presence flag (value ignored) enables map search. Without `cll`, no requested center; clients use zoom 16 when centering. No result count or query-length limit specified. |
| `om://crosshair` | Optional `cll=lat,lon`, `appname`; Android point picker, with result intent described below. iOS handler explicitly returns false: parsed does not mean implemented. |
| `om://menu`, `om://settings` | No required parameters. Optional `highlight=track-recorder` or `icloud`; invalid/absent means no recognized highlight. Implemented iOS navigation; Android handling is TODO/unhandled. |
| `om://oauth2/osm/callback` | Exact callback path and nonempty `code` required. OSM sign-in return flow, **not** a general map-launcher callback or route option. Do not synthesize authorization codes. |

## Shared point links, aliases and foreign formats

Source: [shared parser](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/libs/map/mwm_url.cpp), [geo-prefix/parser source](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/libs/ge0/parser.hpp), [test page](https://omaps.app/api), [zoom constant](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/libs/indexer/scales.hpp).

| Format | Fields / limits |
| --- | --- |
| `om://ENCODED[/NAME]`, `https://omaps.app/ENCODED[/NAME]` | ge0 encoded zoom/coordinate payload, optional name; e.g. documented `o4B4pYZsRs`. Use official encoder rather than treating payload as a place ID. Exact binary codec is a separate format, not ordinary query coordinates. |
| `https://omaps.app/LAT,LON[/NAME]?z=ZOOM` | Source accepts decimal latitude-first point, optional path name, optional **integer** zoom 1…20; absent/malformed/out-of-range zoom defaults 14. Fragment does not supply zoom here. |
| `geo:LAT,LON[?z=ZOOM]`, `geo:LAT,LON(LABEL)` | Common geographical point forms. Label/zoom optional. Native `om://map` has less ambiguity for targeting Organic Maps. |
| `geo:0,0?q=LAT,LON(LABEL)`, `geo:LAT,LON?q=TEXT` | Coordinate query or text search variants documented by test page. Encode literal plus in Plus Codes as `%2B`. Coordinate query is not necessarily a text search. Foreign parser determines interpretation. |
| `ge0://...`, `http(s)://ge0.me/...`, legacy `mapsme://`, `mapswithme://`, `mwm://` | Parser compatibility aliases, not proof that every OS registers every alias or uniquely selects Organic Maps. Avoid for new integration. |
| Google/OSM/2GIS web URLs | Test page demonstrates Google `q`, `z`, `/place/.../@lat,lon,zoom`; OSM `#map=zoom/lat/lon`, search `query`, bounds and zoom; 2GIS `center=lon,lat`, `zoom`, or `m=lon,lat/zoom`. These are foreign URL-import compatibility, not the recommended external Organic Maps contract. No completeness, limits, or app-link association promise inferred for those providers. Note **2GIS longitude-first** exception. |

Additional source-derived shared-link limits from [ge0 parser](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/libs/ge0/parser.cpp) and [header](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/libs/ge0/parser.hpp): the encoded payload is ten characters (one zoom plus nine interleaved coordinate characters), using `A–Z`, `a–z`, `0–9`, `-`, `_`. Zoom decodes to 4…19.75 in quarter-level steps. Shared-link names are truncated to at most 256 encoded bytes before decoding; malformed percent sequences truncate the name, and spaces/underscores are swapped after decoding. Clear-coordinate paths require digits **on both sides of a decimal point in each coordinate**, optionally prefixed with minus; plain integers, leading plus, `.5`, and scientific notation do not match this path grammar. These restrictions do not apply wholesale to `om://map` query fields. Use the official [URL generator](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/libs/ge0/url_generator.hpp) when generating compact links rather than reproducing the interleaving codec.

Android [manifest](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/android/app/src/main/AndroidManifest.xml#L95-L179) registers `ACTION_VIEW` for `om`, `geo`, `geo.offline`, `ge0`, `geo.action`, `geo.action.offline`, `mapsme`, selected OSM and ge0.me links, and verified omaps.app links. It registers `android.intent.action.NAVIGATE` for geo/geo.offline, including voice category. These declarations alone do not prove a specific navigation-mode parameter. iOS [plist](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/iphone/Maps/OMaps.plist) lists `om`, `ge0`, `geo`, `geo-navigation`, `mapswithme`, `mapsme`, `mapswithmepro`. Shared-parser support and OS URL dispatch are different layers.

## Android activity results and iOS pin callbacks

These are **external app integrations**, despite repository names containing “API”; no HTTP service, API key, OAuth token, or partner entitlement is needed for ordinary pins/routes. [Android request/result constants](https://github.com/organicmaps/api-android/blob/f813cc11ee7262a1b33f64aade4443843c83c9ea/lib/src/main/java/app/organicmaps/api/Const.java), [MapRequest](https://github.com/organicmaps/api-android/blob/f813cc11ee7262a1b33f64aade4443843c83c9ea/lib/src/main/java/app/organicmaps/api/MapRequest.java), [iOS callback documentation](https://github.com/organicmaps/api-ios/blob/045dbce7756dfc116be3469f939eda5455b151fe/README.md):

| Action/extra | Type and semantics |
| --- | --- |
| Android `Intent.ACTION_VIEW`, data `om://map` or `om://crosshair` | Standard URL launch. To receive selection, use activity-result machinery rather than fire-and-forget URL launch. |
| `app.organicmaps.api.extra.PICK_POINT` | Optional request boolean; true asks for a picked-point result. Crosshair helper sets it. |
| Result `POINT_LAT`, `POINT_LON`, `ZOOM_LEVEL` | Double extras under prefix `app.organicmaps.api.extra.`; inspect only on successful `RESULT_OK` with data. |
| Result `POINT_NAME`, `POINT_ID` | String extras under same prefix. Point identifier correlates request pin; do not execute returned content blindly. |
| iOS `YourScheme://pin?ll=LAT,LON&n=NAME&id=ID` | Return URL, generated from `backurl`; coordinates/name/id identify selected pin. Not a route completion callback. Register the caller scheme and validate inbound data. |

iOS helper uses the caller's first registered `CFBundleURLSchemes` entry as its callback identity; add `om` to query schemes when using `canOpenURL`. Android package visibility needs appropriate host queries. The Android helper's fallback download dialog points to `https://omaps.app/get?api`; bare `api` is helper attribution, not a route parameter. Native scheme launch by itself has no store fallback. HTTPS link interpretation and fallback should be tested per OS/browser; a browser resolving omaps.app does not prove an installed application.

## File opening/import is a separate, mutating contract

There is **no `om://import` action** in the inspected dispatcher. Android [manifest/import processing](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/android/app/src/main/AndroidManifest.xml#L181-L241) declares `VIEW`, `SEND`, `SEND_MULTIPLE` for KML/KMZ/GPX/GeoJSON/JSON, with URI schemes depending on the filter (`http`, `https`, `content`, `file`, `data`). MIME types include `application/vnd.google-earth.kml+xml`, `application/vnd.google-earth.kmz`, `application/vnd.google-earth.kmz+xml`, `application/gpx`, `application/gpx+xml`, `application/geo+json`, `application/vnd.geo+json`, `application/json`; extension fallback also exists. Sharing uses `Intent.EXTRA_STREAM` or its list. Grant content-URI read permission; no arbitrary filesystem access assumed.

iOS [document declarations](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/iphone/Maps/OMaps.plist) include `com.topografix.gpx`, `com.google.earth.kml`, `com.google.earth.kmz`, `public.geojson`, `public.json`; [handler](https://github.com/organicmaps/organicmaps/blob/b90c786f839d930dcf16590acd9f97201cc988b4/iphone/Maps/Core/DeepLink/DeepLinkHandler.swift) imports while security-scoped access remains valid. File payload schemas/coordinate orders belong to their standards (GeoJSON is longitude-first), not the latitude-first URL API. No import size or route-point cap is established here. Import creates user data and is not a substitute for a transient marker.

## Integration limits and privacy

Do not silently obtain caller GPS to fill the legacy required origin, pretend `0,0` means current location, or drop waypoints. Expose lack of capability explicitly. Offline map download/coverage and GPS permissions remain app concerns. Native-only launch can avoid a web-service request, but HTTPS fallback can reveal coordinates to the website; pin URLs and callback IDs can carry sensitive data. Avoid untrusted callback destinations, secrets in IDs, and logging precise coordinates.
