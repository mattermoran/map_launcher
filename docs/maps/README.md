# Map launch protocol research

Research checked on **2026-10-02** against the implementation at
[`8aa7a6e`](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131).

These records cover external application launch contracts: universal links,
custom URL schemes, Android intents, and their documented parameters. They do
not treat parameters from a provider's REST API or embedded navigation SDK as
parameters accepted by its consumer app.

Each record links the sources used, inventories parameters and platform
differences, compares them with the plugin, and records unresolved questions.
Read the **implementation comparison** before using a documented parameter:
documentation of a provider feature does not mean this plugin exposes it.

## Existing integrations

| Map entry | Research and documentation sources |
| --- | --- |
| Apple Maps | [Apple](apple.md) |
| Google Maps | [Google](google.md) |
| Google Maps Go | [Google Go](google-go.md) |
| Waze | [Waze](waze.md) |
| Yandex Maps | [Yandex Maps](yandex-maps.md) |
| Yandex Navigator | [Yandex Navigator](yandex-navigator.md) |
| 2GIS | [2GIS](2gis.md) |
| HERE WeGo | [HERE](here.md) |
| Mapy.cz / Mapy.com | [Mapy](mapy.md) |
| Mappls / MapmyIndia | [Mappls](mappls.md) |
| Amap / Gaode | [Amap](amap.md) |
| Baidu Maps | [Baidu](baidu.md) |
| Tencent / QQ Maps | [Tencent](tencent.md) |
| Petal Maps | [Petal](petal.md) |
| Citymapper | [Citymapper](citymapper.md) |
| MAPS.ME | [MAPS.ME](maps-me.md) |
| OsmAnd | [OsmAnd](osmand.md) |
| OsmAnd+ | [OsmAnd+](osmand-plus.md) |
| TomTom Go | [TomTom Go](tomtom-go.md) |
| TomTom Go Fleet | [TomTom Go Fleet](tomtom-go-fleet.md) |
| CoPilot | [CoPilot](copilot.md) |
| Sygic Truck | [Sygic Truck](sygic-truck.md) |
| Flitsmeister | [Flitsmeister](flitsmeister.md) |
| Naver Map | [Naver](naver.md) |
| KakaoMap | [Kakao](kakao.md) |
| TMAP | [TMAP](tmap.md) |
| Moovit | [Moovit](moovit.md) |
| Neshan | [Neshan](neshan.md) |
| Air Navigation Pro | [Air Navigation Pro](air-navigation-pro.md) |
| Magic Earth | [Magic Earth](magic-earth.md) |

## Requested integrations and product distinctions

[Issue #111](https://github.com/mattermoran/map_launcher/issues/111) contains
requests already implemented as well as applications still absent. A checked
issue item is not proof that every edition or feature of that product is
supported. In particular, Sygic Truck is not interchangeable with Sygic GPS
Navigation, and TomTom Go/Fleet is not TomTom MyDrive.

| Requested app | Research and feasibility |
| --- | --- |
| Uber | [Uber](uber.md) |
| Lyft | [Lyft](lyft.md) |
| DB Navigator | [DB Navigator](db-navigator.md) |
| Transit App | [Transit](transit.md) |
| TomTom MyDrive | [TomTom MyDrive](tomtom-mydrive.md) |
| Lazarillo | [Lazarillo](lazarillo.md) |
| Organic Maps | [Organic Maps](organic-maps.md) |
| Sygic GPS Navigation | [Sygic](sygic.md) |

These are research records, not newly registered `MapApp` implementations.

## Findings to resolve before expanding support

The audit is not a release-readiness certificate. No native map application was
launched. The CoPilot marker and two store-identity corrections were implemented
during integration of this research and regression-tested; the other findings
below remain open.

| Priority | Finding and evidence | Required follow-through |
| --- | --- | --- |
| Fixed | [CoPilot](copilot.md) markers omitted required `lat` and `long`. | Both fields now emitted; Android/iOS URL tests cover unnamed and encoded labels. Confirm on a Truck-licensed installation. |
| Fixed | [Air Navigation Pro](air-navigation-pro.md) and [Magic Earth](magic-earth.md) had incorrect Apple store IDs. | Metadata and icon-fetch registry now match Apple's live listings; metadata tests pin the corrected IDs. |
| Correctness | [Amap](amap.md) uses undocumented route endpoints and omits required `dev`; [HERE](here.md) omits the documented `mylocation` origin segment. | Align with the exact platform/action contracts and add discriminating regression tests. Do not change coordinate-datum assumptions silently. |
| Action semantics | [OsmAnd/Plus](osmand.md) Android directions open a point; [MAPS.ME](maps-me.md) route fields contradict its legacy parser; [Air Navigation Pro](air-navigation-pro.md) markers invoke direct-to navigation. | Separate display, route planning, and active guidance. Verify current binaries before migrating legacy/source-derived contracts; aviation navigation must not masquerade as a passive pin. |
| Required inputs | [Naver](naver.md) omits required caller identity and sometimes marker name; [Baidu](baidu.md) omits required fields; [Tencent](tencent.md) needs a registered key and a current-location token. | Define caller configuration and missing-label/origin policies. Do not invent credentials or use SDK requirements as app-link requirements. |
| Capability accuracy | Several integrations accept travel modes or coordinate origins without serializing them; examples include [Kakao](kakao.md), [TMAP](tmap.md), [Moovit](moovit.md), [Waze](waze.md), and [TomTom](tomtom-go.md). | Encode documented options or reject unsupported requests. Platform/action-specific capabilities need explicit treatment. |
| URL options | [Google](google.md) universal-only extras reach native iOS URLs; generic extras append duplicate built-in keys. | Define action/platform-aware extras and collision behavior; preserve opaque and signed URL semantics. |
| Contract uncertainty | [Google Go](google-go.md) lacks a verified Go-specific launch contract; [Mappls](mappls.md) transit and bicycle semantics are not established; [Neshan](neshan.md) iOS marker key differs from indexed provider text. | Obtain current provider/device evidence; do not infer support from another product or a cached page alone. |
| Compatibility | [Yandex Maps](yandex-maps.md) current-location routes with waypoints and native cycling need device confirmation; [Navigator](yandex-navigator.md) signing covers exact URL bytes and unsigned launches are limited. | Check actual endpoints/stops, permission states, and signature construction on recorded app versions. Serialization tests alone are insufficient. |
| Modernization | [Apple](apple.md), [2GIS](2gis.md), [Mapy](mapy.md), [Waze](waze.md), and [Petal](petal.md) document additional launch actions. | Add features separately from bug fixes, with OS/app compatibility and mode/waypoint limits tested. |
| Product/licensing | [Sygic Truck](sygic-truck.md), [consumer Sygic](sygic.md), [CoPilot](copilot.md), and [GO Fleet](tomtom-go-fleet.md) have product or commercial restrictions. | Confirm the intended edition and entitlement before advertising or testing new capabilities. |

For issue #111, the best-supported new-map candidates are
[Organic Maps](organic-maps.md) pins/legacy two-point routes and
[Transit](transit.md) transit directions. Organic Maps' advertised v2 API
contradicts the inspected release parser, so its current-location and multistop
examples are not ready to copy. [Uber](uber.md) and [Lyft](lyft.md) need an
explicit ride-request action rather than being labelled ordinary navigation.
[DB Navigator](db-navigator.md) and [Lazarillo](lazarillo.md) lack a verified
current coordinate-launch contract. [MyDrive](tomtom-mydrive.md) mobile was
discontinued; its replacement website is not a drop-in native integration.
Consumer Sygic remains separate from the existing Truck entry.

## Evidence and maintenance

- **Documented:** a provider publishes the contract. Check the document's
  product, platform and version before applying it.
- **Legacy or archived:** useful historical evidence, not proof of current
  installed-app behavior.
- **Source-derived or secondary:** implementation or third-party evidence is
  identified explicitly; it is not presented as a current provider guarantee.
- **Unverified or inaccessible:** a blocked/dead documentation URL or a missing
  specification does not establish that a feature is unsupported.
- **Device validation:** URL serialization tests cannot prove that a particular
  installed application accepts or honors the URL. Native launch checks remain
  necessary for undocumented behavior and product-specific routing.

The check date records this audit, not the provider's last publication date or a
promise that the contract will stay unchanged. Publicly documented parameters
can be inventoried; private, partner-only and undocumented parameters cannot be
claimed exhaustive.

When changing an integration, update its record, link the exact source, and add
a test that distinguishes the old and new behavior. Preserve documented units,
coordinate order/system, delimiters and encoding boundaries. Do not infer
support from a similarly named product, or silently drop requested routing
options when no supported equivalent exists.
