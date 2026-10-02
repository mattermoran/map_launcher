# Sygic Truck external launch audit

Checked **2026-10-02** against fetched origin/master and HEAD [8aa7a6e](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131). Implementation: `lib/src/maps/sygic_truck.dart`; driving-only request tests in `test/requests/map_contracts_test.dart`.

## Product boundary and source availability

| Source | Status/version and permitted conclusion |
| --- | --- |
| [iOS Custom URL][ios] | Primary vendor page, no publication date or overall app version shown. Full cached content retrieved; forced live fetch returned **403**. Introduction explicitly says integration with **“Sygic Truck or Professional navigation.”** This is app-specific evidence despite its SDK documentation path. |
| [Android Custom URL][android] | Old www.sygic.com path and [enterprise-host counterpart](https://enterprise.sygic.com/developers/professional-navigation-sdk/android/api-examples/custom-url) returned **403**. Search index exposes `com.sygic.aura://coordinate` examples but not enough text to independently confirm the complete Android Truck surface. Access-blocked, not proven dead. |
| [Custom URL integration overview](https://enterprise.sygic.com/professional-gps-navigation-sdk/custom-url-integration) | Enterprise product overview; not a substitute for a platform/app compatibility matrix. |
| [Truck product](https://www.sygic.com/truck/) | Distinct from Sygic GPS Navigation consumer product and embedded Maps SDK. Product marketing alone does not establish URL parameters. |

No archive snapshot was used. Cached primary content is not a live verification of the shipping app. Enterprise-host search results suggest a parallel/moved documentation location, but live blocking prevents asserting a verified redirect/migration. Android parity is **unverified**, not inferred from iOS or embedded APIs.

**License:** the [iOS reference][ios] restricts Custom URL integration to **personal usage**; commercial usage requires contacting sales. An installed app or purchased navigation entitlement is not evidence of commercial integration permission. No API key/callback is required by the basic coordinate examples. Activation/login actions below are separate licensed administrative operations, not necessary fields on every route.

## Published app custom-URL action inventory

All rows in this section come from the [iOS Custom URL table][ios]. Prefix `com.sygic.aura://`; following positions are separated by literal `|` in the reference (escaped below only for Markdown). Unless specified, the reference provides a positional grammar but no formal optionality/default table: preserve positions, do not invent omitted-field semantics. No generic URL-length cap or waypoint-count cap is stated.

| Action | Positional fields / accepted values | Semantics and constraints |
| --- | --- | --- |
| `search` | `searched address`, optional final `drive` | Search address/place; adding `drive` searches and drives. Text encoded. |
| `address` | `country or country ISO code\|city\|postal\|street\|house number\|type` | `type=show`, `drive`, `walk`; example country `SVK`. Table's `com.sygic.aura/address` is inconsistent with its valid `com.sygic.aura://address` examples. |
| `coordinate` | `lon\|lat\|type` | Decimal **longitude then latitude**; `type=show`, `drive`, `walk`. No explicit coordinate datum, range validation or default type given. |
| `coordinateaddr` | `lon\|lat\|address_description\|type` | Labeled coordinate; documented example ends `drive`. Do not assume other types without testing. |
| `route` | Local `file` | Loads itinerary in SIF or JSON; file access/location contract not stated here. Not inline `via` parameters. |
| `route_download` | `url\|type` | Downloads/loads itinerary. `type=sif` (Sygic itinerary/precomputed route), `json` (PTV JSON), `bcr` (PTV BCR). No schema/stop limits in this page. |
| `url` | `webpage` | Opens web page inside navigation. |
| `activate` | `productCode` | Activates license. |
| `login` | `username\|password` | Starts app and logs in. Never log/store credential-bearing URLs in diagnostics. |
| `update` | `map` code or `all` | Example `fra`; starts download immediately; old maps removed on restart, temporary double storage can exhaust space. No code registry linked here. |
| `mysygic` | None | Product shop. |
| `mysygicbuy` | `productId` | Buy specified product; example numeric ID, no formal type/range. |
| `truckSettings` | `key=value&key=value…` | Vehicle profile settings below; **13.6.0+**. |
| `back_button` | Application identifier | Defines back-button behavior. iOS page oddly uses Android package `com.android.chrome`; current iOS return mechanism needs verification. Not an arrival callback contract. |
| `deviceCode` | None | Gets device code; response transport unspecified. |
| `hud` | `none`, `normal`, `inverted` | `none` restores standard navigation display. |
| `activate` (remote overload) | `SDpassword\|ProductID\|Period\|Description` | Consult Sygic support for password, product and period; units/limits unspecified. |
| `setLanguage` | `ISO\|Type\|VoicePack` | `Type=Lang/Voice/LangVoice`; `VoicePack=NormalMale/NormalFemale/TTS`. Voice pack ignored for `Lang`; non-TTS packs must be downloaded or no change. Source calls ISO “639-1” but example is locale `en-GB`; clarify accepted locale inventory. |
| Multiple actions | Join commands with `&&&` | Example `com.sygic.aura://login\|username\|password&&&back_button\|package`; failure/atomicity/order guarantees unspecified. |

Geographic bounds normally are lon −180…180, lat −90…90; source examples are signed decimal GPS-like coordinates. **WGS84 is not explicitly named by this page**, nor is clamping, rounding, precision or invalid-coordinate handling. No coordinate-origin field is listed: coordinate navigation targets a destination. Imported itineraries are a different route surface with separately defined formats; they are not proof of inline waypoint or arbitrary origin support.

### Truck settings fields

All fields appear in the [primary table][ios]; send selected `key=value` entries after `truckSettings|`. Required combinations, numeric minima/maxima, omitted-field persistence and most defaults are **not specified**. These are routing-profile changes, not the generic library's travel modes.

| Key | Type / units / accepted values |
| --- | --- |
| `mxs` | Numeric maximum speed, km/h |
| `wei` | Numeric total weight, kg |
| `axl` versus `axw` | **Source inconsistency:** key column says `axl`, examples say `axw`; maximum axle weight, kg. Do not choose a key without vendor/device verification. |
| `len`, `wid`, `hei` | Numeric length/width/height, millimetres |
| `rou` | `car`, `tru` (truck), `cmp` (camper), `van` |
| `general`, `water` | `1` enable respective hazardous-material setting; `0` clear |
| `hClass` | US hazmat `1,2,3,4,5,6,7,8,9,I`; combinations allowed as concatenated values (example `148`); `0` clears |
| `adr` | One of `B,C,D,E`, not combinations; `0` clears |
| `profile` | Profile identifier to modify and activate; default **1**; range unspecified |
| `emiss` | Emission category `1…6` |
| `year` | Production year, e.g. `2017`; bounds unspecified |

### Encoding and excluded consumer endpoints

The [reference][ios] requires percent-encoding the parameter string in most environments, including spaces and reserved characters; its own example changes `route_download|http://…/my route.sif` to `route_download%7Chttp%3A%2F%2F…%2Fmy%20route.sif`. The page also shows raw-pipe HTML examples. Test the actual iOS/Android hand-off rather than assuming either raw or whole-parameter encoding is universally accepted. The current builder joins raw pipes and passes an empty query map, so `buildUrl` returns them unchanged; it does not encode this command body.

The same page's `https://go.sygic.com/` section is explicitly **consumer Sygic GPS Navigation only**: `/search` (`q`, optional `center`), `/directions` (`to`, optional `from`, repeated `via[]`, `mode=car/walk/van`), `/place` (`q` or `coordinates`), `/store` (`product`/`productId`), `/web` (`url`), `/sign-in`, `/manage-maps`, `/travel-insurance`, `/ev`. These are cataloged to prevent product confusion, **not offered as Truck actions**. In particular, do not add consumer `via[]` or universal-link capability to Truck on this evidence. Truck's cached custom-URL reference supplies no general avoid-tolls/highways/ferries parameter or bicycling/transit mode.

## Implementation comparison and driving-only fix

* Current directions always emit `com.sygic.aura://coordinate|longitude|latitude|drive`, ignoring origin, waypoints and labels. Coordinate order agrees with the primary examples.
* **Driving-only filtering is correct for the current serializer:** a walking request must not silently produce `drive`. Existing tests establish that restriction through URL generation, discovery and dispatch.
* **It is not a complete statement of the documented Truck contract:** the iOS introduction names Truck explicitly, and its table lists `walk` and `show`. Walking and marker display are documented implementation gaps on iOS, subject to stale-source/current-app and licensing verification—not proof that Truck only supports driving. Android parity remains unknown.
* `supportsMarkerCoords=false` blocks a raw marker builder that already emits `…|show`; document this policy instead of claiming the URL protocol lacks marker display. All search and waypoint flags false; no universal URL. Direct raw methods still emit drive even with non-driving arguments; public request filtering provides the protection.
* `coordinateaddr`, address/search launch and route imports are unimplemented options. `truckSettings` would alter persistent vehicle configuration and should not be hidden behind generic route mode selection. Zoom unsupported by the documented coordinate grammar.
* iOS uses `com.sygic.aura://`, Android targets `com.sygic.truck`. Shared scheme collision with other Sygic installations is a device question; scheme presence alone does not identify the selected product on iOS.

## Discriminating tests and device gaps

Use destination `(-33.856784,151.215297)` so a swapped pair has an invalid latitude. Assert exact `coordinate|151.215297|-33.856784|drive`, no accidental query `?`, and explicit non-driving rejection for the current implementation on **both** platforms. Distinguish null/default mode from explicit walking. For a future walking implementation, assert final `walk`, never a passing capability test with unchanged `drive`.

On licensed current iOS Truck test `show`, `drive`, `walk` separately and record selected screen/mode, not merely successful app opening. Repeat on Android rather than assuming parity. Compare raw/encoded pipes, a `coordinateaddr` label `A & B + Café`, cold/warm start, no GPS, active itinerary and multiple Sygic apps installed. Test imported route permissions and limits independently; do not activate, buy, log in or change truck settings as harmless launch probes.

No native app was executed. Current `walk`/`show` acceptance, scheme collisions, Android action inventory, raw-pipe handling, actual guidance initiation and commercial integration permission remain unresolved. These docs make no application changes.

[ios]: https://www.sygic.com/developers/professional-navigation-sdk/ios/custom-url
[android]: https://www.sygic.com/developers/professional-navigation-sdk/android/api-examples/custom-url
