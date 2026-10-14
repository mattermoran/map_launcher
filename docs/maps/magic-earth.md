# Magic Earth

Checked: **2026-10-13**. Native-device behavior has not been verified.

## Plugin behavior

Android/iOS markers use `magicearth://?show_on_map&lat=...&lon=...` with optional `name` and `zoom`. Directions use destination coordinates and a bare `drive_to`, `walk_to`, `bike_to` or `public_transport_to` flag; Android additionally prefixes `get_directions`. Omitted mode selects `drive_to`. Origins and nonempty waypoint lists are rejected by direct builders; directions titles are not serialized. Search and web fallback are absent. The plugin retains all four mode capabilities, but current receiver semantics remain unverified because the official developer reference is unavailable. Current metadata uses Apple ID `1007331679`.

## Source status is consequential

| Source | Status/date | What it establishes |
| --- | --- | --- |
| [Official developer URL](https://www.magicearth.com/developers/) | HTTP **404** on checked date | Former contract location, not readable current documentation. Do not claim its old fields are a current official guarantee. |
| [Internet Archive capture index](https://web.archive.org/cdx/search/cdx?url=magicearth.com/developers/&output=json&filter=statuscode:200&filter=mimetype:text/html&collapse=timestamp:4) | “Temporarily Offline”; no usable capture list | No archived contract or capture date established. |
| [Current official homepage](https://www.magicearth.com/), [pricing](https://www.magicearth.com/pricing), [transport modes](https://www.magicearth.com/transport-modes) | Accessible, checked live; no publication date shown | Current product identity, free/premium capabilities; **not** URL parameters. |
| [Neamar/KISS issue 1906](https://github.com/Neamar/KISS/issues/1906) | **Secondary**, opened 2022-04-10, closed 2025-05-07 | Quotes former developer link and `magicearth://?q=%s&mapmode=standard`; reports caller-side URL validation difficulty. Not proof of successful Magic Earth parsing. |
| [Forum archive](https://4pna.com/archive/index.php/t-13861.html) | **Secondary archival forum/search evidence**, not official spec | Quotes addition of `magicearth://?daddr=...` and `...?saddr=...&daddr=...`. Version/platform/field grammar not sufficiently established; research lead only. |
| Plugin [builder](../../lib/src/maps/magic_earth.dart) | Current implementation | What map_launcher emits; **not independent evidence that Magic Earth accepts it**. |

No public official Magic Earth application parser repository was identified. Magic Lane SDK/API documentation is for embedding maps/navigation or backend requests; it must not be substituted for the external Magic Earth app protocol. Consequently this document explicitly leaves undocumented fields/defaults unresolved rather than inventing an exhaustive contract.

## Identity and free/paid platform differences

| Platform | Official identity | Plugin / source detail |
| --- | --- | --- |
| Android | `com.generalmagic.magicearth`, linked by [official homepage](https://www.magicearth.com/) to [Google Play](https://play.google.com/store/apps/details?id=com.generalmagic.magicearth) | Builder and package query agree. |
| iOS | Apple **`1007331679`**, linked by official homepage to [App Store](https://apps.apple.com/us/app/magic-earth-navigation-maps/id1007331679) | Matches plugin metadata. |
| iOS release snapshot | Apple [lookup](https://itunes.apple.com/lookup?id=1007331679): bundle `com.generalmagic.magicearth`, version **9.5.3**, released **2026-09-30T14:20:13Z** | Release snapshot, not a launch-contract specification. |
| Native scheme | Wrapper detects/emits `magicearth://`; secondary historical source also quotes it | Current official OS scheme registration unavailable; retain as unverified current behavior. |
| Web | No supported browser map/route fallback URL established | Homepage/store/pricing links are not map launch URLs. |

Current [official pricing](https://www.magicearth.com/pricing) calls tiers **Essential** and **Premium**. Essential includes search/turn-by-turn navigation and basic car/bicycle/pedestrian/truck routing. Premium adds offline maps/voice, traffic-aware routing, enhanced vehicle profiles, recording, CarPlay/Android Auto/Watch and other features. The official transport page also lists transit. These UI/product capabilities do **not** establish corresponding URL action fields such as a hypothetical `truck_to`, nor a different scheme for paid users. No free/paid URL grammar difference was documented. Historical “completely free” app descriptions are no longer reliable product guidance.

## Observed URL vocabulary, with evidence level per field

This is an observed vocabulary, not a current official contract. `R(wrapper)` means the builder always emits it, not receiver-requiredness. Evidence comes from the plugin builder, KISS issue and former developer reference listed in the source-status table.

| Action/field | Observed syntax and local default | Evidence and unresolved receiver semantics |
| --- | --- | --- |
| Scheme/base | `magicearth://?QUERY` | Wrapper and secondary example. No current scheme-registration source. |
| `show_on_map` | Bare flag preceding marker fields, R(wrapper) on both platforms | Wrapper only; current requiredness/value semantics unknown. |
| `lat` | Decimal string, R(wrapper) | Named latitude, validated −90…90 by wrapper. App range/default/datum unspecified in accessible evidence. |
| `lon` | Decimal string, R(wrapper) | Named longitude, validated −180…180 by wrapper. No paired-coordinate order ambiguity here, but do not claim receiver's validation from our code. |
| `name` | Optional marker title | Wrapper query-encodes; app length/encoding/default unspecified. |
| `zoom` | Optional integer | Wrapper forwards any passed integer; no independent range/default/clamping evidence. Do not import Google or OSM zoom limits. |
| `get_directions` | Bare flag used only by Android wrapper, before mode flag | Current necessity or iOS incompatibility not independently established. |
| `drive_to` | Bare mode flag | Wrapper maps driving and null to this; receiver's default mode is unknown. |
| `walk_to` | Bare mode flag | Wrapper maps walking; not independently confirmed against current docs. |
| `bike_to` | Bare mode flag | Wrapper maps bicycling; no documented advanced/e-bike profile parameters recovered. |
| `public_transport_to` | Bare mode flag | Wrapper maps transit; availability/behavior not independently confirmed. |
| `q` | Search text substituted for `%s` | **Secondary historical quote** only; not implemented in wrapper. `%s` is caller template syntax, not necessarily a literal app value. |
| `mapmode` | `standard` in historical example | **Secondary historical quote** only. No complete enum/default established; do not infer satellite/terrain URLs from UI styles. |
| `saddr`, `daddr` | Values elided in forum snippet | **Unverified secondary lead**, not evidence that arbitrary address/coordinate/waypoint syntax works. |

Current decoded wrapper shapes (not official examples):

```text
magicearth://?show_on_map&lat=59.3293&lon=18.0686&name=Example&zoom=14
magicearth://?drive_to&lat=59.3293&lon=18.0686
magicearth://?get_directions&walk_to&lat=59.3293&lon=18.0686
```

First is marker on both platforms; second iOS directions; third Android walking directions. Query scalar values pass through Dart `Uri(queryParameters: ...)`; bare action flags are then prepended by string replacement. They are not serialized as `flag=true`/`flag=`. Whether the current app treats those alternatives identically is unknown. The builder rejects origins/waypoints and omits destination titles for directions.

## Explicit gaps, rather than inferred absence

| Requirement | Evidence status |
| --- | --- |
| Required fields and unknown/malformed-input handling | No current official contract recovered. Wrapper requirements are not receiver requirements. |
| Coordinates | Wrapper sends geographic decimal lat/lon; current app datum, bounds enforcement and precision limits unverified. |
| Encoding | Wrapper encodes values and emits bare flags. Percent escapes, literal plus, non-ASCII and reserved punctuation acceptance unverified. |
| Marker versus route versus immediate guidance | Local naming implies distinct actions; actual confirmation/guidance timing unverified. |
| Origin/destination/waypoints | Wrapper has destination only. Secondary `saddr`/`daddr` lead requires vendor confirmation. UI multistop route support does not establish a URL waypoints field. |
| Modes | Four wrapper flags; official UI lists more profiles. No verified URL enum/default/range or premium profile parameters. |
| Map display/search | Marker flag/title/zoom in wrapper; historical `q`/`mapmode` quote. No current bounds/style/overlay grammar recovered. |
| Callbacks/extra actions | No verified callback URL/result, stop-navigation, favorites, GPX import Intent or app-screen command catalog recovered. Do not assert unsupported globally. |
| Native/web, Android/iOS | Wrapper differs in `get_directions`; independent current specification not available. No proven cross-platform HTTP fallback. |

## Integration limits

Local sources: [builder](../../lib/src/maps/magic_earth.dart), [base flags](../../lib/src/maps/map_app.dart), [URL encoder](../../lib/src/utils/url_builder.dart), [example Android package visibility](../../example/android/app/src/main/AndroidManifest.xml), [iOS example schemes](../../example/ios/Runner/Info.plist).

Current platform differences, bare flags, zoom, encoding and mode acceptance lack an independent current contract. Historical search/address examples remain secondary leads, not implemented or verified features. Essential/Premium offline entitlement can affect routing without changing package identity. A current vendor specification or installed-app evidence is needed to resolve these gaps.
