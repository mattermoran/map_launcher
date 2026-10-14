# DB Navigator

**Not included in map_launcher.** Requested in [issue #111](https://github.com/mattermoran/map_launcher/issues/111). The available primary sources establish journey sharing and app associations, not a public coordinate-to-journey builder.

Source check: **2026-10-02**. Native acceptance remains unverified.

**Do not implement the old `dbnavigator://query` recipe as if it were a current, cross-platform contract.** Current first-party evidence establishes consumer sharing and HTTPS app associations, but not a public coordinate-to-journey construction API. DB Navigator is a rail/transit journey planner and ticketing app, not a generic marker/driving-navigation target.

## Sources and confidence

| Source | Date/version / what it establishes |
| --- | --- |
| [Current DB Navigator product/help page](https://www.bahn.de/service/mobile/db-navigator) and [English equivalent](https://int.bahn.de/en/booking-information/db-navigator) | Primary, undated. “Reise teilen” / “Share your journey”: app generates a link opening the journey on bahn.de or in installed Navigator; QR sharing and iPhone AirDrop also described. No field-level link specification. |
| [Connection search](https://www.bahn.de/service/mobile/db-navigator/verbindungssuche) | Primary, undated; describes in-app dates, origin/destination, arrival/departure, class/travellers and transit. These are **UI controls**, not documented URL fields. |
| [www.bahn.de iOS association](https://www.bahn.de/.well-known/apple-app-site-association), [international iOS association](https://int.bahn.de/.well-known/apple-app-site-association), [Android association](https://www.bahn.de/.well-known/assetlinks.json) | Primary machine-readable configuration fetched 2026-10-02. Establishes associated app identities and iOS paths, not parameter semantics or runtime acceptance. No version/publication date. |
| [Digital subscription link help](https://www.bahn.de/faq/abo-im-navigator-nutzen) | Primary. Confirmation-mail order status feature explicitly requires Navigator **25.23.0+**. A private order workflow, not arbitrary navigation. |
| [Special Terms of Use](https://int.bahn.de/en/terms-of-use/besondere-nutzungsbedingungen-db-navigator) | Primary, last updated **September 2025**. Some bookings require a customer account. |
| [DB developer documentation](https://developer-docs.deutschebahn.com/doku) | Accessible public landing page for APIs/data streams; did not provide a Navigator launch-parameter specification. No claim that no private contract exists. |
| [Karte legacy implementation](https://github.com/kiliankoe/Karte/blob/1a3912449774a065eb4017198cdadd4336a51e5a/Sources/App.swift#L162-L173) | **Secondary-only**, iOS implementation added [2018-07-26](https://github.com/kiliankoe/Karte/commit/1a3912449774a065eb4017198cdadd4336a51e5a). Issue #111 links Karte, not DB documentation. |
| [generate-db-journey-url source](https://github.com/WahrscheinlichAnkommen/generate-db-journey-url/blob/a1efba8451962f0e45d825a0053afbc8464c1748/src/utils/generate-db-journey-url.js) | **Secondary-only**, pinned repository revision dated **2024-05-20**. Shows newer HTTPS sharing with a server-issued `vbid`, not legacy coordinate launching. Neither supported API status nor current operation is established. |

The former www.bahn.de paths `/service/ueber-uns/verlinkung` and `/service/informationen-buchung/anreise` returned HTTP 404. No current first-party field-level Navigator linking guide was available; this blocks a supported builder, not all possible deep links.

## Current consumer actions and platform associations

Source: [official consumer guide](https://www.bahn.de/service/mobile/db-navigator), [subscription FAQ](https://www.bahn.de/faq/abo-im-navigator-nutzen), and association files linked in the table. There is no published required/optional query schema for these paths in the inspected sources.

| Action / path | Established behavior versus inference |
| --- | --- |
| Share a journey | Consumer guide: obtain a link from journey details' share menu; recipient can view on website or installed app. Treat a generated link as opaque. This does not authorize constructing arbitrary station/date/coordinate fields. |
| `https://www.bahn.de/buchung/start` | Exact iOS-associated path. Booking/journey entry purpose inferred from path and secondary sharing source; required query fields not specified in association file. |
| `https://int.bahn.de/en/buchung/start` | Exact international iOS-associated booking path. Do not assume every language path is associated merely because a website accepts it. |
| `/app/ticket`, `/link_auftragdetails` on www.bahn.de | iOS-associated paths; ticket/order purpose inferred from names. No public field schema, token lifespan or permission contract found. Never place real ticket/order data in research examples. |
| `/link_umgebung` on www.bahn.de | iOS-associated path; nearby purpose inferred from German name. **No coordinate/zoom/stop field schema found**; cannot claim a usable marker API. |
| `/buchung/kundenkonto/vorteile`, `/buchung/upgrade` on www.bahn.de | iOS-associated paths; account benefits/upgrade purposes inferred. Also `/en/buchung/kundenkonto/vorteile` and `/en/buchung/upgrade` on int.bahn.de. Not general transit routing actions. |
| `/jumpback` on both domains | iOS-associated path; no public caller callback or arbitrary redirect contract. Do not invent a `returnurl` parameter. |
| `/navigator/login/success`, `/navigator/login/back` on www.bahn.de | iOS-associated login paths. These are not evidence for a general x-callback-url interface. Authentication flow fields are not documented for third-party construction. |
| `/abo/tarifaenderung` on www.bahn.de | iOS-associated path; subscription tariff-change purpose inferred. No public payload schema. |
| Subscription email/order-status link | Official FAQ permits opening a vendor-generated confirmation/activation link; order-status display available since 25.23.0. URL shape, fields, token expiry and authentication requirements not published there. |

The complete observed www.bahn.de iOS path list is in the table above (10 paths). App identity is `U8FMZM594X.com.deutschebahn.navigator`. The international file has four English/unprefixed paths (`/en/buchung/start`, `/en/buchung/kundenkonto/vorteile`, `/en/buchung/upgrade`, `/jumpback`) associated with both that identity and `U8FMZM594X.com.deutschebahn.vendigator`; the latter's role cannot be inferred solely from this file.

The [Android assetlinks file](https://www.bahn.de/.well-known/assetlinks.json) delegates `common.handle_all_urls` to `de.hafas.android.db` and `de.hafas.android.db.huawei`. This file supplies no Android route/query schema; matching intent filters in installed versions and OS link preferences still govern launch. The [official product page](https://www.bahn.de/service/mobile/db-navigator) links Android `de.hafas.android.db`, App Store ID `343555245`, and a Huawei version with reduced features. Do not assume Huawei parity or copy legacy iOS schemes into Android detection without testing.

## Newer HTTPS share format: secondary evidence, not a public API

Source for every field below: [pinned 2024 generate-db-journey-url implementation](https://github.com/WahrscheinlichAnkommen/generate-db-journey-url/blob/a1efba8451962f0e45d825a0053afbc8464c1748/src/utils/generate-db-journey-url.js). Backend operation is unverified.

| Surface / field | Observed construction / limits |
| --- | --- |
| Final consumer URL | `https://www.bahn.de/buchung/start?vbid=<id>` or `https://int.bahn.de/<locale>/buchung/start?vbid=<id>`. Only query key this package emits is `vbid`. |
| `vbid` | Server response field, passed through `URLSearchParams`; opaque journey-share identifier. Not a coordinate, stop/EVA ID or HAFAS reconstruction token. Length, format, expiry, authentication and portability are undocumented. |
| Locale | Package defaults `lang` argument to `en`; `de` selects www.bahn.de, `cs`, `da`, `en`, `es`, `fr`, `it`, `nl` select international paths. Code comments also claim `pl`, but the actual whitelist omits it. This is a library discrepancy, **not a DB language contract**. |
| Server request | Package POSTs JSON to `https://int.bahn.de/web/api/angebote/verbindung/teilen`. This is backend interaction, not an app-launch URL, and no supported public API/access guarantee was found. |
| `hinfahrtDatum` | POST payload string: ISO timestamp derived from a 12-digit `YYYYMMDDHHmm` component of the reconstruction token, interpreted in `Europe/Berlin` then converted to UTC. This is the package's interpretation, not a documented vendor date rule. |
| `hinfahrtRecon` | POST payload containing the entire HAFAS `refreshToken`/`ctxRecon` input. Obtaining/reconstructing one requires journey data; coordinates alone are insufficient. |
| `startOrt`, `zielOrt` | POST payload strings, first/last station name extracted from token `@O=...@` segments. Not independently documented URL origin/destination parameters. |

The sample token in that package includes HAFAS-like `@L=8011160@` and `@L=8000105@` station identifiers, `@O=` names, timestamps and service text. This is a historical data representation; it is **not** a published scheme where callers can supply arbitrary `L`, `O` or train numbers as public query fields. Encoding, validity, ordering and renewal of tokens are backend concerns and unverified. A thin URL-only plugin should not acquire a network/private-API dependency merely to manufacture `vbid` links.

## Legacy Navigator protocol: complete observed Karte field inventory

**Secondary-only and historical iOS evidence.** [Karte builder](https://github.com/kiliankoe/Karte/blob/1a3912449774a065eb4017198cdadd4336a51e5a/Sources/App.swift#L162-L173), [coordinate representation](https://github.com/kiliankoe/Karte/blob/1a3912449774a065eb4017198cdadd4336a51e5a/Sources/Location.swift), [query encoding helper](https://github.com/kiliankoe/Karte/blob/1a3912449774a065eb4017198cdadd4336a51e5a/Sources/Extensions.swift). Added 2018-07-26, before the newer share implementation above. Not confirmed supported or confirmed removed in current Navigator.

Form: `dbnavigator://query?<fields>&start`. This is not `google.navigation:`, not an Android `intent://` URL and not the current HTTPS booking route.

| Field | What Karte emits | Requiredness/default evidence |
| --- | --- | --- |
| `ZKOORD` | Literal `1` for coordinate destination | Always emitted by builder; alternative values not documented. |
| `ZX` | Integer longitude × 1,000,000 | Always emitted for destination. Swift `Int` truncates toward zero. |
| `ZY` | Integer latitude × 1,000,000 | Always emitted for destination. **X is longitude, Y latitude**, unlike the common lat,lon pair. |
| `ZNAME` | Destination name string | Omitted when name is nil. Name-only routing/default label not established. |
| `SKOORD` | Literal `1` for coordinate origin | Emitted only if origin exists. No vendor default documented. |
| `SX` | Integer origin longitude × 1,000,000 | Only if origin supplied. |
| `SY` | Integer origin latitude × 1,000,000 | Only if origin supplied. |
| `SNAME` | Origin name string | Only if origin/name supplied. |
| `start` | Valueless trailing flag, `&start` | Always appended; intended search launch is inferred from builder/action. Not the string `start=true`. |

Karte percent-encodes with Foundation `.urlQueryAllowed` and sorts fields. That is historical implementation behavior, not proof that unescaped `&` in a name is safe. Coordinate scale is observable; CRS is not declared (**WGS84 inferred**). No vendor numeric range/precision/rounding guarantee found. Do not transplant the microdegree fields into current HTTPS URLs or assume a current app geolocates the origin when the `S*` fields are absent.

For evaluating the old recipe only, a latitude/longitude pair `(52.525084,13.369402)` becomes `ZY=52525084&ZX=13369402`; a negative longitude `-0.1429279` truncates to `-142927` in Karte. These are independently calculated serialization expectations, not tested app inputs.

No primary source was found for legacy station-ID fields, dates, modes, class, passengers, return trips, callbacks, waypoint syntax, coordinate bounds, default origin, app-version cutoff, Android parity or partner requirements. Do not fill those gaps from generic HAFAS CGI parameters or from similarly named DB products.

## Consumer, partner, data API and authentication boundaries

The [Google/DB partnership announcement](https://www.deutschebahn.com/en/Google-and-DB-show-live-train-information-7243254) describes transferring a selected connection into DB booking without retyping the journey. It supplies **no public URL-field contract**. Partner integration availability is not evidence that arbitrary callers can build those requests.

The [DB developer portal](https://developer-docs.deutschebahn.com/doku) concerns APIs/data streams; stop data, timetable REST parameters and authentication there must not be reclassified as Navigator launch inputs. The secondary share implementation's JSON payload likewise must not become deep-link query fields. Ticket buying, booking management, login and Komfort Check-in are separate workflows: [Navigator terms](https://int.bahn.de/en/terms-of-use/besondere-nutzungsbedingungen-db-navigator) say some offers require an account. A public journey-sharing link does not imply permission to book, access another person's tickets or bypass account controls.

No public x-callback-url, caller-specified return URL, automatic purchase, arbitrary map-marker or driving-navigation action was established. Association entries for login and jump-back endpoints do not change that conclusion.

## Integration constraints

A coordinate-based provider requires a current supported construction contract. Forwarding a vendor-generated HTTPS journey link as an opaque URL is a narrower operation and does not implement `directions(destination: coordinates)`. Legacy custom-scheme support, `/link_umgebung` fields, link lifetime, dates/timezones, platform versions and partner requirements remain unknown. Do not construct speculative ticket/login fields or automatically invoke the sharing backend.

Association files establish eligibility for dispatch, not actual dispatch or journey retention; Android link preferences and iOS same-domain browsing can affect handoff. DB journey semantics are transit-specific and must not silently stand in for driving navigation.
