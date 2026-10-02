# Moovit external launch contract

Checked **2026-10-02**. Existing integration. Fetched `origin/master` and verified it and `HEAD` at [8aa7a6e1152a80c4482003bdfaad8f850bdb6131](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131). All app-launch behavior is **runtime-unverified**; this document changes no implementation.

## Primary sources and access limits

| Source | Date/version and scope |
| --- | --- |
| [Deeplinking](https://moovit.com/developers/deeplinking/) | Accessible in full; no publication/version date displayed. Contains a 2019-04-01 date example and legacy OS sample code; that example is not the documentation's release date. Primary native launch reference. |
| [Developer overview](https://moovit.com/developers/) | Separates mobile deeplinking, website links and embedded widget. Undated. |
| [Text Links & Buttons](https://moovit.com/developers/links/) | Accessible; undated. Markdown extraction omits part of the example, so HTML was also inspected to recover the full href. |
| [Old developer host](https://www.developers.moovit.com/) | Linked from the current guide but connection failed on this check. Not necessary for the tables transcribed from the working guide. |
| [Widget reference](https://moovit.com/developers/widgets/) | Returned general Moovit homepage content, not the promised widget specification. Widget configuration is not verified. |
| [Public Transit APIs](https://moovit.com/maas-solutions/transit-apis/) | Primary commercial API overview, undated; volume-metered trip-plan, nearby, stops, lines, real-time and service-alert APIs, with sales contact. Not the consumer-app URL contract. |

## Native actions and all published parameters

Source for both tables: [Moovit Deeplinking, “Opening Moovit with Schemes”](https://moovit.com/developers/deeplinking/). Same schemes are shown for Android and iOS.

| Action | Form | User-visible meaning |
| --- | --- | --- |
| Nearby lines and stations | `moovit://nearby?lat=<float>&lon=<float>&partner_id=<app-name>` | Map centered on the supplied location with nearby transit; without coordinates uses current location. Not a general-purpose arbitrary titled marker API. |
| Get directions | `moovit://directions?dest_lat=<float>&dest_lon=<float>&dest_name=<label>&orig_lat=<float>&orig_lon=<float>&orig_name=<label>&date=<ISO8601>&partner_id=<app-name>` | Suggested transit routes from one origin to one destination. `auto_run` is additionally documented in the parameter table/example despite being absent from the guide's structure line. |

| Field / action | Type / requiredness | Values and default behavior |
| --- | --- | --- |
| `lat`, `lon` / nearby | Optional floats | Latitude and longitude separately. Guide says absent values use user's location; behavior with only one coordinate present is unspecified. Pass both or neither. |
| `orig_lat`, `orig_lon` / directions | Optional floats | Origin latitude and longitude; absent values use user's location. Pair consistency and location-permission errors unspecified. |
| `dest_lat`, `dest_lon` / directions | Optional according to guide; needed for a specified destination | Destination latitude and longitude; guide explicitly says user's location if not provided. Do not rewrite this as a vendor-required pair merely because the library requires destination coordinates. |
| `orig_name`, `dest_name` / directions | Optional strings | Display labels; absent label shows lat/lon. Not address search or place IDs. No maximum length given. |
| `auto_run` / directions | Boolean; no required flag stated | `false`: preview and user must tap “Search”; example uses `true`. Default when absent, and acceptance of `0`/`1`, are not specified. Do not infer automatic turn-by-turn navigation from automatic search. |
| `date` / directions | Date string; no required flag stated | ISO 8601, described as `yyyy-MM-ddTHH:mm:ssZ`; example is `2019-04-01T18:30:00+02:00`. Omission default, departure-versus-arrival meaning, supported horizon and timezone/DST rules are not defined. No separate arrive-by field. |
| `partner_id` / both | String; requiredness ambiguous | “Your app's name (for tracking purposes).” Included in every canonical structure/example, but not explicitly marked mandatory; neither an API secret nor a documented issued credential. No default, character set, maximum length or registration requirement stated. Confirm omission policy rather than asserting it is required or harmless. |

Coordinates are separate decimal floats, latitude then longitude by field name. **WGS84 is inferred**, not explicitly named; precision, ranges and truncation rules are absent. Library `LocationCoords` separately enforces finite latitude −90…90, longitude −180…180.

Percent-encode values once as UTF-8. The guide uses `%20` for spaces. Its unescaped `+02:00` date example is potentially ambiguous to form decoders; encode the plus as `%2B`, not a space. This is an encoding recommendation, not evidence that a particular Moovit parser mishandles the literal plus.

Example derived from the documented fields, **not executed**:

```text
moovit://directions?dest_lat=40.758896&dest_lon=-73.985130&dest_name=Times%20Square&orig_lat=40.735845&orig_lon=-73.990512&orig_name=Union%20Square&auto_run=false&date=2026-10-05T18%3A30%3A00%2B02%3A00&partner_id=example
```

No public deep-link fields are documented for transport-mode selection, wheelchair preferences, waypoints, zoom, line/stop IDs, ticket purchase, caller callbacks, x-callback-url, API authentication or a return URL. Stops/lines in the commercial REST product are not usable as consumer deep-link fields without a separate contract. The app is a transit journey planner, not a generic driving-navigation target.

## Website, installation and partner links

Sources beside each contract: [Text Links & Buttons](https://moovit.com/developers/links/) and [native guide, “Download Link” / “Marketing / Email Campaign”](https://moovit.com/developers/deeplinking/).

| Form / field | Meaning / limitations |
| --- | --- |
| `https://moovit.com/?to=Madison%20Square%20Park&tll=40.742191_-73.98803&metroId=121&lang=en` | Full sample href recovered from official Text Links HTML. Web directions to a location; documentation says search in “To”, leave “From” empty, and **copy URL as is without modifying it**. Not a promise of universal-link app handoff. |
| `to` | Display address string in the web link; no formal requiredness, length or default specified. |
| `tll` | `<latitude>_<longitude>` in the sample (underscore, not comma). Decimal coordinates; reference labels it `<LAT_LON>`, without formal CRS/range/precision constraints. |
| `metroId` | Metro identifier; sample `121`. No complete ID registry, resolution algorithm or default documented here. Not a stop ID. |
| `lang` | Language code, sample `en`; full accepted values and default absent. |
| `https://moovit.onelink.me/3986059930?pid=Developers&c=<YOUR_APP_NAME>` | Documented install link redirects to App Store / Google Play. `pid` shown as fixed `Developers`; `c` is a unique app identifier string. No deferred destination retention is promised. |
| `https://app.appsflyer.com/id498477945?pid=DL&c=` | Older iOS sample fallback; `pid=DL`, empty campaign placeholder. Prefer the guide's dedicated Download Link section for new evaluation. |
| `http://app.appsflyer.com/com.tranzmate?pid=DL&c=` | Older Android fallback sample, even uses HTTP. Not an app-directions contract. |
| Marketing/email static links | Guide says contact Moovit for links tailored to the campaign. Do not invent campaign/partner-only fields from consumer schemes. |

The website field inventory is what the accessible article supplies, not an assertion that all are optional. Embedded widget query attributes are a different interface; the linked widget documentation did not resolve to a specification. Do not substitute widget/REST fields or rate-limit credentials into `moovit://`.

## Platform handling and repository comparison

The [native guide](https://moovit.com/developers/deeplinking/) explicitly requires iOS 9+ `LSApplicationQueriesSchemes` authorization for `canOpenURL`; check `moovit://` and open the native link if installed. Android sample queries package **`com.tranzmate`**, then sends `Intent.ACTION_VIEW` with the scheme URI; it does not publish custom extras, activities or an `intent://` grammar. The App Store ID is **`498477945`**. The platform snippets are old examples, not current OS configuration completeness guarantees.

Inspected [`moovit.dart`](../../lib/src/maps/moovit.dart), [`map_app.dart`](../../lib/src/maps/map_app.dart), [`url_builder.dart`](../../lib/src/utils/url_builder.dart), [`mobile_only_maps_test.dart`](../../test/maps/mobile_only_maps_test.dart), Android manifest and example iOS plist.

| Current behavior | Contract assessment |
| --- | --- |
| Nearby scheme | Sends `lat` and `lon`, but no `partner_id`. `supportsMarkerCoords` is false although native marker fallback opens nearby transit. Honest distinction from a normal marker; title/zoom are not used. |
| Directions | Correct `dest_lat`, `dest_lon`, optional `dest_name`; optional origin pair and `orig_name`. Same URL on both platforms. |
| Missing fields | No `date`, `auto_run` or `partner_id`; these are documented gaps, with ambiguous defaults/attribution requiredness noted above. |
| Modes and waypoints | Signature accepts but ignores them. Inherited `supportsTravelMode()` is true for every mode; this does not demonstrate control of transport mode. |
| Browser | Both URL methods return null; no browser directions capability. Text Links exist, but the copy-generated-URL guidance and metro ID dependency do not justify guessing a generic coordinate URL builder. |
| Encoding | Shared builder drops blank values, encodes once and uses form-style spaces. `%20` compatibility versus `+` needs app testing. |
| Detection | Correct scheme/store IDs in class; Android package query and example iOS query scheme are present. A host application's own iOS declaration remains its responsibility. |

Tests assert scheme and key presence, simple destination label, and origin fields. They do not validate native outcomes or the omitted options.

## Concrete readiness tests

1. Assert decoded nearby/directions fields with asymmetric points: origin `40.735845,-73.990512`, destination `40.758896,-73.985130`. Verify exact negative longitude and endpoint distinction on Android and iOS.
2. Round-trip `Café & Tea + #1/入口?` labels and blank labels. Confirm no double encoding; verify `%20` versus `+` on devices.
3. Compare `auto_run=false`, `true` and omission on current app versions; record whether search is prefilled, executed, or navigation starts. These are different outcomes.
4. For any future `date` option, compare an offset timestamp with the equivalent UTC instant, a past date, a future timetable date and Europe/Stockholm's DST boundary. Establish departure/arrival semantics with vendor confirmation before exposing a typed API.
5. Test missing origin with location granted/denied, explicit origin versus GPS, and coverage/no-service cases. Validate missing coordinate pair handling only as exploratory tests, not a proposed partial-coordinate API.
6. Confirm `partner_id` policy with Moovit; test omission and a real approved caller name without fabricating credentials. Test install fallback separately from directions; it must not be advertised as retaining the destination without evidence.

No device execution or integration changes were made. Current public references are enough for basic native fields, but not enough to infer undocumented date defaults, attribution requirements, website construction rules or embedded-widget options.
