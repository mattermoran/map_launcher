# Amap / Gaode (高德地图)

Checked: **2026-10-13**. Native-device behavior has not been verified.

## Plugin behavior

The plugin supports Android/iOS coordinate markers and routes with optional origin and all four travel modes. Markers use `{android,ios}amap://viewMap`; routes use `amapuri://route/plan/` on Android and `iosamap://path` on iOS. Both send `sourceApplication=map_launcher` and `dev=0`, so callers must supply GCJ-02 coordinates: the plugin does not convert them. Missing or blank marker titles use coordinate text as `poiname`. Route modes map to `t=0/1/2/3`, defaulting to driving. Zoom, search, waypoints and web fallback are not implemented.

## Platforms and URI families

| Surface | Contract and source |
| --- | --- |
| Android | `androidamap://` actions; route planning specifically uses `amapuri://route/plan/`; walking/cycling navigation uses `amapuri://openFeature`. `ACTION_VIEW`, category `DEFAULT`, package `com.autonavi.minimap`. [Getting started](https://lbs.amap.com/api/amap-mobile/gettingstarted) (2024-09-06). |
| iOS | `iosamap://` actions; route planning is **`iosamap://path`**. Walking/cycling navigation examples instead use `amapuri://openFeature`. Declare `iosamap` in `LSApplicationQueriesSchemes` for discovery. [iOS calling guide](https://lbs.amap.com/api/amap-mobile/guide/ios/ios-uri-information). |
| Web / HTTPS | `https://uri.amap.com/…`, serving PC/H5 maps; selected actions accept `callnative=1` to attempt app opening. This is **not proof of OS-verified Universal Links/App Links**, nor a guarantee of app opening inside WeChat/QQ. [Overview](https://lbs.amap.com/api/uri-api) (2025-02-17), [route](https://lbs.amap.com/api/uri-api/guide/travel/route) (2025-03-03). |
| HarmonyOS NEXT | Separate `Want`/`startAbility` launch example using `amapuri://route/plan`; detection example uses `amapuri://com.amap.hmapp/open`. [Getting started](https://lbs.amap.com/api/amap-mobile/gettingstarted). Not a platform implemented by this package; do not infer Android/iOS endpoint equivalence from it. |

Action names (`viewMap`, `path`, `route`, `openFeature`) are URI components, not query parameters. Spelling and case matter. No callback/return-URL parameter is specified in these actions; iOS `openURL` completion reports the OS launch attempt, not navigation completion.

## Coordinate markers

Sources: [Android marker](https://lbs.amap.com/api/amap-mobile/guide/android/marker) and [iOS marker](https://lbs.amap.com/api/amap-mobile/guide/ios/marker), both updated 2024-08-08. Minimum app versions: Android 4.1.3, iOS 5.0.0.

```text
androidamap://viewMap?sourceApplication=APP&poiname=NAME&lat=39.9&lon=116.4&dev=0
iosamap://viewMap?sourceApplication=APP&poiname=NAME&lat=39.9&lon=116.4&dev=0
```

| Key | Required | Type / values / behavior |
| --- | --- | --- |
| `sourceApplication` | Both | Calling application name, string; provider says to always supply it. Not an API key. |
| `poiname` | Android yes; iOS no | POI/display name, string. No documented length limit. |
| `lat`, `lon` | Android yes; iOS paired or both absent | Decimal latitude and longitude in separate keys. iOS absent pair means current location. No endpoint-specific numeric bounds/precision published. |
| `dev` | Android yes; iOS required when coordinates supplied | `0`: already national-survey-encrypted coordinates (GCJ-02); `1`: need national-survey encryption, normally GPS/WGS84 input. No safe omitted default for supplied coordinates. |

No marker `zoom` key is documented for these actions. Do not copy `level` from `showTraffic`, or SDK map zoom ranges, into this contract.

## Route planning, including waypoints

Sources: [Android route](https://lbs.amap.com/api/amap-mobile/guide/android/route), [iOS route](https://lbs.amap.com/api/amap-mobile/guide/ios/route), both updated **2025-10-15**. Android minimum 4.2.1; iOS 5.0.0.

| Key | Required | Syntax / values / platform distinctions |
| --- | --- | --- |
| `sourceApplication` | Both | Application name. |
| `sid`, `did` | No | Start/end POI ID strings. Provider recommends IDs when available and reachable entrances rather than polygon centroids when only coordinates are available. IDs are not required to use the URI. |
| `slat`, `slon` | No | Start latitude/longitude. Android omission uses current location. iOS pair must be both present or absent. |
| `sname` | No | Origin name. On iOS coordinates take precedence; absent coordinates + name invokes name-based planning; neither means current location. |
| `dlat`, `dlon` | Android yes; iOS no | End latitude/longitude. iOS paired; coordinates take precedence over name, then current location if both absent. |
| `dname` | No | Destination name; prefer the place's official sign/name, not a postal-address-only description. iOS supports name-only destinations. |
| `dev` | Android yes; iOS conditional | `0` GCJ-02/already encrypted; `1` needs encryption. iOS requires it when start/end coordinates are present. |
| `t` | Both | `0` driving, `1` transit, `2` walking, `3` cycling (7.8.8+); Android additionally lists `4` train and `5` intercity coach. No documented default. |
| `rideType` | No | Only for `t=3`: `bike` or empty = bicycle; `elebike` = electric bicycle (8.65.0+). |
| `vian` | No, coordinated group | Integer count of intermediate points. |
| `vialons`, `vialats`, `vianames` | No, coordinated group | Parallel pipe-separated longitude, latitude and name lists; all counts must match `vian`. **No maximum count or mode restriction stated on these pages**; do not import SDK limits or the web URI's one-stop limit. |
| `m` | Legacy; table still marks yes | Driving `0` fastest, `1` least cost, `2` shortest, `3` no highways, `4` avoid congestion, `5` no highways + avoid tolls, `6` no highways + avoid congestion, `7` avoid tolls + congestion, `8` all three. **Ignored since Android 7.5.9 and iOS 7.7.4**, local preferences win. |

Legacy transit `m` differs: Android `0` fastest, `1` cheapest, `2` fewer transfers, `3` less walking, `4` comfortable, `5` no subway; iOS `0` fastest, `2` fewer transfers, `3` less walking, `5` no subway, `7` subway only, `8` shorter time. These values are not a reason to expose a working modern route-policy option.

## Navigation and other native actions

Unless noted otherwise below, `sourceApplication` is required; `lat`/`lon` mean separate decimal latitude/longitude; `dev=0|1` has the meaning above. R = required; O = optional. Dates are page update dates, not dates of runtime verification.

| Action / platform | Parameters and documented behavior | Primary source |
| --- | --- | --- |
| `androidamap://navi`, `iosamap://navi` | Current location → destination; R `lat`, `lon`, `dev`; O `poiname`, `poiid`. Legacy R `style=0..8`, same driving meanings as `m`; ignored from Android 8.2.6 / iOS 7.7.4. Android 4.1.3+, iOS 5.0.0+. | [Android](https://lbs.amap.com/api/amap-mobile/guide/android/navigation) (2025-04-09), [iOS](https://lbs.amap.com/api/amap-mobile/guide/ios/navi) (2024-08-08) |
| `androidamap://keywordNavi` | R `keyword` string; legacy R `style=0..8`, ignored from 7.6.5. Searches for destination, user selects result, then navigation. 5.0.0+. Not equivalent to a text-only route-preview API. | [Keyword navigation](https://lbs.amap.com/api/amap-mobile/guide/android/keyword-navi) (2024-08-08) |
| `amapuri://openFeature`, both platforms | Walking navigation: R `featureName`, `lat`, `lon`, `dev`. Example uses `featureName=OnFootNavi`, table says `onFootNavi` (case inconsistency). Examples incorrectly use latitude 110 and omit required `dev`; do not copy literally. 8.26.0+. | [Android walking navigation](https://lbs.amap.com/api/amap-mobile/guide/android/walk-navi), [iOS walking navigation](https://lbs.amap.com/api/amap-mobile/guide/ios/walk-navi) (2024-12-11) |
| `amapuri://openFeature`, both | Cycling navigation: R `featureName=OnRideNavi`, `lat`, `lon`, `dev`; `rideType` marked R but `bike`/empty explicitly means bicycle, `elebike` electric bicycle. 8.26.0+. | [Android](https://lbs.amap.com/api/amap-mobile/guide/android/ride-navi), [iOS](https://lbs.amap.com/api/amap-mobile/guide/ios/ride-navi) (2024-08-08) |
| `androidamap://poi` | R `keywords`; multiple terms pipe-separated. O `lat1`,`lon1` upper-left and `lat2`,`lon2` lower-right bounding box; O `dev`. 5.1.3+. | [Search](https://lbs.amap.com/api/amap-mobile/guide/android/search) (2024-08-08) |
| `iosamap://poi` | R `name`; O same four bounds (all or none), `dev`. 5.1.0+. Do not substitute Android `keywords`. | [Search](https://lbs.amap.com/api/amap-mobile/guide/ios/search) (2024-08-08) |
| `amapuri://poi/detail`, Android | R `poiname`, `lat`, `lon`, `poiid`; missing coordinates can move map to 0,0, missing ID prevents deep detail data. Source field not listed in this table. 7.5.9+. | [Search / details](https://lbs.amap.com/api/amap-mobile/guide/android/search) |
| `{android,ios}amap://arroundpoi` | Spelling really is `arroundpoi`. R `keywords`; Android O coordinates/`dev`; iOS coordinates marked R but prose permits absent pair → current location, requires `dev` when supplied. Android 4.2.1+, iOS 5.1.0+. | [Android](https://lbs.amap.com/api/amap-mobile/guide/android/around-query) (2024-08-08), [iOS](https://lbs.amap.com/api/amap-mobile/guide/ios/around-query) (2025-06-12) |
| `{android,ios}amap://myLocation` | No functional parameters besides application attribution. Android 4.2.1+, iOS 5.1.0+. | [Android](https://lbs.amap.com/api/amap-mobile/guide/android/location), [iOS](https://lbs.amap.com/api/amap-mobile/guide/ios/location) (2024-08-08) |
| `{android,ios}amap://rootmap` | Open main map. Android 4.2.1+, iOS 6.6.0+. | [Android](https://lbs.amap.com/api/amap-mobile/guide/android/map) (2024-06-25), [iOS](https://lbs.amap.com/api/amap-mobile/guide/ios/map) (2024-08-08) |
| `androidamap://viewReGeo` | R `lat`,`lon`,`dev`; reverse-geocode and display. 5.0.0+. | [Reverse geocoding](https://lbs.amap.com/api/amap-mobile/guide/android/regeocoding) (2024-08-08) |
| `androidamap://bus` | R `busname`, `city` (city code or city name). Bus-line lookup, not transit routing. 4.2.1+. | [Bus](https://lbs.amap.com/api/amap-mobile/guide/android/bus-query) (2024-08-08) |
| `{android,ios}amap://openFeature` | R `featureName=Subway`, `page=Subway` in iOS table / Android example; `adcode` required Android, optional iOS. Android 6.4.2+, iOS 6.5.0+. | [Android](https://lbs.amap.com/api/amap-mobile/guide/android/subway), [iOS](https://lbs.amap.com/api/amap-mobile/guide/ios/subway) (2024-08-08) |
| `iosamap://showTraffic` | R `poiid`; O `poiname`, coordinate pair (absent → current), `level` (default level unspecified), conditional `dev`. iOS 5.0.0+. Android `showTraffic` appears in official main-map example, without a complete parameter contract. | [iOS traffic](https://lbs.amap.com/api/amap-mobile/guide/ios/traffic) (2024-08-08), [Android example](https://lbs.amap.com/api/amap-mobile/guide/android/map) |

## Web URI inventory (separate parameter contract)

Base `https://uri.amap.com`. `src` is optional attribution, recommended; `callnative` where listed is `0|1`, default `0`, mobile only. Coordinate tuples here are **longitude,latitude**, unlike most other providers. No callback keys documented.

| Endpoint | Required and optional parameters | Provider documentation |
| --- | --- | --- |
| `/marker` single | R `position=lon,lat`; O `name`, `coordinate=gaode` or `wgs84` (default `gaode` = GCJ-02), `src`, `callnative`. Alternative R `poiid`, O `src`,`callnative`. | [Single point](https://lbs.amap.com/api/uri-api/guide/mobile-web/point) (2023-10-31) |
| `/marker` multiple | R `markers`: 1–10 pipe-separated `lon,lat[,name]` or POI IDs; commas/pipes ASCII. O `src`,`callnative`. No `coordinate` row on this page: do not assume the single-marker conversion flag generalizes. | [Multiple points](https://lbs.amap.com/api/uri-api/guide/mobile-web/points) (2021-01-22) |
| `/poidetail` | R `poiid`; O `src`,`callnative`. | [Details](https://lbs.amap.com/api/uri-api/guide/mobile-web/information) (2021-01-22) |
| `/search` | R `keyword`; O `center=lon,lat` (mobile only), `city` (name/area code/city code), `view=map` or `list` (default list), `src`,`callnative`. | [Search](https://lbs.amap.com/api/uri-api/guide/search/search) (2024-08-20) |
| `/nearby` | Mobile only; R `service=movie` or `hotel`, `location=lon,lat`, `city` code; O `src`. No `callnative` row. | [Nearby services](https://lbs.amap.com/api/uri-api/guide/search/around-search) (2024-08-20) |
| `/navigation` | `from`,`to` use `lon,lat[,name]`; table marks both R, notes allow absent origin → current position on mobile and forbid both empty. O `via` same tuple, **one stop maximum, driving only**; `mode=car/bus/walk/ride` default car; cycling mobile only and app 8.0.0+; `policy` default 0, see below; `src`,`callnative`. No coordinate conversion key listed for this endpoint. | [Routes](https://lbs.amap.com/api/uri-api/guide/travel/route) (2025-03-03) |
| `/line` | R `name`, O `city` name/area code/city code; alternatively R `id`, O `view=map` or `list` (default unspecified). Both accept O `src`,`callnative`. | [Bus/subway line](https://lbs.amap.com/api/uri-api/guide/travel/busline-search) (2021-01-22) |

Web `policy`: car `0` recommended, `1` avoid congestion, `2` avoid tolls, `3` no highways (mobile only); bus `0` best, `1` fewer transfers, `2` less walking, `3` no subway. These are **not** native `m`/`style` values.

## HarmonyOS route fields must not be copied into Android/iOS

Source: [HarmonyOS NEXT route](https://lbs.amap.com/api/amap-mobile/guide/harmony-os/route-next), updated **2025-11-03**, endpoint `amapuri://route/plan/`. This separate platform is outside the package's current platform model.

| Fields | Requiredness / values |
| --- | --- |
| `sname`,`slon`,`slat`,`dname`,`dlon`,`dlat` | All required; name strings and separate decimal longitude/latitude keys. Unlike Android/iOS, no omitted-origin current-position guarantee in this table. |
| `sid`,`did` | Optional POI ID strings. |
| `vialons`,`vialats`,`vianames`,`viaids` | Optional parallel pipe-separated waypoint longitudes, latitudes, names and IDs. No published maximum. |
| `t` | Required: `0` driving, `1` transit/subway, `2` walking, `3` cycling, `12` new-energy vehicle, `7` truck, `11` motorcycle. The introductory sentence only mentions driving/transit; table is broader. |
| `sourceApplication` | Required calling application name. |
| `m`,`dev`,`vian`,`userRelationToken` | Present in example but **not defined in this platform's table**. Do not infer their full contract, or copy example token-like strings into caller configuration. Example also omits required attribution. |

## Encoding and integration limits

Source: [`Amap`](../../lib/src/maps/amap.dart), inherited [`MapApp`](../../lib/src/maps/map_app.dart), [`buildUrl`](../../lib/src/utils/url_builder.dart), [`appendQueryParams`](../../lib/src/utils/launch_helper.dart).

Provider waypoint lists and web actions exceed the plugin's implemented surface. Nonempty waypoints are rejected by the request layer; the direct Amap builder does not serialize them. Generic extras can add absent fields, but conflicting built-in values are rejected rather than overridden.

The package does no coordinate conversion and `LocationCoords` has no datum tag. `dev=0` is a GCJ-02 assumption, not a conversion. URL-encode values once (Chinese, spaces, `&`, `#`, literal `%`, `+`). `buildUrl` uses Dart query encoding (spaces can become `+`). Pipe/comma-separated internal structures still need delimiter-aware tests: outer encoding does not prove names containing pipes are unambiguous after the app decodes them. No URI length, label length or native waypoint maximum was found; do not invent one.

URL-contract coverage: [Chinese map tests](../../test/maps/chinese_maps_test.dart). Device dispatch, coordinate placement and embedded-browser behavior remain unverified.
