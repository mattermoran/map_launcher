# MAPS.ME

Checked: **2026-10-13**. Native-device behavior has not been verified.

## Plugin behavior

Directions serialize
`mapsme://route?sll=...&saddr=...&dll=...&daddr=...&type=...`, preserving that
relative order and both required name keys even when empty. This follows the
pinned official legacy
[route parser](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/map/mwm_url.cpp#L399-L440).
Serialization uses `Uri.queryParameters` locally, not the shared helper that
drops empty values. Driving/walking/transit/bicycling map to
`vehicle`/`pedestrian`/`transit`/`bicycle`; an omitted mode explicitly selects
`vehicle` (a wrapper default, not a parser default). An origin-less route returns
null: the URL parser requires two endpoints and there is no safe current-position
token established. No invented position or Android Intent-only fallback is used.
Markers use `mapsme://map?v=1&ll=lat,lng[&n=TITLE]`; zoom is ignored.
Waypoints, search, callbacks and web fallback are not implemented. The source is
legacy evidence, **not certification of today's closed-source app**.

## Evidence and platform identity

The [current official site](https://maps.me/) confirms Android package `com.mapswithme.maps.pro` and Apple ID `510623322`, matching our builder and Android package query. It does not publish a complete current launch specification. The contract below is **legacy official-source inference**, not a promise about the currently distributed closed-source app:

- Official `mapsme/omim` default revision [1892903, 2021-04-28](https://github.com/mapsme/omim/commit/1892903b63f2c85b16ed4966d21fe76aba06b9ba). Repository is not formally archived, but this default branch is stale.
- Official [Android API library](https://github.com/mapsme/api-android/tree/baba74f75d4a1bff0473ab6036e9148a10a4472b) and [iOS API library](https://github.com/mapsme/api-ios/tree/c47d30111a437dedc1c0a2ec0e43fc79c9dc6669), both last updated 2019-09-18, explicitly stopped offering support. These are historical integration references, not current guarantees.

| Surface | Registration/evidence | Interpretation |
| --- | --- | --- |
| Core custom URL | `mapsme://`, `mapswithme://`, `mwm://` | Parser accepts all three; OS registration is narrower. [Parser](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/map/mwm_url.cpp#L114-L138) |
| Android | General `mapsme:`; `mapswithme:` for `lead`; `geo:`, `ge0:`, HTTP(S) `ge0.me`, HTTPS `dlink.maps.me` and development link domain | Do not infer that every core scheme is externally launchable. [Manifest](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/android/AndroidManifest.xml#L93-L196) |
| iOS | `mapswithme`, `mapsme`, `ge0`, `geo`, `mapswithmepro`; associated domains include `dlink.maps.me`, `mapsme.onelink.me`, development domain | `mwm` is not registered; `mapswithmepro` registration does not establish API parser support. Our `mapswithme://` detection and `mapsme://` launch agree with legacy registration. [Plist](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/iphone/Maps/MAPSME.plist#L60-L75), [entitlements](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/iphone/Maps/maps.me%20rel.entitlements) |
| Browser/web | `ge0.me` and attributed/universal-link entry points exist | A browser URL is not proof of a desktop map/route fallback; current redirect behavior not tested. No standalone web launch contract established. |
| Free/paid | Current store links identify one app on each platform | Package suffix `.pro` and legacy scheme `mapswithmepro` are not evidence of a separate current paid launch protocol. No entitlement-dependent URL field identified. |

## Common syntax

Action is the URL host: `mapsme://map?...`, not a REST path. Scheme, action, and parameter keys are case-sensitive. Query is split on `&`, then first `=`, and URL-decoded; a bare key is an empty value. Encode each value, including nested callback URLs, once. Unknown keys are generally ignored. [URL lexer](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/coding/url.cpp#L195-L255).

`ll`, `sll`, `dll`, `cll` mean **latitude,longitude**, geographic degrees. Legacy validation accepts latitude −90…90 and longitude −180…180; conversion to Mercator is internal, not an input coordinate system. The source does not explicitly name the datum in this parser, so “WGS84-style geographic coordinates” is inference, not a quoted datum guarantee. [Coordinate parser](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/map/mwm_url.cpp#L140-L165), [boundary tests](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/map/map_tests/mwm_url_tests.cpp#L289-L296).

## Map display and callbacks

Source for this table: [map parser](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/map/mwm_url.cpp#L316-L397), [viewport handling](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/map/mwm_url.cpp#L534-L558), [legacy style constants](https://github.com/mapsme/api-android/blob/baba74f75d4a1bff0473ab6036e9148a10a4472b/lib/src/com/mapswithme/maps/api/MWMPoint.java#L135-L163).

| `map` field | Requiredness/type | Values, defaults, ordering and limits |
| --- | --- | --- |
| `ll` | At least one valid coordinate pair required; repeatable | Starts a point. Multiple points frame together; no explicit parser count limit (tests exercise 10,000, not a platform URL-size guarantee). |
| `n` | Optional string, empty default | Name for preceding `ll`; before any `ll` invalidates URL. |
| `id` | Optional string, empty default | Caller identifier or URL for preceding point; before any `ll` invalidates URL. |
| `s` | Optional style string | Applies to preceding point. Library emits `placemark-red`, `placemark-blue`, `placemark-purple`, `placemark-yellow`, `placemark-pink`, `placemark-brown`, `placemark-green`, `placemark-orange`. No caller-specified icon URL contract. |
| `z` | Optional double, default 0 | Only affects a single point and only if ≥1; capped to app comfort scale. Old Android helper emits only 1…19. Multiple-point viewport is not controlled by this field. |
| `v` | Optional integer, default 0 | Invalid value resets to 0; metadata, not an API-compatibility gate. |
| `appname` | Optional string, empty default | Caller title. |
| `backurl` | Optional URL/scheme string | If missing `://`, parser appends `://`. Encode nested query delimiters. |
| `balloonaction` | Optional presence flag, default false | Even `balloonaction=false` enables it; controls immediate balloon action/callback behavior. |
| `affiliate_id` | Optional string | Recorded after successful parsing for every recognized action; default empty. [Common handling](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/map/mwm_url.cpp#L305-L314) |

Repeated point attributes overwrite the current point's attribute. Repeated `ll` needs an ordered multimap/query list; our `Map<String,String>` URL helper cannot express it.

Legacy iOS pin callback: `CALLER://pin?ll=LAT,LON&n=NAME&id=ID`. `backurl` and balloon action are distinct from a universal success/error callback; no route-completion callback was established. [Official API README](https://github.com/mapsme/api-ios/blob/c47d30111a437dedc1c0a2ec0e43fc79c9dc6669/README.md#L143-L160).

## Route, search and additional actions

| Action | Fields and requiredness | Behavior/limits and exact source |
| --- | --- | --- |
| `route` | **All five keys, in relative order:** `sll=lat,lon`, `saddr=source name`, `dll=lat,lon`, `daddr=destination name`, `type=mode` | Exactly two points. Name keys required though empty values can parse. No omitted/current-location origin, waypoints, or default mode. `type` lowercased then checked against `vehicle`, `pedestrian`, `bicycle`, `transit`. Unknown keys may intervene. [Parser](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/map/mwm_url.cpp#L399-L440), [negative tests](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/map/map_tests/mwm_url_tests.cpp#L270-L287) |
| `search` | Required nonempty `query`; optional `cll=lat,lon`, `locale=string`, presence flag `map` | Invalid center ignored; stored center defaults 0,0, locale empty; `map=false` still enables flag. No documented locale enum or query length ceiling. [Parser](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/map/mwm_url.cpp#L442-L471) |
| `lead` | Required nonempty `utm_source`, `utm_medium`, `utm_campaign`; optional `utm_content`, `utm_term` | Persists marketing attribution, not a map action. Order independent. [Parser](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/map/mwm_url.cpp#L473-L490) |
| `catalogue` | Required nonempty `id`; optional `name` | Catalog item; UUID syntax not enforced. Spelling is `catalogue`. [Parser](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/map/mwm_url.cpp#L492-L503) |
| `guides_page` | Required nonempty `url` | Core stores string; Android treats it as relative to catalog frontend. Do not interpret as an unrestricted web opener. [Parser](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/map/mwm_url.cpp#L505-L509), [Android consumer](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/android/src/com/mapswithme/maps/intent/Factory.java#L172-L179) |
| `subscription` | Required nonempty `groups` | No core syntax/enum validation established; do not invent product identifiers. [Parser](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/map/mwm_url.cpp#L511-L515) |

### Compact geographic links

`ge0://ZCCCCCCCCC[/NAME]`, `http://ge0.me/ZCCCCCCCCC[/NAME]`, and HTTPS equivalent encode a single geographic point, not a route. One zoom character plus nine interleaved coordinate characters use `A–Z a–z 0–9 - _`. Zoom = encoded value / 4 + 4, range 4…19.75 in quarter steps; generator clamps. Latitude maps −90…90, longitude −180…180 excluding the upper endpoint. Names swap spaces/underscores and percent-encode reserved characters; decoder takes at most 256 encoded name bytes, and malformed trailing percent escapes truncate. Do not substitute ordinary query encoding for this name codec. [Parser/format](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/ge0/parser.cpp#L31-L176), [generator](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/ge0/url_generator.cpp#L9-L168). `geo:` is registered, but it is a separate generic parser; the custom `map` field contract must not be assumed to apply to it.

### Android external Intent API (not an embedded SDK)

Action `com.mapswithme.maps.api.request`, legacy API version **2**. All extras below have prefix `com.mapswithme.maps.api.`. [Constants](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/android/src/com/mapswithme/maps/api/Const.java), [receiver](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/android/src/com/mapswithme/maps/api/ParsedMwmRequest.java), [sender](https://github.com/mapsme/api-android/blob/baba74f75d4a1bff0473ab6036e9148a10a4472b/lib/src/com/mapswithme/maps/api/MwmRequest.java).

| Request extra | Type/role |
| --- | --- |
| `url` | String carrying map URL; normal show-points payload. |
| `title` | Optional string used as caller/request title. |
| `version` | Integer API version, helper sends 2. |
| `caller_app_info` | Parcelable caller application information. |
| `has_pen_intent` | Boolean indicating callback Intent exists; spelling is intentional. |
| `pending_intent` | Android `PendingIntent`, for returning a selection. |
| `return_on_balloon_click` | Boolean return policy. |
| `pick_point` | Boolean point-picking mode, default false in helper. No `crosshair` URL action exists. |
| `custom_button_name` | Optional string for callback button title. |

Result success is `Activity.RESULT_OK`, cancellation `RESULT_CANCELED`. Success extras: `point_lat`, `point_lon` (double), `point_name`, `point_id` (strings), `zoom_level` (zoom). Helper fallback callback is `mapswithme.client.<calling-package>`. `caller_app_info` is specifically an Android `ApplicationInfo` Parcelable. This contract needs an Intent-capable integration, not merely a URL string.

The manifest also registers the following **separate Android Intent actions**, with a more permissive origin/mode contract than the route URL. Sources: [extraction](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/android/src/com/mapswithme/maps/intent/Factory.java#L686-L775), [execution](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/android/src/com/mapswithme/maps/intent/Factory.java#L1115-L1236).

| Action | Extras | Behavior/defaults |
| --- | --- | --- |
| `com.mapswithme.maps.pro.action.SHOW_ON_MAP` | Required `lat`, `lon` as double or float extras | Both keys must exist; numeric fallback 0.0. Converts to `mapsme://map?ll=...`. |
| `com.mapswithme.maps.pro.action.BUILD_ROUTE` | Required `lat_to`, `lon_to`; optional paired `lat_from`, `lon_from` (double/float); optional string `saddr`, `daddr`, `router` | Incomplete/absent from-pair permits current position. Names absent/null allowed. `router` case-sensitive `vehicle`, `pedestrian`, `bicycle`, `taxi`, `transit`; absent/unknown falls to current/default. No-from branch only applies explicit numeric router types >0, a legacy implementation quirk. |

### Generic geo links, files and dynamic links

Legacy generic `geo:` parser recognizes path `lat,lon`, scalar `lat`/`lon` or `y`/`x`, and coordinate substrings in `q`, `m`, `saddr`, `daddr`, `sll`, `ll`, or parameter names containing `point`. Generic names are case-insensitive (unlike the custom API keys); `z`/`zoom` default 17 and clamp to 0…17. Embedded pair matcher requires decimal-point numeric forms; pure address geocoding is not established. `x` means longitude, `y` latitude. Higher-priority fields override lower-priority ones: scalar lat/lon, x/y, ll, point, sll, saddr/daddr, q/m, then path. [Generic parser](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/coding/url.cpp#L29-L177), [validation/defaults](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/coding/url.cpp#L348-L402), [examples/tests](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/coding/coding_tests/url_tests.cpp#L111-L158).

Android file imports expose KML (`application/vnd.google-earth.kml+xml`) and KMZ (`application/vnd.google-earth.kmz`), plus file paths ending `.kml`/`.kmz` with `*/*`. Non-file URIs depend on recognized MIME tails. No GPX import is declared in this historical manifest. [Filters](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/android/AndroidManifest.xml#L198-L232), [receiver](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/android/src/com/mapswithme/maps/intent/Factory.java#L577-L683).

Verified legacy Android dynamic-link hosts `dlink.maps.me` and `dlink.mapsme.devmail.ru` explicitly handle `/catalogue`, `/guides_page`, `/subscription`; other paths use an adapter to the old core scheme. This is historical mapping, not evidence that today's hosted service resolves identically. [Mapping/validation](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/android/src/com/mapswithme/maps/intent/Factory.java#L371-L553).

## Integration limits

Local sources: [`mapswithme.dart`](../../lib/src/maps/mapswithme.dart), [`map_app.dart`](../../lib/src/maps/map_app.dart), [`url_builder.dart`](../../lib/src/utils/url_builder.dart), [example Android declarations](../../example/android/app/src/main/AndroidManifest.xml), [example iOS declarations](../../example/ios/Runner/Info.plist).

The route builder deliberately preserves empty `saddr`/`daddr` values using `Uri.queryParameters`; the shared helper drops blank values. A dictionary cannot represent the repeated point keys required for multiple markers. Request-layer waypoint rejection does not imply the direct route builder validates its unused waypoint argument. Compact geographic links do not establish a complete web route fallback.

Marker and route labels encode spaces as `%20` and literal plus signs as `%2B`:
the [legacy receiver decoder](https://github.com/mapsme/omim/blob/1892903b63f2c85b16ed4966d21fe76aba06b9ba/coding/url.cpp#L326-L345)
only decodes percent escapes and leaves `+` unchanged.

## Limitations

No current app source, installed app, or current versioned external-link specification was available. Legacy core acceptance is not OS registration, current compatibility, or live catalog/subscription backend availability. No REST, map-data service, or embedded rendering SDK is included here. Android file/Intent behavior above does not establish iOS file-import parity or current-release support.
