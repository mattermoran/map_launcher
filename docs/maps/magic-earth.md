# Magic Earth external launch audit

Checked **2026-10-02** against fetched `origin/master`/HEAD [`8aa7a6e1152a80c4482003bdfaad8f850bdb6131`](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131). **Current launch-contract completeness could not be established:** the official developer reference is unavailable. No installed-app behavior was tested.

## Source status is consequential

| Source | Status/date | What it establishes |
| --- | --- | --- |
| [Official developer URL](https://www.magicearth.com/developers/) | HTTP **404** on checked date | Former contract location, not readable current documentation. Do not claim its old fields are a current official guarantee. |
| [Internet Archive index request](https://web.archive.org/cdx/search/cdx?url=magicearth.com/developers/&output=json&filter=statuscode:200&filter=mimetype:text/html&collapse=timestamp:4) | Returned “Internet Archive: Temporarily Offline” HTML, no usable capture list | No archive content or capture date was recovered. This audit does not cite an imagined historical snapshot. |
| [Current official homepage](https://www.magicearth.com/), [pricing](https://www.magicearth.com/pricing), [transport modes](https://www.magicearth.com/transport-modes) | Accessible, checked live; no publication date shown | Current product identity, free/premium capabilities; **not** URL parameters. |
| [Neamar/KISS issue 1906](https://github.com/Neamar/KISS/issues/1906) | **Secondary**, opened 2022-04-10, closed 2025-05-07 | Quotes former developer link and `magicearth://?q=%s&mapmode=standard`; reports caller-side URL validation difficulty. Not proof of successful Magic Earth parsing. |
| [Forum archive](https://4pna.com/archive/index.php/t-13861.html) | **Secondary archival forum/search evidence**, not official spec | Quotes addition of `magicearth://?daddr=...` and `...?saddr=...&daddr=...`. Version/platform/field grammar not sufficiently established; research lead only. |
| Our [builder](../../lib/src/maps/magic_earth.dart) | Audited baseline | What map_launcher emits; **not independent evidence that Magic Earth accepts it**. |

No public official Magic Earth application parser repository was identified. Magic Lane SDK/API documentation is for embedding maps/navigation or backend requests; it must not be substituted for the external Magic Earth app protocol. Consequently this document explicitly leaves undocumented fields/defaults unresolved rather than inventing an exhaustive contract.

## Identity and free/paid platform differences

| Platform | Current official identity | Baseline comparison |
| --- | --- | --- |
| Android | `com.generalmagic.magicearth`, linked by [official homepage](https://www.magicearth.com/) to [Google Play](https://play.google.com/store/apps/details?id=com.generalmagic.magicearth) | Builder and package query agree. |
| iOS | Apple **`1007331679`**, linked by official homepage to [App Store](https://apps.apple.com/us/app/magic-earth-navigation-maps/id1007331679) | **Concrete mismatch:** builder uses `476085748`. |
| iOS current release | Apple [lookup](https://itunes.apple.com/lookup?id=1007331679) returned bundle `com.generalmagic.magicearth`, version **9.5.3**, released **2026-09-30T14:20:13Z** | Lookup for old `476085748` returned no result, including Sweden. Positive official product link establishes correct identity; absence alone does not establish worldwide delisting. |
| Native scheme | Wrapper detects/emits `magicearth://`; secondary historical source also quotes it | Current official OS scheme registration unavailable; retain as unverified current behavior. |
| Web | No supported browser map/route fallback URL established | Homepage/store/pricing links are not map launch URLs. |

Current [official pricing](https://www.magicearth.com/pricing) calls tiers **Essential** and **Premium**. Essential includes search/turn-by-turn navigation and basic car/bicycle/pedestrian/truck routing. Premium adds offline maps/voice, traffic-aware routing, enhanced vehicle profiles, recording, CarPlay/Android Auto/Watch and other features. The official transport page also lists transit. These UI/product capabilities do **not** establish corresponding URL action fields such as a hypothetical `truck_to`, nor a different scheme for paid users. No free/paid URL grammar difference was documented. Historical “completely free” app descriptions are no longer reliable product guidance.

## Observed URL vocabulary, with evidence level per field

This is an **inventory to verify**, not a current official contract. `R(wrapper)` means our builder always emits it; this must not be read as receiver-requiredness. Sources adjacent: [baseline builder](../../lib/src/maps/magic_earth.dart), [historical secondary search example](https://github.com/Neamar/KISS/issues/1906), [unavailable official reference](https://www.magicearth.com/developers/).

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

First is marker on both platforms; second iOS directions; third Android walking directions. Query scalar values pass through Dart `Uri(queryParameters: ...)`; bare action flags are then prepended by string replacement. They are not serialized as `flag=true`/`flag=`. Whether the current app treats those alternatives identically is unknown. The builder discards origin, waypoint list and destination title for directions.

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

## Comparison and proposed tests

Local sources: [builder](../../lib/src/maps/magic_earth.dart), [base flags](../../lib/src/maps/map_app.dart), [URL encoder](../../lib/src/utils/url_builder.dart), [Android package visibility](../../android/src/main/AndroidManifest.xml), [iOS example schemes](../../example/ios/Runner/Info.plist).

- **Identity mismatch fixed during integration:** app metadata and icon-fetch registry now use `1007331679`, confirmed independently through Apple's live lookup, instead of baseline `476085748`. The metadata regression test expects the corrected ID; launch behavior is unchanged.
- **Not proven mismatches:** Android `get_directions`, iOS omission of it, bare flag spelling, coordinate field names and mode flags. They need live app/vendor verification, not correction based on guesswork.
- `hasUniversalLink=false` and null web builders are conservative given available evidence. Search flags false, waypoints false describe our implementation; historical search is an **omission candidate**, not a verified current feature. `supportsTravelMode` inherits true for all four modes; builder at least serializes distinct flags, but acceptance remains unverified.
- Ignored origin/waypoints/title are observable wrapper limitations. UI feature listings alone cannot classify missing fields as launch-contract defects.

Proposed tests (not executed):

1. Assert generated App Store URL targets the positive current listing; test Android package detection and iOS scheme detection separately from URL action success.
2. On current Android/iOS releases, run marker and all four direction flags, both with and without `get_directions`. Verify map display, planning UI and active guidance as separate outcomes. This resolves the most important undocumented platform split.
3. Test missing mode versus `drive_to`, bare flag versus `flag=`/`flag=false`, and null wrapper mode. Do not assume generic boolean rules.
4. Test `(−33.8688,151.2093)`, `(0,0)`, valid extrema, zoom absent/0/1/19/20, `name=A&B + café/港`, spaces as `+` versus `%20`. Record app behavior, not only generated string correctness.
5. Test historical `q=coffee&mapmode=standard` and the `saddr`/`daddr` lead on disposable routes only after confirming grammar. Test origins distinct from current GPS position to detect silently ignored inputs.
6. Repeat offline/online and Essential/Premium. Offline availability is now an entitlement concern, not a different package identity.

This audit cannot truthfully claim every documented historical/current Magic Earth action was recovered. The actionable next research step is a current vendor launch-specification copy or installed-app tests. Archived/secondary hints are intentionally not upgraded into official protocol facts.
