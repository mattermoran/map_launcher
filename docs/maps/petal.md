# Huawei Petal Maps (花瓣地图): external launch protocol audit

Checked **2026-10-02**. Fetched `origin/master` and verified it matched [`8aa7a6e`](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131). **Runtime-unverified:** this audit reads provider launch specifications and package implementation; it does not establish successful app navigation on a device.

The primary contract is **PetalMaps Intents for Android** in Huawei Map Kit, not arbitrary Map Kit SDK methods or REST routes. Chinese pages read: [introduction](https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/petal-maps-introduction-0000001059189679), [route planning](https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/petal-maps-application-route-0000001060197996), [keyword search](https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/petal-maps-application-textsearch-0000001059480273), [POI details](https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/petal-maps-application-poi-details-0000001116495363), updated **2026-03-04 08:38**. English [navigation](https://developer.huawei.com/consumer/en/doc/HMSCore-Guides/petal-maps-application-navigation-0000001060038018) and [nearby search](https://developer.huawei.com/consumer/en/doc/HMSCore-Guides/petal-maps-application-nearbysearch-0000001059560208) updated **2026-03-04 08:44** were read. The Chinese nearby page and English keyword page timed out during this audit; this is an **access limitation**, not missing functionality.

“Documented” means explicit provider URI evidence. “Inferred” identifies conclusions from examples, and “unresolved” identifies ambiguities rather than assumed support. No secondary-only claim is treated as a contract, and no SDK availability or coordinate converter is used to prove a URI feature.

## Platform and link families

| Surface | Contract / evidence |
| --- | --- |
| Android custom scheme | `petalmaps://…` through `Intent.ACTION_VIEW`; call `resolveActivity` before starting or handle missing app. [Introduction](https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/petal-maps-introduction-0000001059189679). Repository targets package `com.huawei.maps.app`. |
| Android HTTPS app links | Provider explicitly calls `https://www.petalmaps.com/...` examples **Applink**, with distinct paths from custom scheme actions. Association resolution, browser behavior and app-absent fallback are runtime-unverified, not guaranteed by the table alone. |
| iOS | **No iOS external Petal app-launch contract established** by these Android Intent docs. Map Kit iOS SDK in the sidebar is unrelated to an installed Petal Maps iOS URI handler. Do not add iOS capability from its presence. |
| HarmonyOS | Huawei also offers typed [ArkTS `petalMaps` app-start APIs](https://developer.huawei.com/consumer/en/doc/harmonyos-references/map-petal-maps). They are not proof of equivalent `petalmaps://` fields or an Android/iOS callback contract. Not implemented by this package. |
| Published support envelope | Introduction lists Huawei phones with RAM >3 GB, EMUI 10.0+, HMS Core APK 5.0+. Treat this as the provider's documented support matrix, **not proof every other Android device fails**, especially given the separate Play listing. Regional support is linked to product pages, not guaranteed uniformly per action. |

No URI callback, return URL or completion-result key is defined for these five action families. No registered developer key is required in their parameter tables. The optional `utm_*` fields are source/marketing attribution, not callback destinations.

## Common attribution parameters

These five **optional String** keys appear in all five action tables, including custom schemes and the app-link actions: `utm_source` (channel source; package name or app name allowed), `utm_medium` (medium), `utm_campaign` (campaign name), `utm_term` (campaign keyword), `utm_content` (campaign content). No defaults, maximum lengths or allowed-character constraints are specified. Source: [route table](https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/petal-maps-application-route-0000001060197996), also each action link below.

## POI detail / marker

Source: [Chinese POI details](https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/petal-maps-application-poi-details-0000001116495363), 2026-03-04. Endpoint pair:

```text
petalmaps://poidetail?marker=13.7457891,100.5528094&z=15
https://www.petalmaps.com/place/?marker=13.7457891,100.5528094&z=15
```

| Key | Required | Type / range / default |
| --- | --- | --- |
| `marker` | **Yes**, even if `placeId` supplied | String geographic **latitude,longitude**, either place's coordinates or arbitrary marked point. |
| `center` | No | String **latitude,longitude**; default marker position. |
| `z` | No | Integer **3–20 inclusive**, default **15**. |
| `placeId` | No | Place identifier string; no format/length constraint published. |
| `utm_*` | No | Common attribution above. |

No custom marker title, description, address, traffic toggle or callback appears in this table. `placeId` is not a label. One provider app-link example omits `&` between `placeId` and `marker`; use the table's distinct query parameters, not that malformed snippet.

## Route planning

Sources: [Chinese route](https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/petal-maps-application-route-0000001060197996) and [English route](https://developer.huawei.com/consumer/en/doc/HMSCore-Guides/petal-maps-application-route-0000001060197996), 2026-03-04.

```text
petalmaps://route?saddr=48.8754,2.3578(巴黎大酒店)&daddr=home&type=drive
https://www.petalmaps.com/routes/?saddr=home&daddr=company&type=drive
```

The first example shows a **decoded value for readability**; encode names and entire query values before launching.

| Key | Required | Type / accepted values / default |
| --- | --- | --- |
| `saddr` | No | String start point: coordinates, place name, saved `home` / `company`, or coordinates + parenthesized label. Omitted → current location. |
| `daddr` | Yes | Same destination syntax; no default. Chinese example `48.8754,2.3578(巴黎大酒店)` has **no mandatory separating space**. English example includes a space before parentheses. |
| `type` | No | String **`drive`**, **`walk`**, **`bicycle`**, **`bus`**; default drive. Not `bike`, `cycling` or `riding`. |
| `utm_*` | No | Common attribution. |

**Coordinate order:** the Chinese route prose says only 经纬度, while the English translation says “longitude-latitude”. The Paris example `48.8754,2.3578` and Dubai examples `25.102916,55.165363` are clearly **latitude,longitude** geographically; marker docs state that order expressly. Therefore latitude-first routing is **strongly supported by examples, but the English prose is contradictory**. Do not reverse the implementation from translation wording alone; verify a point such as Bangkok whose longitude exceeds 90.

**Coordinate reference system:** these URI tables do **not** state WGS84 versus GCJ-02 or expose a `coord_type`/conversion flag. Global examples are not proof of a mainland-China datum rule. The package performs no coordinate conversion; a separate SDK converter cannot fill this URI documentation gap.

No route-policy/avoidance, waypoint array, route optimization, arrival/departure time or callback parameter is listed. App UI/store descriptions supporting multiple stops are **not URI support evidence**. No endpoint URI length/label length/distance/coordinate precision ceiling is published.

## Navigation and exit

Source: [English navigation](https://developer.huawei.com/consumer/en/doc/HMSCore-Guides/petal-maps-application-navigation-0000001060038018), updated 2026-03-04 08:44.

```text
petalmaps://navigation?daddr=25.16461,55.228869&type=drive
https://www.petalmaps.com/navigate/?daddr=25.16461,55.228869&type=drive
```

| Key | Required | Contract |
| --- | --- | --- |
| `saddr` | No | String origin coordinates or saved `home` / `company`; omitted → current location. Table does not promise arbitrary place-name search or parenthesized labels as broadly as the route table does. |
| `daddr` | Yes | String destination coordinates or `home` / `company`. Coordinate-order translation caveat above also applies. |
| `type` | No | **`drive`** (default) or **`exit`** (exit navigation). Route's walk/bicycle/bus values must not be copied here. |
| `language` | No | String `zh_CN` Chinese, `en` English; default Petal app language. |
| `utm_*` | No | Common attribution. |

`type=exit` is a documented additional action, but the table still marks `daddr` required and supplies no exit-specific example; whether exit can omit destination is **unresolved**. Test rather than claiming a destination-free exit URL. Provider describes driving navigation yet illustrates a route-planning result; record actual guidance state in device tests before promising immediate turn-by-turn startup.

## Search actions

Sources: [Chinese keyword search](https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/petal-maps-application-textsearch-0000001059480273), [English nearby search](https://developer.huawei.com/consumer/en/doc/HMSCore-Guides/petal-maps-application-nearbysearch-0000001059560208), both updated 2026-03-04.

| Action | Parameters / behavior |
| --- | --- |
| `petalmaps://textSearch` | R String `text`, search keyword; O common `utm_*`. Returns a place-list UI, not structured search data to caller. |
| `https://www.petalmaps.com/textSearch/` | Table says R keyword **`q` for Applink**, one of `text`/`q`; however samples use `text` and contain formatting spaces in the URL. **Table/example inconsistency**: prefer table's q when designing, verify q versus text before implementation. Normalized path spelling is inferred from the displayed `text Search/` sample; not a browser-tested URL. |
| `petalmaps://nearbySearch` | R String `text`; O common `utm_*`. Searches around device's current location. **No center/radius/bounds/type filter listed. No corresponding app-link URL provided on the page.** |

No search paging/count/locale/POI category enumeration is defined. REST Site Kit/Map Kit search filters must not be imported into these URI fields.

## Implementation audit

Sources: [`PetalMaps`](../../lib/src/maps/petal.dart), inherited [`MapApp`](../../lib/src/maps/map_app.dart), [`LocationCoords`](../../lib/src/models/location.dart), [`buildUrl`](../../lib/src/utils/url_builder.dart), [`launch helper`](../../lib/src/utils/launch_helper.dart), [`Petal tests`](../../test/maps/osmand_petal_test.dart).

| Generated key / flag | Comparison |
| --- | --- |
| `petalmaps://poidetail`, `marker=lat,lng` | Matches explicit marker table. No title emitted; label not supported in audited marker URI contract. |
| Optional marker `z` | Correct key, **range 3–20 not validated** by builder/request; arbitrary integer forwarded. Omitted correctly leaves provider default 15. |
| `petalmaps://route`, `daddr` | Documented endpoint/key. Uses latitude-first and `lat,lng(label)`, matching Chinese example. Translation ambiguity is not evidence of an implementation reversal bug. |
| Optional `saddr` | Correct key; omission is explicitly current location. Parenthesized origin labels supported by route table. |
| `type=drive/walk/bus/bicycle` | All four mappings documented; default drive correct. Existing `bicycle` spelling is correct. |
| Attribution | Not generated; allowed omission because all utm fields optional. |
| Coordinate flags true, all four modes true | Consistent with Android marker/route contract. They do not imply walking/cycling/bus support on navigation endpoint. |
| Search flags false | Current implementation lacks documented `textSearch`/nearby and route name-based destination builders. Provider has broader capabilities. |
| `supportsWaypoints=false` | Consistent with **no URI waypoint parameter found**. Direct builder ignores argument; request layer rejects nonempty list. App UI multiple stops not evidence to change flag. |
| `hasUniversalLink=false`, HTTPS methods null | Implementation omits explicitly documented `/place/`, `/routes/`, `/navigate/` app links. A future HTTPS implementation still needs app-absent/browser tests before treating them as portable universal fallbacks. |
| Android-only metadata | Play package present; iOS scheme/App Store ID absent. Appropriate to audited Android contract. Direct scheme builder itself does not guard platform; don't mistake a returned string for supported iOS behavior. |
| Extras | No typed Petal extra. Generic extras can add `center`,`placeId`,`utm_*`; they append encoded query pairs, not replace existing generated values. Cannot switch route to navigation endpoint; duplicate `type`,`z`/`daddr` keys have unestablished precedence. |

The provider says names containing special characters need `UriEncode`. Package builds the whole `daddr`/`saddr` decoded string then encodes once through Dart `Uri(queryParameters: …)`, including Unicode, ampersands, percent signs and hashes. Spaces use query/form encoding; app interpretation of `+` versus `%20` remains unverified. Parentheses inside a title are potentially ambiguous after URL decoding because they are also syntax; no nested label-escaping rule is documented. Blank but non-null title becomes empty parentheses, unlike absence. Existing tests only round-trip through Dart's parser, not Petal's grammar.

## Proposed discriminating tests

1. Zoom: test omitted, 3, 20, and invalid 2/21; verify chosen validation policy or actual app result. Do not assert merely that `z` appears.
2. Route coordinates: use Bangkok `13.7457891,100.5528094` versus reversed order; test labeled/unlabeled endpoints and separate custom-scheme / HTTPS links. Check actual destination; a permissive app may open even with bad coordinates.
3. Test origin omitted versus `home`, `company`, and an explicit origin far from current location. Test text-only destination and coordinates-plus-label as distinct contracts.
4. Exercise all four **route** modes; separately test **navigation** drive and exit, including exit with/without `daddr`, and `language=en/zh_CN`. Record whether route preview or active guidance is reached.
5. Compare app-link keyword `q` and `text`; verify normalized path, percent encoding and app-absent browser behavior. Do not create a nearby HTTPS URL by analogy.
6. Label inputs should include `Café & Tea/入口? #1`, literal `+`, `%`, nested parentheses and empty title. Inspect displayed name and exact endpoint after provider parsing, not only `Uri.queryParameters`.
7. Check a mainland landmark against known source datums without assuming a conversion key; record app version/region/device and coordinate provenance. No new datum promise until provider/device evidence resolves it.
