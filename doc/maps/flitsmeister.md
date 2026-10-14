# Flitsmeister

## Current support

`Flitsmeister` is advertised as Android-only, targeting `nl.flitsmeister`. Directions hand off destination coordinates with `geo:lat,lon`; explicit origins, every explicit travel mode (including driving), and nonempty waypoints are rejected. Markers, search and universal URLs are disabled; title and zoom are not serialized. The geo URI does not express a routing mode or “navigate now” instruction.

See [provider](../../lib/src/maps/flitsmeister.dart) and [capabilities](../../lib/src/maps/map_app.dart). iOS detection scheme and App Store metadata are null, despite raw iOS builder branches using `flitsmeister://?geo=lat,lon`; those branches do not establish supported iOS discovery or dispatch.

Source check: **2026-10-02**. Native destination handling remains unverified.

## Sources

No public Flitsmeister deep-link specification was found. The Android formats below come from platform documentation, not a Flitsmeister integration guide.

| Source | Date and scope |
| --- | --- |
| [Official website](https://www.flitsmeister.nl/) | Retrieved page metadata 2026-09-28. Advertises navigation, parking, warnings; no launch parameter schema. |
| [Official support](https://help.flitsmeister.com/) | Current support destination linked from the official site; use to obtain a supported integration contract. No specific protocol article was located. |
| [Vendor Play listing](https://play.google.com/store/apps/details?id=nl.flitsmeister) | Retrieved listing updated 2026-09-14. Establishes `nl.flitsmeister` and navigation product, not external launch fields. |
| [Vendor iOS listing](https://apps.apple.com/si/app/flitsmeister/id354936286) | Establishes that an iOS app exists. It does not establish its URL registration. No source version used as a protocol guarantee. |
| [Android common map intents](https://developer.android.com/guide/components/intents-common#Maps) | Current primary platform contract, unversioned. A generic display/search intent, not a dedicated Flitsmeister navigation API. |

The iOS URL below comes from the plugin implementation; its acceptance by the app is unconfirmed.

## URL formats

| Action/field | Syntax, requiredness, values and limitations | Evidence |
| --- | --- | --- |
| Android coordinate display | `geo:latitude,longitude`, both decimal coordinates required in this form; `ACTION_VIEW`, no MIME type | [Android](https://developer.android.com/guide/components/intents-common#Maps) |
| Android labeled pin/search | `geo:0,0?q=lat,lon(label)` or `geo:0,0?q=address`; label/query text encoded, spaces `%20` or `+` | [Android](https://developer.android.com/guide/components/intents-common#Maps); **Flitsmeister acceptance not independently documented** |
| Android zoom | Optional `z`, integer 1…23 (1 whole Earth); no default stated | [Android](https://developer.android.com/guide/components/intents-common#Maps); not emitted, not confirmed for Flitsmeister |
| Repository directions | `geo:lat,lon`, package `nl.flitsmeister`; destination only | `Flitsmeister.directionsSchemeUrl`; generic intent has no “navigate now” instruction |
| Repository iOS branch | `flitsmeister://?geo=lat,lon`; required coordinate value in builder, query-encoded | `Flitsmeister.directionsSchemeUrl`/`markerSchemeUrl`; no current primary schema found |

Latitude precedes longitude. Geographic bounds are −90…90 and −180…180; GPS/WGS84 is the normal geo-URI expectation. App-specific validation, precision, alternate coordinate systems, default zoom, maximum labels/URL length and escaping of embedded parentheses are not established. No public app contract was found for origin, waypoints, travel modes, avoidance policies, alternative routes, navigation start/stop, callbacks, caller identity, authentication or integration licensing. Do not reinterpret the product's parking/toll features as externally callable actions. No SDK protocol was used to infer app support.

## Compatibility limits

The raw Android marker builder emits `geo:lat,lon?q=lat,lon`, but marker requests are disabled because Flitsmeister's display behavior is unverified. Android directions hand off a location without guaranteeing navigation. iOS scheme registration, route replacement, login/subscription requirements, missing-GPS behavior and label/query parsing need confirmation.
