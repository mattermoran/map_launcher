# Flitsmeister external launch audit

Checked **2026-10-02** against fetched origin/master and HEAD [8aa7a6e](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131). Implementation: `lib/src/maps/flitsmeister.dart`, `map_app.dart` capability defaults and Android package-targeted `ACTION_VIEW` launcher.

## Evidence boundary

No public Flitsmeister-owned deep-link/intent field specification was located in the official site or indexed searches for URL schemes/deep links. This is an evidence gap, not proof that no private or public protocol exists.

| Source | Date/version and evidentiary value |
| --- | --- |
| [Official website](https://www.flitsmeister.nl/) | Retrieved page metadata 2026-09-28. Advertises navigation, parking, warnings; no launch parameter schema. |
| [Official support](https://help.flitsmeister.com/) | Current support destination linked from the official site; use to obtain a supported integration contract. No specific protocol article was located. |
| [Vendor Play listing](https://play.google.com/store/apps/details?id=nl.flitsmeister) | Retrieved listing updated 2026-09-14. Establishes `nl.flitsmeister` and navigation product, not external launch fields. |
| [Vendor iOS listing](https://apps.apple.com/si/app/flitsmeister/id354936286) | Establishes that an iOS app exists. It does not establish its URL registration. No source version used as a protocol guarantee. |
| [Android common map intents](https://developer.android.com/guide/components/intents-common#Maps) | Current primary platform contract, unversioned. A generic display/search intent, not a dedicated Flitsmeister navigation API. |

No archived specification was used. No identified official deep-link reference could be classified as moved/dead; the documentation is **not located**, which is distinct from dead. The repository's iOS URL is implementation evidence only, not an independent vendor contract.

## Launch surface and missing contract details

| Action/field | Syntax, requiredness, values and limitations | Evidence |
| --- | --- | --- |
| Android coordinate display | `geo:latitude,longitude`, both decimal coordinates required in this form; `ACTION_VIEW`, no MIME type | [Android](https://developer.android.com/guide/components/intents-common#Maps) |
| Android labeled pin/search | `geo:0,0?q=lat,lon(label)` or `geo:0,0?q=address`; label/query text encoded, spaces `%20` or `+` | [Android](https://developer.android.com/guide/components/intents-common#Maps); **Flitsmeister acceptance not independently documented** |
| Android zoom | Optional `z`, integer 1…23 (1 whole Earth); no default stated | [Android](https://developer.android.com/guide/components/intents-common#Maps); not emitted, not confirmed for Flitsmeister |
| Repository directions | `geo:lat,lon`, package `nl.flitsmeister`; destination only | `Flitsmeister.directionsSchemeUrl`; generic intent has no “navigate now” instruction |
| Repository iOS branch | `flitsmeister://?geo=lat,lon`; required coordinate value in builder, query-encoded | `Flitsmeister.directionsSchemeUrl`/`markerSchemeUrl`; no current primary schema found |

Latitude precedes longitude. Geographic bounds are −90…90 and −180…180; GPS/WGS84 is the normal geo-URI expectation. App-specific validation, precision, alternate coordinate systems, default zoom, maximum labels/URL length and escaping of embedded parentheses are not established. No public app contract was found for origin, waypoints, travel modes, avoidance policies, alternative routes, navigation start/stop, callbacks, caller identity, authentication or integration licensing. Do not reinterpret the product's parking/toll features as externally callable actions. No SDK protocol was used to infer app support.

## Comparison and tests

* **Concrete capability mismatch:** inherits all travel modes as supported, but serializes none. The same `geo:` URI cannot express a requested walking, cycling or transit route.
* `supportsMarkerCoords=false` blocks marker requests, though a raw builder exists. This is a conservative library policy; the generic Android protocol can show locations but app-specific marker behavior remains unverified.
* Android directions are a location hand-off, **not proof of navigation**. Test actual UI behavior before promising turn-by-turn initiation.
* iOS App Store ID and detection scheme are null, so the library advertises Android-only despite the existing iOS product and iOS builder branch. This is an unimplemented integration, not evidence the iOS app does not exist. Add metadata only after independently testing scheme registration and destination handling.
* No universal links, text search or waypoints are advertised. Origin, title, zoom and modes are ignored. These are library limitations; no found dedicated protocol establishes additional supported fields.

Propose exact tests for `(52.090737,5.121420)` and a distinct origin `(51.924420,4.477733)`: assert Android `geo:52.090737,5.12142`, package targeting, and that unsupported explicit modes cannot pass capability filtering. Separately compare `geo:lat,lon`, `geo:0,0?q=lat,lon`, and a label containing `A & B + Café (West)` on-device; distinguish centering a map, selecting a destination, previewing a route and starting guidance. Test iOS detection versus raw URL generation rather than asserting only that a string contains `flitsmeister://`.

No Flitsmeister app was launched in this audit. Current Android/iOS versions, cold/warm starts, existing route replacement, login/subscription gates, GPS unavailable and label/query parsing remain device-verification gaps. Browser emulation would not verify native intent handling.
