# TMAP external app launch reference

Checked **2026-10-02**. Primary sources are the Korean **TMAP Invoke** pages in the [official developer guide](https://tmapapi.tmapmobility.com/main.html), not the REST routing API. The page router serves HTML fragments; direct fragment links below avoid loading only the navigation shell. Some automated readers misdecode UTF-8 as Latin-1; the original HTML was retrieved and read as UTF-8 for this research. No last-update date is published in these pages; individual app-version notes are recorded below. No native testing was performed.

Baseline: [`8aa7a6e`](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131), verified as fetched `origin/master`; [builder](../../lib/src/maps/tmap.dart), [capabilities](../../lib/src/maps/map_app.dart).

## Three interfaces must not be conflated

1. **Raw native links in this repository:** `tmap://viewmap?...` and `tmap://route?...`. A complete current primary-source raw-scheme contract was not recovered. Their observed *construction* is documented below; their acceptance on Android/iOS is device-unverified.
2. **Official HTTPS launch service:** `https://apis.openapi.sk.com/tmap/app/{action}?appKey=...`. These URLs launch TMAP from mobile, rather than return a route JSON response or guarantee a desktop map. The provider explicitly requires `appKey` here.
3. **Official external-app invocation helpers:** `TMapTapi` / `TMapApi.invokeRoute`, `invokeNavigate`, etc. These open the installed TMAP application and therefore are relevant external-launch interfaces. Their dictionary keys and argument names are **not automatically raw URL query parameters**. They are distinct from embedded Navi/ETA SDK route calculation, which is out of scope.

The older `tmapapi.sktelecom.com` host appears in historical integrations; current primary pages are under `tmapapi.tmapmobility.com`. A [secondary SwiftUI example dated 2023-05-22](https://develop-const.tistory.com/33) uses `tmap://route?rGoName=...&rGoX=...&rGoY=...`; this is a useful compatibility lead, not proof that the repository's `goalx` family is invalid on iOS. Do not “fix” one family to the other without a raw-scheme contract or device check.

## Official HTTPS actions and fields

All paths below are relative to `https://apis.openapi.sk.com/tmap/app/`. All require **`appKey` (string, issued API key)**. No default key or anonymous-launch guarantee is documented. The table's types/requiredness are the provider's.

| Action | Other fields | Meaning / primary source |
| --- | --- | --- |
| `execution` | None | Launch TMAP; [source](https://tmapapi.tmapmobility.com/webv2/sample/webSample59.html). |
| `map` | Optional `name` string, `lon` number, `lat` number | Map display; longitude then latitude by named fields. Defaults not stated; [source](https://tmapapi.tmapmobility.com/webv2/sample/webSample60.html). |
| `routes` | Full table below | Enter route summary; [source](https://tmapapi.tmapmobility.com/webv2/sample/webSample61.html). |
| `poi` | Required string `name` | POI integrated keyword search; [source](https://tmapapi.tmapmobility.com/webv2/sample/webSample62.html). |
| `poidetail` | Required string `poiId`; optional string `pKey` | POI details; `pKey` combines POI and entrance point, iOS support from **TMAP 10.2**. Case matters (`pKey` in table); [source](https://tmapapi.tmapmobility.com/webv2/sample/webSample98.html). |
| `nearby` | Required strings `reqKey`, `scheme`, `host`, `tailParam` | `reqKey=FUDALL` restaurants or `CAFEALL` cafes; fixed `scheme=tmap`, `host=nearby`; `tailParam` is encoded JSON containing numeric `centerLon`, `centerLat`; [source](https://tmapapi.tmapmobility.com/webv2/sample/webSample97.html). |

### Route query fields

Source: [route launch reference](https://tmapapi.tmapmobility.com/webv2/sample/webSample61.html). `x` means longitude and `y` latitude; entrance coordinates are not the same as a place's display center. The table gives no geographic range, numeric precision, label length, URL size, or explicit CRS switch. Decimal degree examples correspond to Korean geographic locations; WGS84 interpretation is conventional rather than explicitly specified in this launch table. Do not copy projected-coordinate or `reqCoordType` options from REST APIs.

| Field | Type / required | Meaning, default, limits |
| --- | --- | --- |
| `appKey` | String / yes | Issued key for this HTTPS service. |
| `startx`, `starty` | Number / no | Origin longitude, latitude; omission behavior not stated. |
| `startid` | String / no | Origin POI ID. |
| `startflag` | String / no | Origin RP flag; values not enumerated. |
| `startname`, `startaddr` | String / no | Origin name and address. |
| `goalx`, `goaly` | Number / **yes** | Destination longitude, latitude (old names `lon`, `lat` noted by provider). |
| `goalgx`, `goalgy` | Number / no | Destination entrance longitude, latitude. |
| `goalid` | Number / no | Destination POI ID; unlike `startid`, provider types it as Number. |
| `goalpkey` | String / no | Identifier containing POI and entrance point. |
| `goalflag` | String / no | Destination RP flag. |
| `goalname` | String / **yes** | Destination name. |
| `goaladdr` | String / no | Destination address. |
| `via1x`, `via1y`; `via2x`, `via2y` | Number / no | First and second waypoint longitude, latitude. Only **two slots** documented on this HTTPS interface. |
| `via1id`, `via2id` | Number / no | Waypoint POI IDs. |
| `via1flag`, `via2flag` | String / no | Waypoint RP flags. |
| `via1name`, `via2name`; `via1addr`, `via2addr` | String / no | Waypoint names and addresses. |
| `angle` | Number / no | Vehicle heading when requesting guidance; no range/default stated. |
| `history_data` | String / no | Comma-separated location fix; schema below. |
| `autostart` | String / no | `y` skips route summary; default **`n`**. Added **7.5**. Provider says taxi-app-only and recommends `navigate` for other apps because some TMAP-only features do not operate. This is not a documented general-purpose `/navigate` HTTPS endpoint. |
| `referrer` | String / no | Calling app package name, e.g. `com.skt.tmap`; caller identification, not a callback. |
| `guideoption` | Number / no | **0** optimal, **1** minimum time, **2** toll-free, **3** shortest distance, **4** prefer highways, **5** prefer comfortable roads, **6** prefer two-wheeler roads. Added **7.1.1**. No default printed. |

`history_data` fields, in table order: latitude `double` degrees; longitude `double` degrees; horizontal accuracy `float` meters; bearing `float` degrees; provider `string` (example `gps`); speed `float` meters/second; fix time `long` UTC milliseconds since 1970-01-01. The example is `37.52290030039832,126.95798301201155,107.77323,0.0,gps,0.0,1524132001292`. **Its accuracy/bearing values differ from the individual column examples**; do not infer a different ordering from those values. Number of historical fixes, repetition syntax, ranges, and escaping inside the provider string are not defined.

Percent-encode each query value once, including Korean names, `&`, `#`, and `tailParam` JSON; retain JSON numeric coordinates and use a dot decimal separator. No callback/return URL, arrival/departure time, walking/transit/bicycle mode selector, or extra attribution field is listed. `guideoption=6` is a two-wheeler route policy, not documented bicycle navigation.

## External-app invocation helper contracts

These primary sources describe launching an installed app, **not raw URL serialization**: [Android route helper](https://tmapapi.tmapmobility.com/android/docs/androidDoc.html#TMapTapi_invokeRoute_2), [iOS route helper](https://tmapapi.tmapmobility.com/iosv2/docs/iosDoc.html#TMapTapi_invokeRoute_2), and [iOS sample 43](https://tmapapi.tmapmobility.com/iosv2/sample/iosSample.html#sample43). The guide notes compatibility **3.2.8 / 4.0 build 3122 and later**. Android values are `HashMap<String,String>`; iOS uses `Dictionary<String,Any>` with numeric coordinate examples and string names. Defaults/ranges are otherwise unspecified.

| Route dictionary key | Requirement / meaning / platforms |
| --- | --- |
| `rGoName`, `rGoX`, `rGoY` | Required destination name, longitude, latitude; Android/iOS. |
| `rStName`, `rStX`, `rStY` | Optional origin name, longitude, latitude; Android/iOS. |
| `rStAddr`, `rGoAddr` | Optional origin/destination address; Android table and iOS sample. |
| `rGoGX`, `rGoGY` | Optional destination entrance longitude/latitude; Android table and iOS sample. |
| `rGoFlag` | Destination RP flag; Android notes **8.0.0 added**; also in iOS reference. |
| `rV1Name`, `rV1X`, `rV1Y`, `rV1Addr`; `rV2Name`, `rV2X`, `rV2Y`, `rV2Addr` | First/second waypoint name, longitude, latitude, address; Android/iOS sample. Android marks X/Y required when adding a waypoint. |
| `rV3Name`, `rV3X`, `rV3Y`, `rV3Addr`; `rV4Name`, `rV4X`, `rV4Y`, `rV4Addr`; `rV5Name`, `rV5X`, `rV5Y`, `rV5Addr` | Third–fifth waypoints in **Android** table only; X/Y required when adding. Do not extend the two-slot iOS/HTTPS contract by analogy. |
| `rV1Id`…`rV5Id`, `rV1Flag`…`rV5Flag` | Android waypoint POI IDs and guidance codes. |
| `rV1pkey`…`rV5pkey`, `rV1navSeq`…`rV5navSeq` | Android waypoint pkey and entrance sequence identifiers; exact lowercase suffixes are significant. |
| `rV1centerX`…`rV5centerX`, `rV1centerY`…`rV5centerY` | Android waypoint display-center longitude/latitude. |
| `rAngle` | Vehicle heading; Android/iOS. |
| `rSOpt` | Same **0–6** meanings as `guideoption`, plus **7** avoid school zones + recommended route; below TMAP **8.1**, 7 falls back to recommended. Android notes **7.1.1 added** for route options. |

Additional external-app helpers, documented in the same [Android](https://tmapapi.tmapmobility.com/android/docs/androidDoc.html) and [iOS](https://tmapapi.tmapmobility.com/iosv2/docs/iosDoc.html) references:

| Helper | Launch arguments / behavior |
| --- | --- |
| `invokeTmap` | Android reference: no arguments; open installed app. No corresponding iOS helper was found in the retrieved reference. |
| `invokeRoute` simple overload | Destination name plus longitude/latitude (Android floats) or `CLLocationCoordinate2D` (iOS); route guidance. |
| `invokeSetLocation` | Destination name and coordinate; move map. |
| `invokeSearchPortal` | Search name string. |
| `invokeGoHome`, `invokeGoCompany` | No route coordinates; use saved home/work. |
| `invokeNearCafe`, `invokeNearFood` | Center longitude/latitude on Android; coordinate on iOS. |
| `invokeNavigate` | Destination name, coordinate, POI ID integer, boolean `isAutoClose` (Android) / `autoclose` (iOS); enters navigation screen. Auto-close means close TMAP upon arrival, **not** invoke a caller URL. Android explicitly says **TMAP 7.0.4+**. |

The helper pages include authentication setup APIs; their credentials are SDK configuration, not proof of an `appKey` query requirement on `tmap://`. Raw query spellings for saved-home/work, search, nearby, immediate navigation, and auto-close were not established from these helper signatures. Authentication success/failure delegates are not navigation-completion callbacks.

## Implementation comparison and gaps

| Field / capability | Current implementation | Assessment |
| --- | --- | --- |
| Marker action / coordinates | `tmap://viewmap?x={lng}&y={lat}`, optional `name` | Longitude/latitude orientation agrees with provider convention. Raw action/keys not independently verified by recovered current primary contract; HTTPS equivalent uses `map`, `lon`, `lat`. |
| Marker title / zoom | Optional `name`, ignores `zoom` | HTTPS name optional; no launch zoom found. Raw optionality still unverified. |
| Destination | `goalx`, `goaly`, optional `goalname` on `tmap://route` | Names resemble HTTPS contract, where `goalname` is mandatory, but applying HTTPS requiredness to raw links is **not proven**. iOS helper uses `rGo*`; compatibility deserves targeted testing. |
| Origin | Optional `startx`, `starty`, `startname` | Matches HTTPS vocabulary, not proof of raw-scheme acceptance or current-location fallback. |
| `carType` | Always string `1` | **Not present in recovered launch contract.** Do not import vehicle-class meanings from REST/embedded SDK tables. Unsupported versus ignored on device remains unknown. |
| Travel mode | Ignores all modes; inherited capability returns true for driving/walking/transit/bicycling | **Demonstrable capability/implementation mismatch**, irrespective of raw URL acceptance. |
| Waypoints | Ignored; advertises false | Omitted external invocation feature, honestly restricted. HTTPS has 2 slots; Android helper 5. |
| Entrance/POI/address/heading/policy/history/referrer | Not emitted | Omitted features of official launch interfaces; raw equivalents must be established before adding. |
| Immediate navigation / callbacks / search / saved places | Not implemented | Invocation features omitted; no URL callback contract found. |
| Web | Universal methods null, flag false | Does not expose keyed mobile HTTPS launch service; that service is not established as a desktop map fallback. |

## Concrete follow-up tests

1. Golden query test with origin `(37.553017,126.972646)` and destination `(37.497942,127.027621)` must assert `x=longitude`, `y=latitude` and preserve `서울 & 출구?#` as one decoded value.
2. Assert capabilities cannot promise four selectable modes while URLs remain identical for all modes. Do not invent walking/transit query names to satisfy a test.
3. Test HTTPS service separately with required key and destination name, two ordered waypoint slots, and policy 0 versus 6. Never put real keys in fixtures/logs or assume route-API key handling applies to native links.
4. If helper-backed integration is introduced, test Android 5/6 waypoint and iOS 2/3 waypoint boundaries, `rSOpt=7` version fallback, entrance versus center coordinates, and auto-close false/true.
5. Required device investigation: raw `goal*` versus `rGo*` on Android/iOS, omitted title/origin, `carType=1`, app absent, route preview versus immediate guidance, and return behavior. The source review does not establish any of these runtime results.
