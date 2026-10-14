# KakaoMap

The plugin opens native coordinate markers and routes with optional coordinate origins. Driving/transit/walking/bicycling emit `by=car/publictransit/foot/bicycle`; null mode omits `by`. Waypoints and web URLs are not exposed. Marker title/zoom are ignored. Android targets `net.daum.android.map`; iOS callers declare `kakaomap` for installation queries.

Reference check: 2026-10-13. Primary sources: [iOS schemes](https://apis.map.kakao.com/ios_v2/docs/getting-started/urlscheme/) (app **6.0.0+**), [Android schemes](https://apis.map.kakao.com/android_v2/docs/api-guide/urlscheme/), [Web guide](https://apis.map.kakao.com/web/guide/) and [2025-06-30 feature announcement](https://devtalk.kakao.com/t/url-scheme/144923). Tables include unimplemented provider actions.

Implementation: [builder](../../lib/src/maps/kakao.dart), [capabilities](../../lib/src/maps/map_app.dart).

## Native and mobile-web action parameters

For each native `kakaomap://{action}?{query}`, the provider also lists `http://m.map.kakao.com/scheme/{action}?{query}` as a mobile-web alternative when the app is absent. Trend ranking uses an HTTPS example. Preserve action casing, notably `roadView`. These mobile-web scheme endpoints differ from the cross-platform `/link/` forms below.

The iOS guide gives examples rather than a formal required/default/type schema. “Needed” means needed to express the action, not a documented omission policy.

| Action | Fields, syntax, requiredness | Values / behavior |
| --- | --- | --- |
| `open` | No fields needed | Open app. |
| `open` | Optional `page` string | `placeSearch` search entry; `routeSearch` route entry; `locationsharing` location-sharing screen. |
| `open` | Optional `layer` string | `skyview`, `bike`, `traffic`, `hyperaccuratebus`, `airinfo`, `cctv`; enables the named map layer. Multiple-layer syntax and defaults not documented. |
| `open` | `page=placerank&center=map` | Trend-ranking restaurants around current location. Only `map` is demonstrated for `center`. |
| `look` | `p=lat,lng`, needed for specified point | Center and marker at numeric decimal latitude,longitude. No title or zoom parameter documented. |
| `place` | `id={placeID}`, needed | Provider place ID (numeric-looking identifier, e.g. `18577297`), not address text. |
| `search` | `q={text}&p=lat,lng` | Keyword search around coordinates. Both appear in the example; optionality of `p` is not established by this page. |
| `route` | `sp=lat,lng`, `ep=lat,lng` | Origin and destination; examples provide both. No explicit current-location default or formal requiredness is given here. |
| `route` | `by={mode}` | **`car`, `publictransit`, `foot`, `bicycle`**. The page specifies no default. |
| `route` | Optional `vp`, `vp2`, `vp3`, `vp4`, `vp5`, each `lat,lng` | Ordered waypoints, **maximum five**; **not supported with public transit**. First is `vp`, not `vp1`. |
| `roadView` | `p=lat,lng` | Street-level Roadview at coordinate. No bearing/pitch/panorama ID fields documented here. |

**Source conflict:** the 2025 announcement calls trend ranking mobile-app-only, whereas the current guide prints a mobile-web trend-ranking URL. Web support needs confirmation.

No API key, `appname`, caller attribution, callback, return URL, immediate-navigation switch, avoid policy, route timing, or vehicle subtype is specified for these links. Do not import Kakao Navi SDK parameters into KakaoMap. A missing scheme should lead the caller to the app store; a recognized scheme with an unsupported action opens the app's main map according to the guide.

The Android guide also documents `geo:37.537229,127.005515` and `geo:0,0?q=서울+용산구+이태원로+179`. `q` is search text and `+` denotes spaces; no other Geo URI fields/defaults/label grammar are specified. This Android-only family is not implemented by the plugin. Untargeted Geo URIs may open another handler; KakaoMap's package is `net.daum.android.map`.

## Cross-platform web map URLs

Base `https://map.kakao.com`; the provider says these select PC or mobile-web maps based on environment. This is documented web fallback, not a promise of OS-level universal-link association.

Source: [Web guide, 지도 URL](https://apis.map.kakao.com/web/guide/#mapurl).

| Path pattern | Fields / requirements and meaning |
| --- | --- |
| `/link/map/{lat},{lng}` | Coordinates required; show point. |
| `/link/map/{name},{lat},{lng}` | Label and coordinates; name is a path component value, not a query key. |
| `/link/map/{placeID}` | Provider place ID instead of coordinates. |
| `/link/to/{name},{lat},{lng}` or `/link/to/{placeID}` | Destination-only directions. No explicit origin/default transport contract in table. |
| `/link/from/{name},{lat},{lng}/to/{name},{lat},{lng}` | Explicit origin and destination. |
| `/link/by/{mode}/{origin}/{destination}` | Each point is a name/latitude/longitude tuple or place ID per introductory prose. |
| `/link/by/{mode}/{origin}/{via...}/{destination}` | Up to five intermediate points; no transit waypoints. Preserve point ordering. |
| `/link/by/subway/{region}/{startStation}/{endStation}` | Station names and region required; regions **`seoul`, `busan`, `daegu`, `gwangju`, `daejeon`**. Web-only subway routing per announcement. |
| `/link/roadview/{lat},{lng}` or `/link/roadview/{placeID}` | Open Roadview. Note lowercase `roadview`, unlike native `roadView`. |
| `/link/search/{query}` | Search text in path. |

**Web mode names are `car`, `traffic`, `walk`, `bicycle`.** Native/mobile-web-scheme `publictransit` and `foot` must not be copied into the `/link/by/` path.

Coordinates are decimal **latitude,longitude**. The Web guide identifies `LatLng` as WGS84; link examples use that order. No scheme-specific coordinate bounds, precision, zoom limits, maximum label/query length, URL-length limit, or route-distance limit is stated. Do not confuse embedded-map zoom/level or API projection settings with link fields. Encode user text as a URL component (UTF-8 percent encoding); retain structural commas and path separators. The guide does not define escaping of commas *inside* tuple labels, so verify those separately. Embedded JavaScript maps need `appkey`; the link tables do **not** require it.

## Plugin limitations

The builder allows an omitted origin, but the provider's examples do not specify
that case. They also give no default for an omitted mode.

The plugin does not expose waypoints, web links, search, place IDs, Roadview,
layers, entry screens, trend ranking or subway links. Direct builders ignore
waypoints. Native marker titles and route names have no documented fields;
labeled web links use a separate format.
