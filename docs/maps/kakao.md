# KakaoMap external links

Checked **2026-10-02**. Primary sources: Korean [iOS URL Scheme guide](https://apis.map.kakao.com/ios_v2/docs/getting-started/urlscheme/), [Android guide](https://apis.map.kakao.com/android_v2/docs/api-guide/urlscheme/), and the **지도 URL** section of the [Web guide](https://apis.map.kakao.com/web/guide/). The retrieved iOS guide specifies app **6.0.0+**. The provider [2025-06-30 update announcement](https://devtalk.kakao.com/t/url-scheme/144923) announces waypoints, modes, web subway routes, and trend ranking; no later revision date appears on the retrieved guides. No native application was tested.

Baseline: [`8aa7a6e`](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131), verified as fetched `origin/master`; [builder](../../lib/src/maps/kakao.dart) and [base capabilities](../../lib/src/maps/map_app.dart).

## Native and mobile-web action parameters

For each native `kakaomap://{action}?{query}`, the provider also lists `http://m.map.kakao.com/scheme/{action}?{query}` as a mobile-web alternative when the app is absent. Trend ranking uses an HTTPS example. Preserve action casing, notably `roadView`. These mobile-web scheme endpoints differ from the cross-platform `/link/` forms below.

Source beside this complete action table: [native/mobile-web guide](https://apis.map.kakao.com/ios_v2/docs/getting-started/urlscheme/). It gives examples rather than a formal required/default/type schema. “Needed” means needed to express that documented action; unspecified omission behavior is not a documented default.

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

**Source conflict:** the 2025 announcement calls trend ranking mobile-app-only, whereas the current guide prints a mobile-web trend-ranking URL. Record it as a published example whose actual web behavior needs verification, not a guaranteed cross-platform capability.

No API key, `appname`, caller attribution, callback, return URL, immediate-navigation switch, avoid policy, route timing, or vehicle subtype is specified for these links. Do not import Kakao Navi SDK parameters into KakaoMap. A missing scheme should lead the caller to the app store; a recognized scheme with an unsupported action opens the app's main map according to the guide.

The [Android guide](https://apis.map.kakao.com/android_v2/docs/api-guide/urlscheme/) additionally documents standard **`geo:`** handling: `geo:37.537229,127.005515` for coordinates and `geo:0,0?q=서울+용산구+이태원로+179` for an address query. The additional field is `q` (search text); the example uses `+` for spaces. It does not enumerate other `geo:` parameters, zoom, defaults, or label grammar. This is Android-only in the recovered documentation and is not implemented by this provider builder. A generic `geo:` URI can resolve to another installed handler unless the caller targets KakaoMap's Android package (`net.daum.android.map` in this repository).

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

## Implementation comparison

| Contract | Current builder / capability | Assessment |
| --- | --- | --- |
| Coordinate marker | `kakaomap://look?p=lat,lng` | Matches documented form; ignores title/zoom, neither documented for `look`. |
| Route origin/destination | Optional `sp`, required `ep` | Correct keys/order. Origin-free behavior is not established by the current examples, so do not claim failure or guaranteed current location. |
| Route mode | Ignores `travelMode`, never emits `by`; inherited `supportsTravelMode` returns true for all four modes | **Demonstrable capability/builder mismatch.** Provider supports four modes, implementation does not select any. |
| Waypoints | Ignored; `supportsWaypoints=false` | Honest implementation limit; documented non-transit waypoints omitted. |
| Universal/web URLs | Both URL methods null; `hasUniversalLink=false` | Documented web alternatives omitted. Avoid equating web availability with verified universal-link association. |
| Search, place ID, Roadview, layers, entry screens, trend ranking, subway | Not exposed; search flags false | Omitted provider actions. |
| Names / encoding | Uses shared query encoder; native route names not emitted | No documented native route name key to add speculatively. Web tuple labels are a separate opportunity. |

## Concrete follow-up tests

1. Select each travel mode and assert exact native `by` values; separately assert web `traffic`/`walk` versus native `publictransit`/`foot`.
2. Route `(37.402056,127.108212)` → `(37.395297,127.110449)` with two distinct intermediate points. Assert `vp` then `vp2`, not `vp1`, and endpoint order. Test 5/6 waypoints and transit with any waypoint.
3. Assert `look.p` decodes to latitude first. For new search support, round-trip `카페 & 빵/출구?#`; test path encoding independently from query encoding.
4. Test native `roadView` versus web `roadview`, place IDs versus coordinate tuples, all five subway regions, and unsupported mode/region handling.
5. Device/browser work remains: origin omitted, app installed/absent, fallback routing, tuple labels containing commas, and trend-ranking web conflict. Tests of generated strings cannot prove those behaviors.
