# OsmAnd external launch contract

Checked **2026-10-02** against map_launcher baseline [`8aa7a6e1152a80c4482003bdfaad8f850bdb6131`](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131), verified after fetching `origin/master`. **No installed-app behavior was tested.**

## Evidence and platform differences

- Current official [intent documentation](https://osmand.net/docs/technical/algorithms/osmand-intents/) supplies examples but not a complete normative parameter specification. In particular, its route example uses `finish`, whereas current source handles `end`; its map examples also omit the usual `#zoom/lat/lon` fragment delimiter. Do not copy those examples without checking the actual handler.
- [Official API overview](https://osmand.net/docs/technical/osmand-api-sdk/) mixes external Intents, bound AIDL and embedded SDK. Only external launch/Intent contracts are included here, not the AIDL method catalog, REST services or embedded rendering APIs.
- **Official-source inference:** Android [344beca, 2026-10-02](https://github.com/osmandapp/OsmAnd/commit/344beca32335ab3c24c104667ba808e7ab64abc1), iOS [f97f648, 2026-10-02](https://github.com/osmandapp/OsmAnd-iOS/commit/f97f6488d37700958924d01ac35bbb1de3f98d99). Source HEAD is not proof that store releases already contain every handler below.

| Platform/product | Identity and launch surfaces | Source |
| --- | --- | --- |
| Android free | `net.osmand`; HTTP(S) `osmand.net/go`, `/map`, `/add-tile-source`, `/open-gpx`; native `osmand.api:`, navigation and file intents | [Flavors][flavors], [manifest][manifest] |
| Android OsmAnd+ | `net.osmand.plus`; same source handlers, distinct target package | [Flavors][flavors]; see [separate audit](osmand-plus.md) |
| iOS | Apple ID `934850257`, scheme `osmandmaps`; also `geo-navigation` and associated domain `osmand.net` | [README](https://github.com/osmandapp/OsmAnd-iOS/blob/f97f6488d37700958924d01ac35bbb1de3f98d99/README.md), [plist][ios-plist], [entitlements](https://github.com/osmandapp/OsmAnd-iOS/blob/f97f6488d37700958924d01ac35bbb1de3f98d99/OsmAnd%20Maps.entitlements) |
| Web | `https://osmand.net/map` is a web resource and native launch target | Web route state is not identical to native parser state. HTTPS does not guarantee an installed app opens; OS associations/user settings determine dispatch. |

Android `/go` has auto-verified filters specifically intended for Google Play Free/Plus; `/map` has browsable filters but is not auto-verified in this manifest. `osmand.api` has VIEW/DEFAULT but **no BROWSABLE category**, so use an explicit Android Intent rather than promising ordinary browser-link launch. Free/paid feature entitlements do not create separate query vocabularies. Plugin-dependent commands still require their plugin enabled.

## Coordinates, encoding and limits

Native point pairs below are **latitude,longitude**, geographic decimal degrees, not projected x/y. GPS/WGS84 interpretation is source-domain inference; these handlers have no caller-selectable datum. URL-encode string values and nested URLs once; commas/semicolons are structural delimiters after decoding. Case and separators matter. No cross-platform URL-length or waypoint-count maximum is specified; OS limits still apply.

iOS `/map` route and pin handlers validate finite latitude −90…90, longitude −180…180. iOS `/go` and `osmandmaps` instead convert absent/malformed numeric strings to zero in the examined paths and do not explicitly range-check. Android handlers parse doubles without local geographic bounds checks. These are implementation quirks, **not recommended accepted inputs**. map_launcher already validates finite geographic bounds in `LocationCoords`. Sources: [iOS parser][ios], [Android parser][intent], [external API][external].

## Native/web map and routing URLs

These tables are **source inference** from [Android IntentHelper][intent], [GeoPointParserUtil][geo], and [iOS DeepLinkParser][ios]. The official [intent page](https://osmand.net/docs/technical/algorithms/osmand-intents/) documents only a subset.

| URL/action | Fields, requiredness, defaults | Effect and platform difference |
| --- | --- | --- |
| `http[s]://osmand.net/go` | Required `lat`, `lon` numeric pair; optional integer `z`; Android generic parser also recognizes `zoom`; optional iOS `title` | **Location/map context, not directions.** Android simple-domain parser does not consume `title`; iOS uses current zoom when `z` omitted. |
| `osmandmaps://` (iOS) | `lat`, `lon` should be supplied; parser defaults each to 0; `z` integer default 0; `title` optional string | Moves map/opens target. Unknown hosts also reach display branch. |
| `osmandmaps://navigate` (iOS) | Same coordinates/title; `z` parsed but unused | Creates destination, sets nonempty title, calls navigate and **startNavigation**. No origin, waypoint or mode parameter in this handler. |
| `https://osmand.net/map?pin=LAT,LON#Z/LAT/LON` | `pin` required pair; optional fragment zoom | Opens a location marker/context. iOS default zoom is current zoom. |
| `https://osmand.net/map#Z/LAT/LON` | Three fragment components | Moves map without separate pin; zoom numeric. Missing/malformed numeric values can become zero on iOS; not a safe input contract. |
| `https://osmand.net/map/navigate?end=LAT,LON` | Required valid `end`; optional `start`, `via`, `profile`, Android `params` | Enters **route planning**, not unconditional active guidance. Recognition keys on map URL plus `end`; `/navigate` is the conventional path. |
| `https://osmand.net/map/poi` | Required `pin`; optional `type`, `name`, `wikidataId`, `osmId`; fragment zoom | Nonempty `type` selects amenity lookup; otherwise `name` selects favorite lookup. `wikidataId` normalized with `Q`; `osmId` integer. Use these canonical spellings for Android; iOS lowercases keys before matching. |
| Android `/go?url=...` | Encoded nested `url` | Validated redirect, not a general unvalidated URL execution guarantee. [Handler](https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/src/net/osmand/plus/helpers/IntentHelper.java#L657-L680) |

| Route field | Syntax/default/limits | Source |
| --- | --- | --- |
| `end` | Destination `lat,lon`, required; malformed/empty aborts | [Android lines 182–230][intent], [iOS lines 388–463][ios] |
| `start` | Origin `lat,lon`, optional; absent leaves current/unspecified start, invalid treated as absent | Same sources |
| `via` | Ordered `lat,lon;lat,lon;...`; Android splits on comma or semicolon | No hard count limit identified. [Android lines 569–588][intent], [iOS route parser][ios] |
| `profile` | Available profile key; Android built-ins: `car`, `bicycle`, `pedestrian`, `truck`, `motorcycle`, `moped`, `public_transport`, `train`, `boat`, `aircraft`, `ski`, `horse`; custom routable profiles may exist | Unknown map-link profile falls through normal/default handling, unlike strict `osmand.api` profile check. iOS logs unknown and passes nil. [ApplicationMode](https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/src/net/osmand/plus/settings/backend/ApplicationMode.java#L55-L103) |
| `params` | Android comma-separated entries `key`, `key:value`, `key=value`; bare key means true; generated form begins with profile key | Routing-profile-specific keys, not a fixed portable enum. iOS application is TODO/disabled at audited revision. [Android lines 1073–1140][intent], [iOS route parser][ios] |

Do not translate app travel mode `walking` literally to `profile=walking`: ordinary routing profile is `pedestrian`; the distinct iOS `/app` UI links below use `walking`.

## Android external Intent API: all dispatched actions

`ACTION_VIEW`, data `osmand.api://ACTION?FIELDS`, target `net.osmand` (or `net.osmand.plus`). Action host lowercased. Tables below derive from [ExternalApiHelper lines 201–635][external]; they are implementation-derived, not a stable versioned prose specification. All named coordinates are decimal doubles; strings have no published maximum. Destination/center pairs should be complete. `force` and `location_permission` are boolean query values, default false, **not presence-only flags**.

| Action | Inputs (R = required/effectively required) | Defaults/effect |
| --- | --- | --- |
| `show_gpx` | One GPX source R: query `path`, Intent string extra `data`, or query `uri=true` plus first `ClipData` URI | Precedence path → data → URI. `uri=false` default. Displays GPX. Grant read access for content URI. |
| `navigate_gpx` | Same GPX source; optional `force`, `location_permission` | Saves/imports and navigates; booleans false. |
| `navigate` | `dest_lat`, `dest_lon` expected destination pair; optional `dest_name`, `start_lat`, `start_lon`, `start_name`; valid routable `profile` R; optional `force`, `location_permission` | Names default empty. Start pair optional. `default`/unknown/unavailable profile rejected. Null destination can reach downstream helper; do not rely on that loophole. Can ask before replacing existing navigation. |
| `navigate_search` | Nonempty `dest_search_query` R; `search_lat`, `search_lon` R; valid `profile` R; optional `show_search_results`, `start_lat`, `start_lon`, `start_name`, `force`, `location_permission` | Booleans false, name empty; show results or navigate to first result. |
| `pause_navigation` | None | Pauses calculated active navigation. |
| `resume_navigation` | None | Resumes calculated route. |
| `stop_navigation` | None | Stops following/paused navigation. |
| `mute_navigation`, `unmute_navigation` | None | Changes voice state. |
| `record_audio`, `record_video`, `record_photo` | `lat`, `lon` R | Active A/V notes plugin required. |
| `stop_av_rec` | None | Stops/saves recording. |
| `get_info` | None | Returns map/location/navigation information as Intent extras, not a web callback. |
| `add_favorite` | `lat`, `lon` R; optional `name`, `desc`, `category`, `color`, `visible` | Strings empty; `visible=true`; absent/unrecognized color falls back to 0. Adds and opens favorite. |
| `add_map_marker` | `lat`, `lon` R; optional `name` | Name empty; adds and opens marker. |
| `show_location` | `lat`, `lon` R | Opens map context at zoom 15. |
| `start_gpx_rec`, `stop_gpx_rec`, `save_gpx`, `clear_gpx` | Optional `close_after_command` | Default true; trip-recording plugin required. Clear mutates recorded data. |
| `execute_quick_action` | `quick_action_number` R; optional `close_after_command` | Zero-based integer in flattened action list, close defaults true. No fixed maximum independent of configured actions. |
| `get_quick_action_info` | Same | Returns action name/type/JSON params/version. |
| `subscribe_voice_notifications` | None | Recognized but **not implemented** (1002); not an available subscription feature. |

Favorite `color` strings: `darkyellow`, `red`, `orange`, `yellow`, `lightgreen`, `green`, `lightblue`, `blue`, `purple`, `pink`, `brown`, `black`. [DefaultColors](https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/src/net/osmand/plus/card/color/palette/solid/data/DefaultColors.java#L14-L42). Source permits active custom routable profile keys; do not advertise every built-in profile as universally installed/available.

### Results and callbacks

Activity result codes: −1 success, 0 canceled/default; 1001 exception/unknown error, 1002 not implemented, 1003 required plugin inactive, 1004 GPX unreadable/not found, 1005 invalid navigation profile, 1006 empty search query, 1007 undefined search location, 1008 quick action not found. Source [constants and result writers][external], [Intent handoff lines 765–773][intent]. No URL `x-success`, `x-error` or completion callback parameter was found.

| Result | Fields/type/condition |
| --- | --- |
| `get_info` position | `lat`, `lon` doubles when last location exists; `map_lat`, `map_lon` doubles (also guarded by last-location presence in this implementation) |
| Route | `destination_lat`, `destination_lon` when calculated; `eta` epoch seconds, `time_left` seconds, `time_distance_left` remaining distance (literal unusual name), `routing_data` string list, `version` integer 1 |
| Turns | Prefixes `current_`, `next_`, **`after_next`** (no trailing underscore), `no_speak_next_`; suffixes `turn_distance` integer, `turn_imminent` integer, `turn_name` string, `turn_type` XML turn string, `turn_lanes` stringified integer array, `turn_angle` float, `turn_possibly_left`/`turn_possibly_right` booleans |
| Quick action info | `quick_action_name`, `quick_action_type`, `quick_action_params` JSON string, `version` |

Exact source: [ExternalApiHelper lines 149–183, 431–466, 647–706][external]. Optional information depends on current GPS/route state; lack of extras is not necessarily an error.

## Other external actions and file imports

| Entry point | Fields and behavior | Source/limitations |
| --- | --- | --- |
| `/add-tile-source` (Android/iOS) | Query passed into map-source editor; `name`, `url_template`, `min_zoom`, `max_zoom` identified | Not a route or tile REST API. Full renderer/template attribute grammar is not an app-launch field guarantee; editor validates. [Android lines 683–707][intent], [iOS lines 562–570][ios] |
| `/open-gpx` (Android) | Required `url`, optional `name`; sanitized basename, `.gpx` appended if needed | Downloads into GPX import directory; not immediate route navigation. No iOS handler at audited source revision. [Android lines 712–742][intent] |
| `/premium?token=...` (Android), `/premium/device-registration?token=...` (iOS) | Cloud/device authorization token | Auth workflow, not map launch; sensitive token must not be logged. [Android lines 263–293][intent], [iOS lines 572–598][ios] |
| Android `geo:LAT,LON[?z=ZOOM]`, `geo:0,0?q=QUERY` | Geographic location or text/address/business query | [Official documented examples](https://osmand.net/docs/technical/algorithms/osmand-intents/); generic parser supports labels and many provider URLs. |
| Android `google.navigation:q=LAT,LON`, `osmand.navigation:q=LAT,LON` | Numeric destination after `q=` or `ll=` in scheme-specific part; regex permits trailing text | Sets destination and enters route planning; this handler does not parse an address, mode or origin from trailing text. Not the `osmand.api` vocabulary. [Manifest][manifest], [IntentHelper parseNavigationIntent lines 911–935][intent] |
| Android `geo.action:`, `geo.action.offline:` | Registered external geo-action schemes | Registration alone is not a complete field specification. Not used by wrapper. [Manifest lines 546–580][manifest] |
| iOS `geo-navigation` path containing `directions` | `source`, `destination`, repeated ordered `waypoint`; each coordinate pair or geocoded address | Car profile; unresolved destination discards waypoints. No separate transport-mode field. [GeoNavigationParser][geo-ios], [iOS lines 131–159][ios] |
| iOS `geo-navigation` path containing `place` | `coordinate`, fallback `address` | Coordinate pair or geocoded address; validates geographic bounds. [GeoNavigationParser][geo-ios] |
| Android file VIEW | GPX/ZIP, KML, KMZ, OBF/ZIP, SQLite/SQLITEDB, OSF/ZIP, XML, WPT/3D chart | Scheme/MIME filters vary: generally file/content, some data. Exact filters in [manifest lines 190–445][manifest]; do not assume every MIME/scheme combination works. |
| Android SEND | `Intent.EXTRA_STREAM`; `application/gpx+xml` supports SEND_MULTIPLE; binary/application octet-stream content import | Needs readable content URI. Structured `osmand.api` callbacks do not apply to ordinary import. [IntentHelper lines 760–793][intent] |
| iOS file URL | GPX, KML, KMZ, OsmAnd XML, OSF, SQLITEDB, OBF, chart UTIs | Incoming-file handler; no Android-style return Intent. [Plist][ios-plist], [iOS lines 359–362][ios] |

The official intent page additionally documents accepted Google map query/path forms (`q`, `saddr`, `daddr`, `@lat,lon,zoom`), OpenStreetMap `search?query=...`, `#zoom/lat/lon` and shortlinks, Yandex `ll`/`z`, Baidu `c`/`l`, Amap fragment links, HERE location links, QQ location links, Apple `daddr`/`ll`, and `ge0.me`. These are **input compatibility parsers**, not REST APIs or identical coordinate-order contracts: e.g. provider-specific `ll` and projected coordinates must not be replaced with OsmAnd's lat/lon assumptions. Exact parser/tests are linked from that [official page](https://osmand.net/docs/technical/algorithms/osmand-intents/). An exhaustive third-party-provider grammar is not established by its “many other similar” examples.

### iOS app-screen links

Official source [DeepLinkParser enum and dispatcher][ios] supports `https://osmand.net/app/` plus these paths, with no action-specific query field shown in the route enum:

`help/last-release-notes`, `help/whats-new`, `settings`, `cloud`, `help`, `plan-a-route`, `plugins`, `plugins/trip-recording`, `plugins/topography`, `plugins/weather`, `plugins/external-sensors`, `plugins/vehicle-metrics`, `configure-screen/widgets/left`, `configure-screen/widgets/right`, `configure-screen/widgets/top`, `configure-screen/widgets/bottom`, `map-settings`, `map-settings/map-type`, `map-settings/wikipedia`, `map-settings/overlay`, `map-settings/underlay`, `destinations`, `destinations/direction-appearance`, `my-places/favorites`, `my-places/tracks`, `my-places/osm-edits`, `maps-and-resources`, `maps-and-resources/local`, `maps-and-resources/updates`, `purchases`, `purchases/osmand-pro`, `purchases/maps-plus`, `quick-actions/lock-screen/add`, `settings/profile-settings/configure-screen/speedometer/car`, `trip-recording/external-sensors`.

Profile-suffixed paths: `settings/profile-settings/trip-recording/{profile}`, `settings/profile-settings/configure-screen/distance-by-tap/{profile}`, `navigation-screen/{profile}`. UI-profile keys: `browse`, `car`, `bicycle`, `walking`; `navigation-screen` excludes `browse`. These open screens, not portable route APIs. No assumption is made that iOS-only paths also work on Android.

## Comparison with map_launcher

Sources: [`osmand.dart`](../../lib/src/maps/osmand.dart), [`map_app.dart`](../../lib/src/maps/map_app.dart), [`url_builder.dart`](../../lib/src/utils/url_builder.dart), [Android queries](../../android/src/main/AndroidManifest.xml), [iOS example plist](../../example/ios/Runner/Info.plist).

| Existing behavior | Classification and evidence |
| --- | --- |
| Android marker `/go?lat=...&lon=...[&z=...]` | Matches location parser. Android title is omitted; current simple parser does not consume a title anyway. |
| Android directions uses exactly `/go?lat=...&lon=...` | **Concrete semantic mismatch:** one point opens location context; it does not construct route. Both Free and Plus inherit this. |
| iOS marker `osmandmaps://?lat=...&lon=...&z=...&title=...` | Matches custom display handler; omitted zoom falls to source's 0, not the `/go` current-zoom fallback. |
| iOS directions `osmandmaps://navigate?...` | Valid source contract, but starts guidance, not merely planning. Origin, waypoints and requested mode are ignored. |
| All travel modes reported supported | Overstates ability to honor requested mode: neither branch serializes it. Current iOS custom handler has no such field; alternate map route link does. |
| `supportsWaypoints=false`, search flags false | Honest wrapper limitation, omitted app capabilities (map `via`, geo/search API). |
| `hasUniversalLink=false`, URL methods null | Omitted web/native HTTP(S) surface, not lack of app-link support. Choosing a web fallback still needs browser verification. |
| Android `net.osmand`, iOS `934850257`, detection `osmandmaps://` | Match current official source. |

## Proposed tests and remaining uncertainty

1. Android: distinguish `/go?lat=59.3293&lon=18.0686` from `/map/navigate?start=58.4108,15.6214&end=59.3293,18.0686&via=59.2,17.5&profile=pedestrian`. Assert location context versus route planning, not just successful Intent dispatch.
2. iOS: compare `osmandmaps://navigate` with `/map/navigate`; verify immediate navigation versus route planning and current-location permission behavior.
3. Exercise `car`, `pedestrian`, `bicycle`, `public_transport`, unknown/default profile, no origin, two asymmetric waypoints, and offline routing data missing.
4. Query title/search `A&B + café/港`; literal plus must survive decoding; nested GPX URL must not leak `&` into outer query. Missing coordinate, malformed numeric, 0,0, −33.8688/151.2093 and geographic boundaries expose defaults/order mistakes.
5. Test free/Plus installed separately and together with explicit package targeting; Android verified/unverified links and iOS canOpenURL are not proof of routing behavior.
6. API result tests: plugin disabled (1003), nonexistent GPX (1004), bad profile (1005), empty query (1006), missing search location (1007), out-of-range quick action (1008). Verify returned fields, not just app opening.

Source-only conclusions are pinned to the revisions above. Documentation is incomplete and partially inconsistent with source; store-release parity, Android chooser/browser behavior, geographic normalization downstream, and paid feature gates remain unverified. No code changes or native test execution were part of this audit.

[flavors]: https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/build.gradle#L117-L149
[manifest]: https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/AndroidManifest.xml
[intent]: https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/src/net/osmand/plus/helpers/IntentHelper.java
[external]: https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/src/net/osmand/plus/helpers/ExternalApiHelper.java
[geo]: https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd-java/src/main/java/net/osmand/util/GeoPointParserUtil.java
[ios]: https://github.com/osmandapp/OsmAnd-iOS/blob/f97f6488d37700958924d01ac35bbb1de3f98d99/Sources/Helpers/DeepLinkManager/DeepLinkParser.swift
[geo-ios]: https://github.com/osmandapp/OsmAnd-iOS/blob/f97f6488d37700958924d01ac35bbb1de3f98d99/Sources/Helpers/DeepLinkManager/GeoNavigationParser.swift
[ios-plist]: https://github.com/osmandapp/OsmAnd-iOS/blob/f97f6488d37700958924d01ac35bbb1de3f98d99/Resources/OsmAnd-Info.plist
