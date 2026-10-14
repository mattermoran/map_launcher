# Tencent / QQ Maps (腾讯地图)

Checked: **2026-10-13**. Native-device behavior has not been verified.

## Plugin behavior and configuration

Android/iOS markers use `qqmap://map/marker` with `marker=coord:lat,lng[;title:NAME]`. Routes use `qqmap://map/routeplan`, optional endpoint names, required destination coordinates and `fromcoord=CurrentLocation` when origin is absent. Driving/walking/transit/bicycling map to `drive/walk/bus/bike`, default driving. Zoom, search, waypoints and web fallback are not implemented.

Tencent documents a registered developer key through `TencentExtra(referer: ...)`. The plugin permits discovery and keyless launch attempts for compatibility; omission is outside the documented contract and provider acceptance has not been device-verified. Bind options with `providerExtras: {.tencent: TencentExtra(...)}` before discovery when supplying a key. The plugin does not certify key validity.

Sources are the current Chinese Tencent **URI API（地图调起）** pages. Individual parameter pages expose no update date; the [official changelog](https://lbs.qq.com/webApi/uriV1/uriLog) lists **v2.1, 2025-06-18** (HarmonyOS launch/routes), **v2.0, 2018-05-30** (iOS scheme / Android Intent, searches/markers/routes/street view), v1.5 2015-11-05, v1.0 2014-04-21. This is source-version context, not proof every current parameter existed in 2018.

REST directions, coordinate conversion, SDK routing/waypoints and embedded H5 components have separate contracts.

## Platform and attribution contract

Source: [native calling guide](https://lbs.qq.com/webApi/uriV1/uriGuide/uriMobileGuide), [web guide](https://lbs.qq.com/uri_v1/guide.html).

| Surface | Documented form / limitations |
| --- | --- |
| Android | Intent targeting Tencent Maps, URI base `qqmap://map/`; detect package `com.tencent.map`. |
| iOS | Same URI base; detect `qqmap://` with `canOpenURL` (query-scheme configuration is required for discovery under iOS rules). |
| HarmonyOS NEXT | Same base; `canOpenLink`; package `com.tencent.mapohos`. Current route page covers Harmony but explicitly excludes `bike`. This repository has no Harmony platform. |
| Web / H5 | `https://apis.map.qq.com/uri/v1/<method>`; opens web/WAP map product. **Not evidence of iOS Universal Link / Android verified App Link support.** Different parameter tables from native. |
| Download fallback | `https://pr.map.qq.com/j/tmap/download?key=YourKey`; key optional, browser-type key for attribution. Not a marker/route fallback preserving request state. |
| Native `referer` | **Required developer key** in native marker, geocoder, route, search, nearby and old native street-view tables. Do not substitute an arbitrary app name. |
| Web `referer` | Required calling source; web tables describe “generally your application name”, while examples sometimes show developer-key strings. Preserve this documentary distinction rather than assuming native rules match. |

There is no documented URI callback/return URL in these pages. Launch completion is not navigation completion. The [FAQ](https://lbs.qq.com/faq/webFaq/jsUriApi) warns that WeChat restricts third-party app opening and recommends separate H5 components; it also documents web `debug=true` for parameter diagnostics. Neither is a new native route field.

## Native route planning

Endpoint **`qqmap://map/routeplan`**, Android/iOS/Harmony. Source: [current native route table](https://lbs.qq.com/webApi/uriV1/uriGuide/uriMobileRoute). Despite the heading “navigation and route planning”, the described result is a **route-planning screen**, not a documented automatic-start guidance toggle.

| Key | Required | Type / values / limits |
| --- | --- | --- |
| `type` | Yes | String `bus`, `drive`, `walk`, `bike`; bike unavailable on Harmony. No default specified by provider. |
| `from` | No | Origin display name, string. |
| `fromcoord` | **Yes** | `lat,lng` decimal coordinate string, or exact token **`CurrentLocation`**. Native table does not state that omission means current location. |
| `to` | No | Destination display name. |
| `tocoord` | Yes | `lat,lng` destination. Unlike web table, text name is not an alternative to coordinates. |
| `touid` | No | Destination POI ID string; nearby entrance guidance for large parks/complexes. If too far from `tocoord`, ignored; distance threshold unspecified. |
| `passes` | No | **Up to 15** intermediate stops. Each `name:NAME;coord:lat,lng`, separated by **pipe (`\|`)**. See exact example below. No mode restrictions or minimum client version specified. |
| `referer` | Yes | Registered developer key. |

Provider's decoded `passes` example has an extra semicolon after the first coordinate:

```text
name:新业路(地铁站);coord:30.248015,120.207788;|name:华联·全景天地;coord:30.245793,120.218048|
```

The example contains an extra semicolon before the first pipe and a trailing pipe; their requiredness is unresolved. Encode the complete value once. The key is **`passes`**, not REST `waypoints`.

The native route table does not list `coord_type`, `policy`, `avoid`, `navigation`, `callback` or route-result return. Web conversion and policy fields do not establish native support. Native coordinates are expected to align with Tencent's map datum (commonly GCJ-02 in mainland China), but the native table does not explicitly name a datum or conversion flag. Raw GPS conversion remains unresolved.

## Native marker, geocoder, search and nearby

Sources: [marker/geocoder](https://lbs.qq.com/webApi/uriV1/uriGuide/uriMobileMarker), [search](https://lbs.qq.com/webApi/uriV1/uriGuide/uriMobilePoisearch), [nearby](https://lbs.qq.com/webApi/uriV1/uriGuide/uriMobileRoundsearch). These pages name Android/iOS, not a blanket Harmony guarantee. Every row requires `referer` developer key.

| Action | Required and optional fields |
| --- | --- |
| `qqmap://map/marker` | R `marker` composite string. Attributes `coord:lat,lng`, `title:NAME`, `addr:ADDRESS`; ASCII colon separates key/value, semicolon separates attributes. The table does not mark each attribute individually required. **Only one marker currently supported**, despite prose presenting a multiple-record grammar. |
| `qqmap://map/geocoder` | R `coord=lat,lng`; label/address generated from coordinates. Preferred documented action when caller has no name/address. This opens map UI, not a REST response. |
| `qqmap://map/search` city | R `keyword`; O `region` city string. No documented need to pre-geocode a query. |
| `qqmap://map/search` nearby | R `keyword`,`center=lat,lng` or `CurrentLocation`, `radius` meters. No range/default published for radius. |
| `qqmap://map/nearby` | R `coord=lat,lng`,`placeName` (page title); explores nearby popular places, distinct from keyword search. |

The marker text mixes literal `I` and pipe in its record-separator prose; [older provider marker page](https://lbs.qq.com/uri_v1/guide-mobile-poiMarker.html) clearly says pipe. Because native currently supports **one** marker, this is not evidence to implement multiple native markers. No zoom, label length limit, coordinate precision, route distance ceiling or URI byte limit is specified for these native actions.

### Legacy native street view remains documented, not runtime-proven

Source: [older official native street-view page](https://lbs.qq.com/uri_v1/guide-mobile-showPano.html), still readable, undated and absent from current native navigation menu. Endpoint **`qqmap://streetview`**, not `qqmap://map/streetview`.

| Key | Requirement / semantics |
| --- | --- |
| `pano` | R panorama scene ID string. Separate picker/REST service may obtain it, but the URI is what opens the scene. |
| `heading` | O number 0–360 degrees clockwise from north; default 0. |
| `pitch` | O angle: −90 up, +90 down, 0 horizontal; default 0. |
| `referer` | R developer key. |
| `zoom` | Example-only `zoom=1`; **no parameter-table range/default**, so not a supported configurable range established by this source. |

## Web / H5 URI actions have a different contract

Base `https://apis.map.qq.com/uri/v1/`. `referer` R as described above. Explicit web `coord_type` on marker/geocoder/search/routes is O: **`1` GPS, `2` Tencent coordinates (default)**; the URI docs explicitly promise conversion for non-Tencent coordinates. **This web support does not prove native support.** All geographic tuples are latitude,longitude. R/O = required/optional.

| Method | Parameters / defaults / scope | Primary source |
| --- | --- | --- |
| `marker` | R `marker` composite; attributes R `coord`,`title`,`addr`, O `tel`,`uid`; same colon/semicolon grammar. PC one marker; mobile prose directs multiple points to a **separate location-display component**, not a clear URI count contract. O `coord_type`. | [Web markers](https://lbs.qq.com/webApi/uriV1/uriGuide/uriWebMarker) |
| `geocoder` | R `coord=lat,lng`; O `coord_type`; resolves coordinate to address and displays marker. | [Web markers](https://lbs.qq.com/webApi/uriV1/uriGuide/uriWebMarker) |
| `search` city/bounds | R `keyword`; O `region`, **`bound`** (singular) `latSW,lngSW,latNE,lngNE`, `coord_type`. Search includes places, addresses and bus-line names, not transit itineraries. | [Web search](https://lbs.qq.com/webApi/uriV1/uriGuide/uriWebPoisearch) |
| `search` nearby | R `keyword`,`center`,`radius` meters; mobile-only `center=CurrentLocation`; O `coord_type`. No radius bounds/default listed. | [Web search](https://lbs.qq.com/webApi/uriV1/uriGuide/uriWebPoisearch) |
| `routeplan` | R `type=bus/drive/walk`; walk mobile only, **bike not listed**. One of `from` / `fromcoord` normally required; mobile omission of both explicitly uses current location. R `to` name; O `tocoord`,`coord_type`,`policy`. No `passes` or `touid` row. | [Web route](https://lbs.qq.com/webApi/uriV1/uriGuide/uriWebRoute) |
| `streetview` | R `pano`; O `heading` 0–360 default 0, `pitch` −90 up/+90 down/default 0. Example-only `zoom=1`, no defined range. | [Web street view](https://lbs.qq.com/webApi/uriV1/uriGuide/uriWebStreetview) |

Web `policy` default **0**: bus `0` faster, `1` fewer transfers, `2` less walking, `3` no subway; driving `0` faster, `1` no highways, `2` distance. Do not describe `2` as a toll policy. The current web route table contains a malformed “GPS” cell but the same `coord_type=1/2` definition is unambiguous in web marker/search pages.

## Encoding and integration limits

Sources: [`TencentMaps`](../../lib/src/maps/tencent.dart), [`TencentExtra`](../../lib/src/extras/tencent_extra.dart), inherited [`MapApp`](../../lib/src/maps/map_app.dart), [`launch helper`](../../lib/src/utils/launch_helper.dart), [`Chinese map tests`](../../test/maps/chinese_maps_test.dart).

The native geocoder is recommended by the provider for coordinate-only points but has no plugin builder. Native route names are labels, not text-only destinations. `passes` is documented but nonempty waypoint requests are rejected and direct builders omit them. Generic extras can add absent fields such as `touid` or `passes`; conflicting generated values are rejected. `TencentExtra` contains only `referer`.

`LocationCoords` validates finite degree ranges but does no datum conversion. `buildUrl` encodes a query value once, with Dart form-style space handling, and filters wholly blank values. It does not escape nested marker grammar separately: a title containing semicolon, colon or pipe can become structural after provider decoding. URL encoding is necessary, but not sufficient proof that arbitrary labels survive the provider grammar. No provider-supported nested escaping rule was found.
