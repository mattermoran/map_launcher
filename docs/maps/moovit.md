# Moovit

The plugin opens native directions with destination coordinates/title and an optional coordinate origin/title. Explicit modes and nonempty waypoints are rejected, including direct builders. Marker capability is false; the low-level marker fallback opens nearby transit and ignores title/zoom. Browser URLs, `date`, `auto_run` and `partner_id` are not emitted. Android targets `com.tranzmate`; iOS callers declare `moovit` for installation queries.

Reference check: 2026-10-13. Protocol tables include provider options not exposed by the plugin.

## Sources

| Source | Date/version and scope |
| --- | --- |
| [Deeplinking](https://moovit.com/developers/deeplinking/) | Native actions, install/campaign links and legacy OS samples; no protocol version stated. The 2019 timestamp is an example, not a release date. |
| [Developer overview](https://moovit.com/developers/) | Separates mobile deeplinking, website links and embedded widget. Undated. |
| [Text Links & Buttons](https://moovit.com/developers/links/) | Website links and copy-generated-URL instructions. |
| [Old developer host](https://www.developers.moovit.com/) | Linked from the current guide but connection failed on this check. Not necessary for the tables transcribed from the working guide. |
| [Widget reference](https://moovit.com/developers/widgets/) | Returned general Moovit homepage content, not the promised widget specification. Widget configuration is not verified. |
| [Public Transit APIs](https://moovit.com/maas-solutions/transit-apis/) | Primary commercial API overview, undated; volume-metered trip-plan, nearby, stops, lines, real-time and service-alert APIs, with sales contact. Not the consumer-app URL contract. |

## Native actions and all published parameters

Reference: Deeplinking, “Opening Moovit with Schemes”; same schemes on Android/iOS.

| Action | Form | User-visible meaning |
| --- | --- | --- |
| Nearby lines and stations | `moovit://nearby?lat=<float>&lon=<float>&partner_id=<app-name>` | Map centered on the supplied location with nearby transit; without coordinates uses current location. Not a general-purpose arbitrary titled marker API. |
| Get directions | `moovit://directions?dest_lat=<float>&dest_lon=<float>&dest_name=<label>&orig_lat=<float>&orig_lon=<float>&orig_name=<label>&date=<ISO8601>&partner_id=<app-name>` | Suggested transit routes from one origin to one destination. `auto_run` is additionally documented in the parameter table/example despite being absent from the guide's structure line. |

| Field / action | Type / requiredness | Values and default behavior |
| --- | --- | --- |
| `lat`, `lon` / nearby | Optional floats | Latitude and longitude separately. Guide says absent values use user's location; behavior with only one coordinate present is unspecified. Pass both or neither. |
| `orig_lat`, `orig_lon` / directions | Optional floats | Origin latitude and longitude; absent values use user's location. Pair consistency and location-permission errors unspecified. |
| `dest_lat`, `dest_lon` / directions | Optional according to guide; needed for a specified destination | Absent destination uses user's location per guide; the plugin's required destination is a library constraint. |
| `orig_name`, `dest_name` / directions | Optional strings | Display labels; absent label shows lat/lon. Not address search or place IDs. No maximum length given. |
| `auto_run` / directions | Boolean; no required flag stated | `false`: preview and user must tap “Search”; example uses `true`. Default when absent, and acceptance of `0`/`1`, are not specified. Do not infer automatic turn-by-turn navigation from automatic search. |
| `date` / directions | Date string; no required flag stated | ISO 8601, described as `yyyy-MM-ddTHH:mm:ssZ`; example is `2019-04-01T18:30:00+02:00`. Omission default, departure-versus-arrival meaning, supported horizon and timezone/DST rules are not defined. No separate arrive-by field. |
| `partner_id` / both | String; requiredness ambiguous | Caller app name for tracking. Present in every canonical form/example but not explicitly mandatory; not a secret or issued credential. Default, character set, length and registration requirement are unspecified. |

Coordinates are separate decimal floats, latitude then longitude by field name. **WGS84 is inferred**, not explicitly named; precision, ranges and truncation rules are absent. Library `LocationCoords` separately enforces finite latitude −90…90, longitude −180…180.

Percent-encode values once as UTF-8. The guide uses `%20` for spaces. Its unescaped `+02:00` date example is potentially ambiguous to form decoders; encode the plus as `%2B`, not a space. This is an encoding recommendation, not evidence that a particular Moovit parser mishandles the literal plus.

Example derived from the documented fields, **not executed**:

```text
moovit://directions?dest_lat=40.758896&dest_lon=-73.985130&dest_name=Times%20Square&orig_lat=40.735845&orig_lon=-73.990512&orig_name=Union%20Square&auto_run=false&date=2026-10-05T18%3A30%3A00%2B02%3A00&partner_id=example
```

No public deep-link fields are documented for transport-mode selection, wheelchair preferences, waypoints, zoom, line/stop IDs, ticket purchase, caller callbacks, x-callback-url, API authentication or a return URL. Stops/lines in the commercial REST product are not usable as consumer deep-link fields without a separate contract. The app is a transit journey planner, not a generic driving-navigation target.

## Website, installation and partner links

References: Text Links & Buttons; Deeplinking download/campaign sections.

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

## Platform handling and plugin limitations

The native guide requires iOS 9+ `LSApplicationQueriesSchemes` authorization for `canOpenURL`. Android uses **`com.tranzmate`** with `ACTION_VIEW`; no custom activity/extras or `intent://` grammar is specified. App Store ID: **`498477945`**. These legacy snippets are not complete current OS setup instructions.

Code: [builder](../../lib/src/maps/moovit.dart), [capabilities](../../lib/src/maps/map_app.dart), [encoding](../../lib/src/utils/url_builder.dart). URL tests: [`mobile_only_maps_test.dart`](../../test/maps/mobile_only_maps_test.dart).

| Current behavior | Contract assessment |
| --- | --- |
| Nearby scheme | Sends `lat` and `lon`, but no `partner_id`. `supportsMarkerCoords` is false although native marker fallback opens nearby transit. Honest distinction from a normal marker; title/zoom are not used. |
| Directions | Correct `dest_lat`, `dest_lon`, optional `dest_name`; optional origin pair and `orig_name`. Same URL on both platforms. |
| Missing fields | No `date`, `auto_run` or `partner_id`; these are documented gaps, with ambiguous defaults/attribution requiredness noted above. |
| Modes and waypoints | Explicit modes and nonempty waypoints are rejected; the public scheme has no mode selector. |
| Browser | Both URL methods return null; no browser directions capability. Text Links exist, but the copy-generated-URL guidance and metro ID dependency do not justify guessing a generic coordinate URL builder. |
| Encoding | Shared builder drops blank values, encodes once and uses form-style spaces. `%20` compatibility versus `+` needs app testing. |
| Detection | Correct scheme/store IDs in class; Android package query and example iOS query scheme are present. A host application's own iOS declaration remains its responsibility. |

Date defaults, attribution requiredness, generic website construction and widget options remain unspecified. URL tests do not establish native outcomes.
