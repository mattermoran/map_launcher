# Transit App external launch contract

Checked **2026-10-02**. Requested in [issue #111](https://github.com/mattermoran/map_launcher/issues/111), not implemented in the inspected repository. Fetched `origin/master`; it and `HEAD` match [8aa7a6e1152a80c4482003bdfaad8f850bdb6131](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131). Research only, **runtime-unverified** on Android and iOS.

## Current primary documentation exists

| Source | Date/version and scope |
| --- | --- |
| [Transit APIs, “Transit's URL scheme”](https://transitapp.com/apis) | Primary, retrieved in full. Page extraction reports published **2026-09-30 12:16 UTC**; this is page metadata, not a new protocol version. Explicit compatibility note: query strings supported in **Transit 2.0+**. |
| [Former developer path](https://transitapp.com/developers) | Resolves to the same API page. The issue's historical Karte reference is not the only available evidence. |
| [Link to Transit with Deeplinks and Smart Banners](https://resources.transitapp.com/article/448-deeplink-to-transit-from-other-apps) | Primary partner help, last updated **2022-09-15**; offers setup help through partner contact. Does not replace the publicly published scheme table with a partner-only API. |
| [Smart banner instructions](https://transitapp.com/smartbanners/how) | Primary, undated; confirms Android/iPhone store destinations and app identifiers. Banner is install promotion, not a route deep link. |
| [REST reference](https://api-doc.transitapp.com/) | Primary **v4.0.0 stable**, OpenAPI 3.1.0; legacy v3 linked separately. Authenticated data API, not URL-scheme parameters. |
| [On-Demand Transit API Guidelines](https://resources.transitapp.com/article/397-on-demand-transit-api-guidelines) | Primary partner integration, updated **2025-11-27**; specifies links *out of Transit into a partner app*, not extra fields accepted by Transit. |

## Every published public launch action and field

Source for all rows: [official API page's URL-scheme section](https://transitapp.com/apis). No dedicated Android intent-extra contract or HTTPS equivalent is supplied in that section.

| Action | Form | Purpose |
| --- | --- | --- |
| Directions | `transit://directions?from=<location>&to=<location>` | Get transit directions between two locations. Not a promise to start GO or turn-by-turn guidance immediately. |
| Nearby lines | `transit://routes?q=<location>` | Fetch nearby transit routes for the location. Not an arbitrary marker pin, stop-departure board by ID, or geographical search-results API. |

| Field | Requiredness / type | Syntax, defaults, constraints |
| --- | --- | --- |
| `from` | Optional; coordinate pair or location string | Origin, decimal `latitude,longitude` or text. Omitted parameter uses user's current location. |
| `to` | Optional in vendor contract; needed for a chosen destination | Destination with the same forms. The note “Leaving out a parameter will use the user's current location” applies in directions section; do not assume a missing destination is invalid simply because the library API requires one. |
| `q` | Location pair or string; requiredness not explicitly stated | Nearby reference example `45.5391,-73.5997`. Missing-`q` default is not explicitly specified; the current-location note is under directions, not nearby. |

Official examples:

```text
transit://directions?from=Berri-UQAM&to=8194%20Drolet
transit://routes?q=45.5391,-73.5997
```

Coordinates are latitude first, longitude second with a comma. Decimal degrees are demonstrated; **WGS84 is inferred**, not named. No numeric range, precision, string length or URL-length limit is published. A future use of `LocationCoords` would inherit finite latitude −90…90 and longitude −180…180 as library-side validation, not vendor limits.

Address geocoding is explicitly biased by the user's current location. A text like `Berri-UQAM` is a location string, **not a documented station ID**. Ambiguous names may resolve differently in another city; use coordinates for deterministic endpoints when possible. The reference provides no separate labels or address-display metadata, nor a syntax for combining a name and coordinates in one value.

Encode each query value once using UTF-8 percent encoding. The official text example encodes a space as `%20`; commas may be percent-encoded as data. Escape `&`, `+`, `#`, `?` and `%` in input strings. The source does not specify whether a literal `+` decodes to space. Do not copy Karte's less restrictive historical Foundation encoding as a complete escaping contract.

### Not documented by this interface

| Category | Status in [primary URL-scheme reference](https://transitapp.com/apis) |
| --- | --- |
| Origin/destination beyond two endpoints | No via points, waypoint arrays, intermediate-stop dwell times or multiple destinations. |
| Modes | No external mode parameter; action is transit directions. The app's multimodal capabilities do not establish an externally selectable driving/cycling/walking option. |
| Times | No date, departure/arrival time, timezone, timetable horizon or arrive-by fields. Defaults beyond current-location omission are not stated. |
| IDs | No public line, stop, trip, GTFS feed, agency or place-ID input. REST IDs are not documented as interchangeable with location strings. |
| Display/navigation | No zoom, map style, marker label, automatic GO, navigation stop, ticket purchase or ride-booking action. |
| Authentication/callbacks | No key, signature, partner ID, callback, x-callback-url or return URL in the scheme reference. No enrollment prerequisite is stated for these two actions. |
| Platform differences | Reference is not partitioned by OS; no Android-specific URL form or declared minimum Android/iOS OS version. Query-string requirement is app version 2.0+, not iOS 2.0. |

## Do not mix public links, REST, partner handoffs and banners

| Interface | Contract boundary and source |
| --- | --- |
| Public scheme | Two actions above, no documented credentials. Native app must be installed to handle `transit://`; exact OS behavior needs device tests. |
| REST APIs | [Current stable v4 reference](https://api-doc.transitapp.com/) uses server `https://external.transitapp.com` and an `apiKey` authentication scheme. The [API overview](https://transitapp.com/apis) advertises access-key signup, five calls/minute and 1,500 calls/month free. Those quotas and keys apply to HTTP data calls, not launching the app. Walking speed, accessibility, multimodal route products and data identifiers must not be transplanted into scheme queries. |
| On-demand partner integration | [Guidelines](https://resources.transitapp.com/article/397-on-demand-transit-api-guidelines) ask partners to accept origin, destination and product ID in the partner's own link, supply GOFS, optional wait-time API keys, staging/production endpoints, test apps and technical contact. This is **the opposite direction** from `map_launcher` opening Transit. No evidence that `product_id` is a Transit consumer launch parameter. |
| Partner support | [2022 help article](https://resources.transitapp.com/article/448-deeplink-to-transit-from-other-apps) invites agencies to contact `partners@transitapp.com` for setup. Public documented scheme remains independently visible; bespoke agency features require agreement/documentation. |
| Smart banner | [Instructions](https://transitapp.com/smartbanners/how) send iPhone users to `https://apps.apple.com/app/apple-store/id498151501?pt=2090552&ct=AGENCY-smartbanner&mt=8`, Android to `https://play.google.com/store/apps/details?id=com.thetransitapp.droid&utm_source=AGENCY&utm_medium=smartbanner&utm_campaign=partners`. `AGENCY` is an abbreviation without spaces/symbols; `pt`, `ct`, `mt`, `utm_*` are store/campaign attribution, not route fields. No deferred route retention promised. |

The banner's HTML `smartbanner:*` title, author, price, icon, button and enabled-platforms metadata configures a website widget, not a native launch action. No reason to add it to a map URL builder.

## Historical evidence and repository readiness

[Karte's iOS implementation](https://github.com/kiliankoe/Karte/blob/1a3912449774a065eb4017198cdadd4336a51e5a/Sources/App.swift#L132-L135) uses `transit://directions`, `from=lat,lon` (optional origin) and `to=lat,lon`. Its [original implementation commit](https://github.com/kiliankoe/Karte/commit/9987eaf015d8774676a30f865e756481f5020d50) is dated **2017-04-15**. This is secondary historical iOS evidence; the current primary guide now supports the basic syntax directly. Karte's tests do not validate present app behavior or Android support.

No Transit `MapApp`, registry entry, exported class, icon, Android visibility entry, example iOS query entry or app-specific tests exist at the baseline. Generic URL and location helpers exist, but support is **not implemented**.

**Assessment:** feasible candidate for a narrow transit-directions integration, contingent on mobile validation. Coordinate and text directions have primary documentation; nearby transit could be a separately described action or best-effort fallback, not `supportsMarkerCoords=true` by default. Android package is `com.thetransitapp.droid`, iOS store ID `498151501`; those are confirmed by official banner links. `transit` is the documented query scheme, but platform detection/dispatch still need verification. Do not advertise a universal HTTPS route URL, all travel modes, labels, time controls or waypoints.

## Concrete tests and remaining blockers

1. Device-test `transit://directions?to=45.5391%2C-73.5997`, then a different explicit origin `45.5048,-73.5607`. Confirm endpoints are not swapped and explicit origin wins over GPS on Android and iOS.
2. Test coordinate/text mixtures, Unicode, `Café & Tea + #1`, and empty-value omission. For an ambiguous location string, compare behavior in Montreal and outside its vicinity; distinguish successful URL parsing from correct geocoding.
3. Separately test missing `from`, missing `to`, both absent, and missing nearby `q`, with location permission granted/denied. Only directions' omitted-endpoint behavior is documented.
4. Verify nearby opens transit routes rather than a titled pin; no zoom/label guarantee. Verify directions does not silently claim driving mode or automatic GO.
5. Record app/OS versions, package discovery, query-scheme visibility and scheme dispatch. Test installed, uninstalled and unsupported-city cases and an explicit store fallback. Do not infer Android parity from old iOS Karte code.
6. Before implementation, decide how unsupported modes/waypoints are rejected or represented in capabilities, and whether nearby warrants a generic marker fallback. No new public API is justified solely by the app's unrelated REST features.

The primary sources were accessible; no native device tests were performed. No speculative integration was implemented.
