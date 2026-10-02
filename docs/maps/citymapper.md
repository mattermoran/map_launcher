# Citymapper external launch contract

Checked **2026-10-02**. Existing integration. Repository baseline: fetched `origin/master` and verified that it and `HEAD` resolve to [8aa7a6e1152a80c4482003bdfaad8f850bdb6131](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131). Research only; all native-app behavior below is **runtime-unverified**.

## Sources and evidence limits

| Source | Status / date / evidentiary scope |
| --- | --- |
| [Launch Citymapper for Directions](https://citymapper.com/news/2386/launch-citymapper-for-directions) | Primary, retrieved in full; no publication date or protocol version displayed. Documents HTTPS and native directions, six fields. |
| [Former tools URL](https://citymapper.com/tools/1053/launch-citymapper-for-directions) | Inaccessible: HTTP 404. The shorter `/tools/1053/` returns “Not Found”; `/news/1053/launch-citymapper-for-directions` returned HTTP 500. Do not silently attribute historical options to the current article. |
| [SDKs and APIs come to an end](https://citymapper.com/news/2596/sdks-and-apis-come-to-an-end) | Primary. `/powers` redirects through `/enterprise` to this notice. Self-service SDK/API shutdown effective **2023-06-23**; existing enterprise contracts excepted. |
| [2019 arriveby report](https://stackoverflow.com/questions/57251461/citymapper-url-ignoring-arriveby-parameter) | Secondary-only, question 2019-07-29, answer edited 2019-07-31; historical web behavior, not a current app contract. |

“Not documented” here means absent from the accessible launch reference, not proof that an app version rejects the option. Numeric limits, supported locales and app-version compatibility must not be invented from examples.

## Public launch actions and complete documented fields

Source for both forms and every row: [official directions guide](https://citymapper.com/news/2386/launch-citymapper-for-directions).

| Action | Form | Semantics / platform |
| --- | --- | --- |
| Plan directions | `https://citymapper.com/directions?endcoord=<lat>,<lon>` | Cross-platform link; article says it launches the app and “works for all platforms.” Exact installed/uninstalled browser fallback and OS association behavior need tests. |
| Plan directions in native app | `citymapper://directions?endcoord=<lat>,<lon>` | Same fields as HTTPS. Article recommends this for older iOS and to force native app opening. No Android-specific intent extras or explicit `intent://` syntax published. |

| Field | Required / type | Values, defaults, constraints |
| --- | --- | --- |
| `endcoord` | **Required**, comma-delimited latitude,longitude | Decimal latitude then longitude; percent-encoded comma `%2C` shown. The only absolutely necessary field. Destination cannot be supplied solely by its name/address. |
| `endname` | Optional string | Business name or nickname; display label, not a place ID or geocoding input. No default label or length limit specified. |
| `endaddress` | Optional string | Street address shown at trip end to help find the door; does not replace coordinates. No length limit specified. |
| `startcoord` | Optional coordinate pair, same syntax | Explicit origin; omitted origin uses current location. Location-permission failure behavior unspecified. |
| `startname` | Optional string | Origin label, analogous to `endname`; independent label-only origin behavior unspecified. |
| `startaddress` | Optional string | Origin street-address label, analogous to `endaddress`. |

Coordinates look like ordinary geographic decimal degrees; **WGS84 is inferred**, not named in the guide. It gives no numeric bounds or precision limit. The library separately enforces finite latitude −90…90 and longitude −180…180 in `LocationCoords`; those are library constraints, not vendor-documented limits.

Encode each query value once as UTF-8 URI data. The reference explicitly encodes spaces as `%20` and commas as `%2C`. Keep structural `?`, `&`, and `=` outside values. A literal `&`, `+`, `#`, `%`, or non-ASCII character in a name must not become query syntax. Whether the native app accepts form-style `+` for spaces is runtime-unverified.

Example derived from the documented contract, not an executed launch:

```text
https://citymapper.com/directions?startcoord=51.50685%2C-0.142927&startname=Green%20Park&endcoord=51.532499%2C-0.10579&endname=Angel
```

### Fields that must not be promoted to current public support

| Category | Finding and source |
| --- | --- |
| Date/time | `arriveby` appears in the [2019 secondary report](https://stackoverflow.com/questions/57251461/citymapper-url-ignoring-arriveby-parameter) with ISO-8601 offset example `2019-08-06T21:00+01:00`. A respondent describes day/result failures and speculates about six days. Neither support nor a six-day maximum is established. Current primary article does not list `arriveby` or departure-time fields. |
| Modes / preferences | No launch field for walking, cycling, public transport, wheelchair access, avoiding modes, speed, or route alternatives in the [primary guide](https://citymapper.com/news/2386/launch-citymapper-for-directions). In-app mode choices are not an external API. |
| IDs / stops / multiple points | No place ID, station ID, route ID, intermediate stops, waypoints, or multiple destinations documented. |
| Map / navigation lifecycle | No standalone marker, search-only action, zoom, heading, automatic GO/navigation start, or stop-navigation action documented. Directions mean journey planning, not guaranteed turn-by-turn activation. |
| Callbacks / credentials | No callback, x-callback-url, return URL, API key, partner ID, signature, login or partner enrollment requirement specified for these public links. This does not waive ordinary service terms. |

The [2023 shutdown notice](https://citymapper.com/news/2596/sdks-and-apis-come-to-an-end) concerns self-service REST/embedded SDK products, **not a stated retirement of public app links**. Conversely, historical routing API fields must not be copied into `citymapper://directions`. The old directions article's closing SDK/API advertisement is stale relative to that notice.

## Existing implementation versus the contract

Inspected [`citymapper.dart`](../../lib/src/maps/citymapper.dart), [`map_app.dart`](../../lib/src/maps/map_app.dart), [`location.dart`](../../lib/src/models/location.dart), [`url_builder.dart`](../../lib/src/utils/url_builder.dart), and [`nav_only_maps_test.dart`](../../test/maps/nav_only_maps_test.dart) at the baseline.

| Behavior | Assessment |
| --- | --- |
| Native directions | Emits `endcoord`, optional `endname`, and optional `startcoord`/`startname`; matches documented field names and coordinate order. Uses the same builder on Android/iOS. |
| Address labels | `endaddress` / `startaddress` absent; generic coordinate model has a title but no separate address. A documented capability gap, not a malformed basic request. |
| HTTPS | `directionsUrl()` returns null and inherited `hasUniversalLink` is false despite documented HTTPS form. Browser support is currently unexposed; test fallback before changing metadata. |
| Marker | Advertises `supportsMarkerCoords == false`; native marker method nevertheless opens directions as a best-effort fallback. Correctly not represented as a real pin. No zoom effect. |
| Modes and waypoints | Accepted in method signature but ignored. Base `supportsTravelMode()` returns true, which overstates selectable-mode support. No launch contract supports these values. |
| Encoding | `buildUrl` uses `Uri(queryParameters: ...)`, omits blank strings, encodes values once, and commonly uses `+` for spaces. Need native compatibility verification against the guide's `%20` examples. |
| Discovery | Android package `com.citymapper.app.release`, App Store ID `469463298`, iOS scheme `citymapper://`; Android manifest and example iOS query-scheme entry are present. Consumers still need their own iOS query declaration. Detection does not prove a specific action works. |

Existing tests check URL scheme and field presence, origin inclusion and null browser URLs; they do not establish exact field values, native parsing or real routing outcomes.

## Concrete verification before extending support

1. Parse generated query values and independently assert destination `51.532499,-0.10579` versus origin `51.50685,-0.142927`, on both platform branches. This detects coordinate reversal and swapped endpoints; symmetric coordinates would not.
2. Round-trip `Café & Tea + #1/入口?` as both names. Check null/blank omission, comma encoding once, and compare native handling of `%20` with `+`.
3. Test omitted origin with permission granted, denied and location unavailable; explicit origin must win over GPS. Record app/OS versions and use a supported city plus an out-of-coverage point.
4. Open HTTPS links in Safari/Chrome with app installed and absent, then open the scheme directly. Confirm destination, labels, origin and fallback outcome rather than merely a successful OS launch.
5. If address fields are added later, verify their display without treating them as geocoding inputs. Do not add historical time fields without renewed vendor confirmation and date-boundary tests.
6. Explicitly test that marker fallback means directions and that unsupported mode/waypoint requests are not advertised as honored.

No native devices were used for this research. No app code, capability flags or tests were changed.
