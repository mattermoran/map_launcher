# Baidu Maps (百度地图)

Checked: **2026-10-13**. Native-device behavior has not been verified.

## Plugin behavior and configuration

Android/iOS markers use `baidumap://map/marker`, with a supplied nonblank title or coordinate-text fallback. During launch preparation, iOS defaults `content` to coordinate text only when the caller has not supplied a description through extras; only Android sends `traffic=on`. Optional zoom is forwarded. Routes use `baidumap://map/direction`, coordinate/name composites, and modes `driving`, `walking`, `transit`, `riding` (default driving). Android requires a nonblank origin after extras are merged: supply coordinate `from` or a named `origin` extra. iOS defaults to `origin=我的位置` only when no origin is supplied. Raw URL getters omit these launch defaults and do not validate origin requirements. Both actions send `coord_type=gcj02` without converting coordinates. Search destinations, waypoints and web fallback are not implemented.

Configure `BaiduMaps(source: 'company.application')` to add `andr.` or `ios.`, or supply a complete `src` extra. No default attribution is provided. This is caller attribution, not an API key. The plugin does not reject absent attribution or enforce its documented format; provider acceptance has not been device-verified. Identical built-in extras are retained once. Conflicting built-in options still exclude the provider from discovery and cause explicit launch to report `MapLaunchException`.

Primary sources are the current Chinese **地图调起 API / URI API v2.0** pages: [Android](https://lbs.baidu.com/docs/webapi?title=mapadjustment/uri/andriod), [iOS](https://lbsyun.baidu.com/docs/webapi?title=mapadjustment/uri/ios), [web](https://lbs.baidu.com/docs/webapi?title=mapadjustment/uri/web), each updated **2026-03-20 16:08**; [HarmonyOS](https://lbs.baidu.com/docs/webapi?title=mapadjustment/uri/harmony), updated **2026-03-23 14:27**. The misspelled `andriod` in the official URL is intentional. The older [URI overview](https://api.map.baidu.com/lbsapi/uri.htm) remains accessible but is **legacy**, not preferred over the current tables.

REST place search/geocoding/navigation and SDK callbacks are separate APIs from these launch actions.

With shorthand `.baidu`, use `BaiduExtra(src: 'andr.example.myapp')` in `extra`
or `providerExtras`. Supply the complete prefix (`ios.` on iOS); unlike the
`BaiduMaps(source: ...)` constructor, this helper does not add it automatically.

## Platforms, attribution and coordinates

| Surface / field | Contract |
| --- | --- |
| Android native | `baidumap://map/<action>` in an Android Intent; installed Baidu app required. Provider distinguishes browser-oriented `bdapp://map/<action>`. Package used by this repository: `com.baidu.BaiduMap`. |
| iOS | `baidumap://map/<action>`; iOS navigation section also names `bdapp://map/navi` for browser use, although examples use `baidumap`. Do not generalize Android browser aliases to every iOS action. |
| Web | `http://api.map.baidu.com/<action>` in current official examples, generally `output=html`. Browser map, **not evidence of an OS Universal Link**. HTTPS availability/app association was not runtime-tested. |
| `src` | Required attribution/statistics, not a REST access key. Android convention `andr.companyName.appName`, iOS `ios.companyName.appName`, web `webapp.companyName.appName`. Some current tables copy the wrong platform prefix; platform-specific examples and iOS search/route tables clarify intent. Provider says service is not guaranteed without it. |
| `coord_type` | Explicit URI support for `bd09ll` (Baidu latitude/longitude; default), `bd09mc` (Baidu Mercator), `gcj02` (national-survey-encrypted), `wgs84` (GPS). General tables mark optional, some coordinate-action tables mark required. Supply the actual datum, especially for routes. This support is established by URI tables, **not inferred from coordinate-conversion services**. |
| Coordinate order | Geographic tuple `latitude,longitude`; bounding boxes `latSW,lngSW,latNE,lngNE`. Mercator is not decimal degrees and cannot be represented by the package's degree-validated `LocationCoords` without another model. No generic numeric range/precision/URI length limit is stated in the launch tables. |

No return-URL/callback query key is documented in the Android/iOS/web inventory. Android `startActivity`, iOS opening completion and Harmony promises concern app launching, not a route result returned to the caller. Most URI actions need no `ak`; **web panorama explicitly does**.

## Markers and map display

Sources: Android §2.2 and iOS §2.1 in the URI API v2.0 guides linked above. R = required; O = optional. All actions inherit required `src`.

| Action / key | Requiredness and syntax |
| --- | --- |
| `/marker`: `location` | R `lat,lng`. |
| `/marker`: `title` | R string on both platforms. No stated length/default. |
| `/marker`: `content` | O Android, **R iOS**; marker description string. |
| `/marker`: `coord_type` | O per requiredness column, default BD-09; description sometimes says required. |
| `/marker`: `zoom` | O numeric zoom; Android table gives `13` as an example, not an explicit default or range; iOS default “best visual level”. Do not import SDK zoom bounds. |
| `/marker`: `traffic` | Android O `on`/`off`. **Not listed for iOS marker** (it is listed for iOS `/show`). |
| `/show`: `center`, `bounds` | Android requires at least one; `bounds` overrides center + zoom. Center `lat,lng`; bounds SW then NE. iOS table lists O `center` but not `bounds`. |
| `/show`: `zoom`,`coord_type`,`traffic` | O. `traffic=on`/`off`; on iOS omission preserves existing state. |
| `/map` root (i.e. `baidumap://map`) | Open main map, no functional keys besides attribution. |
| `/geocoder`: forward | R `address` string; iOS O `zoom`. This opens map UI; it is not the REST geocoder response API. |
| `/geocoder`: reverse | R `location=lat,lng`; O `coord_type`,`zoom`. |

## Route planning

Endpoint on both platforms: `baidumap://map/direction`. Sources: Android §2.3.2 and iOS §2.2.3 in the URI API v2.0 guides.

| Key | Required | Values / syntax / differences |
| --- | --- | --- |
| `origin`, `destination` | Both R | Plain place name, bare `lat,lng`, or combined `name:LABEL` and `latlng:lat,lng` separated by ASCII pipe. Coordinates take routing precedence; name labels the point. **Name-only input must not be prefixed `name:`.** |
| `origin_uid`, `destination_uid` | O | POI ID strings; destination ID improves entrance guidance. |
| `coord_type` | Android R; iOS O | Four values above; iOS default BD-09. |
| `mode` | Android O; iOS table R | `transit`, `driving`, `truck`, `neweng` (electric/new-energy vehicle routing), `walking`, `riding`; prose default `driving` on both. Older iOS note says `navigation` is unsupported and navigation starts only at current location. The current Android mode table does **not** enumerate `navigation`; that cross-platform note is not sufficient evidence to add it. |
| `region`, `origin_region` | O | City/county; common region applies unless endpoint-specific region supplied. |
| `destination_region` | O iOS | Listed in iOS/web, not the current Android route table. |
| `sy` | O transit only | **Android:** `0` recommended, `2` fewer transfers, `3` less walking, `4` no subway, `5` shorter time, `6` subway first. **iOS:** `3` recommended/faster, `4` fewer transfers, `5` less walking, `6` no subway, `7` shortest time. No cross-platform shared numeric enum. |
| `index` | O transit only | Result index, integer starting at 0; no upper bound specified. |
| `target` | O transit only | `0` map, `1` detail. Android default `0` when index supplied; iOS no explicit default. |
| `car_type` | O | `BLK` avoid congestion, `TIME` shortest time, `DIS` shortest distance, `FEE` fewer highways, `HIGHWAY` highway priority, `DEFAULT` recommended without selecting app preference. Omitted: current app preference. iOS mentions local restrictions/license-plate policy. **FEE is not documented here as “avoid tolls”.** |
| `viaPoints` | O | URL-encoded JSON string, schema below. Android route table names JSON but omits detailed example; Android navigation and iOS route tables specify the object wrapper. **No Android/iOS maximum stated in these tables.** |
| `zoom` | O iOS | Default best visual level; not listed in current Android route table. |
| `src` | R | Platform-specific attribution above. |

Waypoint value **before outer query encoding**:

```json
{"viaPoints":[{"name":"深圳北站","lat":22.615108,"lng":114.035529,"uid":"POI_ID"}]}
```

`lat`,`lng` are numeric; `name`,`uid` are strings. `uid` is an enhancement for reaching an entrance, not a replacement for the whole tuple. The documentation does not separately mark each object field's requiredness. Use `encodeURIComponent`-equivalent encoding of the JSON value once, not hand-concatenation of raw JSON. iOS **7.1+** documents `origin=我的位置` as current-location input. The `origin` table is required; omission is **not a documented current-location default**.

## Navigation is not the directions screen

Sources: Android §2.4 and iOS §2.3 in the URI API v2.0 guides. Include `src` and correct `coord_type`.

| Action | Parameters / distinctions |
| --- | --- |
| `/navi`, both | Driving navigation. R `query` destination name; O `location=lat,lng`, `uid`, `type`, `viaPoints`. Android marks `coord_type` R, iOS O. `type` uses the `car_type` values above, default local app preference. `viaPoints` is the same encoded wrapper object. Some examples omit required `query`; record as provider inconsistency, not permission to omit. iOS starts from current location. |
| `/bikenavi`, Android | R `origin`, `destination` geographic tuples, `coord_type`, `src`. |
| `/ridenavi`, iOS | R `destination` tuple, `src`; O `coord_type`. **Different path, no origin parameter** in iOS table. |
| `/walknavi`, Android | R `origin`,`destination`,`coord_type`,`src`. Table calls `mode` required but its remark is a copied coordinate example and examples omit it: **valid mode values unresolved**, do not invent a requirement value. |
| `/walknavi`, iOS | R `destination`,`src`; O `coord_type`, `mode=walking_ar` for AR navigation; omit mode for ordinary walking. |
| `/navi/common`, Android 9.5.5+ | R `addr=home` or `company`, `coord_type`,`src`; saved address navigation. |

## Search, details and additional documented app actions

Sources: Android §§2.3–2.6 and iOS §§2.2, 2.4 in the URI API v2.0 guides. Required `src` remains applicable even where the provider says “no parameters”. Unless named, no default/range/limit is published.

| Action | Parameters and platform scope |
| --- | --- |
| `/place/search`, both | R `query`; scope via `region`, `bounds`, or `location` + `radius` (meters), precedence bounds > center/radius > region. O `coord_type`; iOS O `zoom`,`jumpto`. iOS `jumpto`: legacy `0` prior behavior, `1` map, `2` list; from 8.6, `1` full map, `2` half map/list, `3` full list. Android radius table misspells `redius`; prose/examples use **`radius`**. Combined location labels have differing example syntax; bare coordinates are clearest. |
| `/place/nearby` and `/nearbysearch`, Android | Both retained historical aliases. O `center`, `query`, `radius` default 5000 m; `coord_type` marked R. Neither center nor query → nearby page; center only → search-around page; query → search, center omitted → current location. |
| `/nearbysearch`, iOS | R `query`; O `center`,`coord_type`,`radius` default 5000 m. Android's no-query UI variants not promised here. |
| `/line`, both | R `region`,`name` strings; iOS O `zoom`. Bus/subway-line lookup, not route planning. |
| `/place/detail`, both | R `uid`; Android O `show_type=detail_bar` (default) or `detail_page`, since 7.1. iOS O `zoom`. |
| `/navi/offlinemap`, Android | Offline-navigation download screen; no additional keys. |
| `/routepage`, Android | O `type=bus/car/walk/ride` default car; O `param` JSON statistics, `action=set_home_action/set_company_action/dig_home_action/dig_company_action` to open saved-address secondary pages. |
| `/newsassistant`, Android | O `cityid`; omitted uses current city. Travel news page. |
| `/trip`, Android | R `action`; `edit` opens editor and requires string `tripId`; any other string opens main assistant. O `end_uid`,`end_name`,`end_loc`. Coordinate syntax for `end_loc` not specified in table. |
| `/page/realtimebus`, `/page/offlinemap`, Android 9.5.5+ | O `mode`: `CLEAN_MODE` clears stack, back exits; `MAP_MODE` clears stack, back returns to main map; `NORMAL_MODE` preserves stack; `NORMAL_MAP_MODE` preserves existing stack or inserts map if absent. No default stated. |
| `/component`, Android | Currency: `comName=international`, `target=international_exchangerate_page`; translation: same comName, `target=international_translation_page`; O stack `mode` as above. Currency section incorrectly titled offline maps; action/example identify currency. |
| `/component`, Android | AR building identification: R `comName=mapbasear`,`target=show_arexplore_page`. Subway home: R `comName=subway`,`target=subway_page_openapi`. |
| `/navi/cruiser`, Android | Driving warning/cruise UI; no functional keys. |
| `/traffic`, Android | R `keyword` road name; O `playMode`,`resetVoiceMode`, each `1` on (default), `0` off: spoken traffic and follow-up voice questioning respectively. |

## Browser-map URI contract

Source: [web specification](https://lbs.baidu.com/docs/webapi?title=mapadjustment/uri/web). These are UI launch URLs, **not `/place/v2`, `/geocoding/v3`, or routing JSON REST endpoints**. Base in official examples is `http://api.map.baidu.com`; required `src=webapp.companyName.appName`. Except panorama, the listed interfaces require **`output=html`**.

| Endpoint | Parameters |
| --- | --- |
| `/marker` | R `location=lat,lng`,`title`,`content`; O `coord_type`,`zoom` (best visual level). |
| `/geocoder` forward / reverse | R `address` for forward, `location=lat,lng` in reverse example; O `coord_type`,`zoom`. Reverse table mistakenly repeats `address`; do not erase the contradiction. |
| `/place/search` | R `query`; scope `region`, `bounds` SW/NE, or `location` + `radius`; same precedence as native. O `coord_type`,`zoom`. |
| `/line` | R `region`,`name`; O `zoom`; table also includes `bounds` with ambiguous “same as above” requiredness. |
| `/direction` | R `origin`,`destination` plain names/coordinates/combined values, `mode=transit/driving/walking`, `coord_type`; O `region`,`origin_region`,`destination_region`,`zoom`. **No web `riding`, native policies or waypoint keys documented here.** |
| `/place/detail` | R `uid`. |
| Panorama | Header gives `/place/pano`; example gives `/pano/`. R `ak` plus one of `xy`, `pid`, `uid`; example instead uses separate `x=longitude`,`y=latitude`. O `h` horizontal angle, `p` vertical angle (both default scene best); `nc=1`,`lc=1`,`issc=1` controls on by default, `ac=0` album off, `z=3` zoom, `iec=1` indoor exit on. **Endpoint/coordinate syntax conflicts require confirmation before implementation.** |

## HarmonyOS is a distinct launch contract

Source: [HarmonyOS page](https://lbs.baidu.com/docs/webapi?title=mapadjustment/uri/harmony) (2026-03-23). The package has no HarmonyOS platform. These documented additions must **not** be claimed for Android/iOS merely because the scheme is also `baidumap://map`.

Common O string keys: `needLocation=yes/no`; `isReducedAccuracyEnough=yes/no` (default no, used with `needLocation=yes`); `popRoot=no` preserves UI stack (default clears). Common `coord_type` values as above. Launch via `openLink` with `appLinkingOnly=false`; this is not an HTTPS Universal Link.

| Action | Harmony-specific contract / differences |
| --- | --- |
| Root, `/show` | O `bounds` (highest precedence), `zoom`,`center=lat,lng`,`userlocation` (use device location; exact accepted value unspecified). |
| `/marker` | R string `title`,`content`,`location`,`src`; O `coord_type`,`zoom`. |
| `/geocoder` | `address` or `location` (mutually exclusive; address wins); O `name`,`coord_type`,`zoom`; R `src`. |
| `/place/detail` | R `uid`; O `x`,`y` (datum/order not explained here), `show_type=detail_bar/detail_page`, default bar. |
| `/place/search` | R `query`; example adds `location`,`radius`, not independently specified in its table. |
| `/routepage` | R `type=walk/ride/car/neweng/truck/motor/bus/train/flight/coach/aitravel/rentcar_entrance`; `param` extra JSON (requiredness blank). Opening a route tab does not guarantee a corresponding routing mode. |
| `/direction` | R `origin`,`destination`; O `originName`,`originAddr`,`destName`,`destAddr` encoded strings; O `mode=transit/driving/walking/riding/moto` (train/flight/coach explicitly unavailable); O `force_mode=recommend/driving/transit` overrides mode. |
| `/navi` | R `location=lat,lng`; O `uid`, but provider does not guarantee successful navigation calculation without it. Mercator example reverses the stated geographic tuple convention; keep datum-specific tests. |
| `/nearby/sug` | R numeric `poiX`,`poiY`; O strings `address`,`from`,`poiPoint`,`source`,`uid`. Example uses latitude as X, longitude as Y; don't assume GIS X/Y convention. `uid` description is erroneous (“coordinates”). |
| `/busnearby` | O `busfrom` (currently unused), `param` JSON with `posX`,`posY` doubles and `cityId` (table string, example number). Campaign switch payload noted unsupported. |
| `/walknavi` | R `origin`,`destination`; `mode` explicitly unsupported. |
| `/bikenavi` | R `origin`,`destination`; O `coord_type`, `viaPoints` JSON **max 15**. Example waypoint objects add `isUserPokingPoint` boolean and `typeInUdc` string, or `uid`; not proof of the Android/iOS count limit. |
| `/truck/navigation` | Detailed truck-specific launch contract below. |

Harmony truck navigation parameters ([same source](https://lbs.baidu.com/docs/webapi?title=mapadjustment/uri/harmony)):

| Key | Requiredness / values |
| --- | --- |
| `location`, `query`, `uid` | At least location tuple or query; if location supplied query labels it, otherwise query searches; uid O. |
| `scene` | O number `0` during travel (default), `1` before travel. |
| `type` | O `BLK`, `TIME`, `ECONOMICS` save money, `FEE` no highways, `HIGHWAY`, `DEFAULT`; omitted local preference. |
| `viaPoints`,`trajectory_restore` | O encoded JSON. Waypoint wrapper above; trajectory object contains `id` string and `type`, passed to service. |
| `coord_type`,`src` | O in table, BD-09 default; src remark still warns no service guarantee without it and copies iOS prefix. Example `coord_type=1` conflicts with enumerated strings; do not reuse. |
| `plate_number`,`truck_type` | R plate string; R numeric type `1` micro, `2` light, `3` medium, `4` heavy. |
| `plate_color` | O `1` yellow, `2` blue default, `3` green, `4` black. |
| `height`,`width`,`length` | R doubles, meters: `(0,10]`, `(0,5]`, `(0,25]`. |
| `weight`,`load_weight` | R vehicle weight / rated load, tonnes `(0,100]`. |
| `axle_count`,`axle_weight` | Count R integer `[2,8]`; axle weight O tonnes `(0,100]`. |
| `is_trailer`,`displacement` | O trailer `1/0`; fuel consumption L/100km `(0,150]`. |
| `power_type`,`emission_limit` | R power `1` petrol, `2` diesel, `3` electric, `4` hybrid; R emissions `0..6` none / China I–VI. |

## Encoding and integration limits

Sources: [`BaiduMaps`](../../lib/src/maps/baidu.dart), [`MapApp`](../../lib/src/maps/map_app.dart), [`buildUrl`](../../lib/src/utils/url_builder.dart), [`launch helper`](../../lib/src/utils/launch_helper.dart), [`Chinese map tests`](../../test/maps/chinese_maps_test.dart).

`LocationCoords` has no datum tag. Labeling GPS/WGS84 coordinates `gcj02` does not convert them. Truck/new-energy modes are not representable by `TravelMode`. Provider `viaPoints` support is broader than the plugin: requests reject nonempty waypoints and direct builders omit them. Generic extras add absent fields but cannot override conflicting generated fields or change the endpoint.

Encode each query value once; preserve ASCII structural commas/colon/pipe inside the decoded combined value. A label containing a pipe or `name:`/`latlng:` sequence may become ambiguous to Baidu after outer decoding. JSON waypoints avoid delimiter splitting but still need correct query encoding. Existing tests prove Dart string assembly/round-trip, not provider acceptance, current-position semantics or navigation behavior.
