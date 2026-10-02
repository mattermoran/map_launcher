# Sygic GPS Navigation (consumer app)

Checked: **2026-10-02**. Research only; no native-device tests. Baseline fetched and verified: [8aa7a6e](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131), equal to `origin/master`. [Issue 111](https://github.com/mattermoran/map_launcher/issues/111) marks “Sygic” complete, but the baseline's `SygicTruck` entry targets Android `com.sygic.truck`; this document covers the **distinct consumer product**.

## Product identity and evidence status

The official [Sygic GPS Navigation product page](https://www.sygic.com/gps-navigation) still offers the consumer navigation app and links to [Android `com.sygic.aura`](https://play.google.com/store/apps/details?id=com.sygic.aura) and [Apple ID `585193266`](https://itunes.apple.com/us/app/sygic-gps-navigation-maps/id585193266). It separately advertises Sygic Truck. Do not use the Truck package/store identity for the consumer app; an Apple numerical ID is not the bundle ID.

**Strongest consumer launch contract:** the “Supported universal URL schemes for Consumers” section of the official [iOS Custom URL page](https://www.sygic.com/developers/professional-navigation-sdk/ios/custom-url). It explicitly states these `https://go.sygic.com/...` schemes are valid only for consumer Sygic GPS Navigation. The preceding `com.sygic.aura://...` section says **Truck or Professional navigation**. Same-looking branding/scheme text is not a guarantee of interchangeability.

Access limitation: live fetches of that page, its `enterprise.sygic.com` counterpart, and the Android Custom URL page returned **HTTP 403** on the checked date (also confirmed with direct HTTP headers). A cached full rendering of the official iOS page was readable; no reliable source update date/version is displayed. This is **cached primary documentation, not live-verified current behavior**. The [Windows Professional page](https://www.sygic.com/developers/professional-navigation-sdk/windows/api-examples/custom-url) was also readable through the page reader. Do not conceal this access limitation or replace it with claims from a third-party URL library.

## Consumer universal links and complete documented parameters

Source for every row: [official consumer section](https://www.sygic.com/developers/professional-navigation-sdk/ios/custom-url). It does not identify a minimum consumer release. All links use **`https://go.sygic.com`**. These are app entry links, not Sygic REST API calls and not a promise of an interactive web map when the app is absent.

| Path / action | Parameter | Type, requiredness, values/defaults/limits |
| --- | --- | --- |
| `/search` — open search results | `q` | Search text: address, postal code, or coordinates. Shown as action input (not explicitly marked optional). No length or coordinate-text grammar specified. |
| `/search` | `center` | Optional decimal coordinate pair; search center. Without it, actual position is center by default. |
| `/directions` — start route planner | `to` | Destination coordinate pair; not marked optional, provide it for a route. |
| `/directions` | `from` | Optional start coordinate pair. Omitted-origin default is **not explicitly stated** in this table; test current-location behavior instead of assuming. |
| `/directions` | `via[]` | Optional waypoint coordinate pair; repeat key for multiple ordered waypoints, as official example does. No count limit or stop-versus-shaping-point semantics stated. |
| `/directions` | `mode` | Optional string: `car`, `walk`, `van`. Default not stated. No documented bicycle, public transit, truck dimensions, motorbike, or EV route parameter here. In-app modes do not imply URL values. |
| `/place` — search/open first valid result in POI detail | `q` | Search string. Example uses `q=Bratislava` without coordinates. |
| `/place` | `coordinates` | Coordinate pair. Alternative example uses coordinates without `q`; relationship/precedence if both supplied not specified. At least one useful locator is needed; no separate arbitrary marker-title parameter documented. |
| `/store` — open store item | `product` | Item tag string, example `dashcam`; alternative to ID. No tag enumeration or default. |
| `/store` | `productId` | Item ID, example `123`; treat as opaque identifier, not guessed integer range. Alternative to tag; precedence if both supplied unstated. |
| `/web` — open a web view | `url` | URL string; documented example `https://www.sygic.com`. Required action payload; no scheme allowlist, callback, auth, or size limit stated. |
| `/sign-in` | None documented | Open login UI. No credentials or automatic-login query contract. |
| `/manage-maps` | None documented | Open map-management UI, not automatic download command. |
| `/travel-insurance` | None documented | Open insurance UI; not a navigation mode. |
| `/ev` | None documented | Open EV mode; not an externally specified route with charging constraints. |

Consumer examples establish **latitude,longitude** (`49.2194,18.7408`), opposite the older custom coordinate command below. The table does not explicitly name the datum or numerical ranges. Use normal WGS84 GPS decimal degrees as the integration convention, validating finite latitude −90…90 and longitude −180…180 locally rather than attributing an undocumented range to Sygic. No precision, URL length, query length, waypoint cap, zoom, marker icon, origin label, destination label, callback, result code, or avoidances are specified.

Encode individual values once with normal URL query encoding; repeated `via[]` may be represented as repeated `via%5B%5D`. Do not collapse repeated keys into a single value. Encode nested `url` as a query value, Unicode as UTF-8 percent escapes, literal plus as `%2B`, and reserved `&`/`#` in search text. No special double-encoding requirement is documented for consumer links.

Candidate examples (not tested):

```text
https://go.sygic.com/place?coordinates=59.3293,18.0686
https://go.sygic.com/directions?from=59.3293,18.0686&to=59.3421,18.0520&via%5B%5D=59.3350,18.0600&mode=walk
```

The directions action is explicitly a **route planner**, not necessarily immediate turn-by-turn navigation. A place link opens a POI result/detail, not necessarily an arbitrary labelled pin. Both are important capability distinctions for the package's `showDirections`/`showMarker` interface.

## Legacy Truck/Professional custom actions — separate product contract

This section catalogs the public custom URL surface so that consumer research does not mistakenly inherit it. It is **not verified consumer support**. Sources: [iOS Truck/Professional Custom URL](https://www.sygic.com/developers/professional-navigation-sdk/ios/custom-url), [Windows Professional Custom URL](https://www.sygic.com/developers/professional-navigation-sdk/windows/api-examples/custom-url). Android page was inaccessible, so Windows' “Android Geo URI” subsection is evidence of published claims, not independently confirmed Android consumer support.

All commands below follow `com.sygic.aura://COMMAND` with **positional pipe-separated arguments**, not query parameters. Arguments are shown in required documented order; the tables do not define omitted/empty-slot defaults unless mentioned. String lengths and numeric bounds are unspecified. Do not interpret this scheme's spelling as unique installed-product detection.

| Command | Arguments after command, separated by pipes | Semantics / limits |
| --- | --- | --- |
| `search` | search string; optional trailing `drive` | Search, or search then drive. |
| `address` | country/name or ISO code, city, postal, street, house number, type | iOS example uses `SVK`; type `show`, `drive`, `walk`. Windows table lists show/drive. No empty-field behavior specified. Some table syntax omits `://`, while examples include it. |
| `coordinate` | longitude, latitude, type | Decimal **longitude-first**; iOS type `show`, `drive`, `walk`. Windows lists show/drive. Origin unspecified by URL. |
| `coordinateaddr` | longitude, latitude, address description, type | Labelled destination; documented action `drive`. Do not expand allowed types beyond evidence. |
| `route` | local file name (`sif` or `json`) | Load itinerary file. Not inline origin/destination/waypoints. No file-access or point-count guarantee. |
| `route_download` | URL, format | Download/load itinerary; format `sif` (itinerary/precomputed route), `json` (PTV), `bcr` (PTV). No inline stop limit specified. |
| `url` | web page | Open web page in navigation. |
| `activate` | product code | Activate a license. |
| `activate` (remote overload) | SD password, product ID, period, description | Password/ID/period must be agreed with Sygic support; no public range. |
| `login` | username, password | Login/start navigation; do not put real credentials into a logged/browser URL. |
| `update` | map identifier or `all` | Immediately downloads, deletes old maps on app restart; temporary double storage possible. Example map `fra`, not a complete map-code enum. |
| `mysygic` | none | Open shop. |
| `mysygicproduct` | product ID | Product detail, in Windows table; not in inspected iOS table. |
| `mysygicbuy` | product ID | Purchase UI/license operation, not map launch. |
| `gpslog` | NMEA file name under `Res/gpslogs` | Playback, Windows table; not in inspected iOS table. |
| `truckSettings` | `key=value&key=value...` string | Vehicle configuration; documented since 13.6.0; keys below. Not consumer `mode`. |
| `back_button` | application identifier | Back-button target; iOS page uses an Android-package example (`com.android.chrome`), so iOS callback syntax/behavior needs vendor clarification. Not a documented result callback. |
| `settingsOverwrite` | file path | Overwrite settings, Windows table only in inspected evidence. Mutates configuration. |
| `deviceCode` | none | Get device code; no return transport/schema defined by table. |
| `hud` | `none`, `normal`, or `inverted` | `none` returns to normal navigation display. |
| `setLanguage` | ISO language, type, voice pack | Type `Lang`, `Voice`, `LangVoice`; voice `NormalMale`, `NormalFemale`, `TTS`. Voice ignored with `Lang`; normal voices must already be downloaded. Docs say ISO 639-1 but use `en-GB`, so exact locale acceptance not fully specified. |

Truck settings source: [same iOS table](https://www.sygic.com/developers/professional-navigation-sdk/ios/custom-url). Entries are independently selectable `key=value` fields; missing-key mutation behavior and numeric bounds are not specified.

| Key | Type / allowed values / units / default |
| --- | --- |
| `mxs` | Numeric maximum speed, km/h. |
| `wei` | Numeric total weight, kg. |
| `axl` / `axw` | **Documentation conflict:** key column says `axl`, examples use `axw`; maximum axle weight in kg. Do not silently resolve. |
| `len`, `wid`, `hei` | Numeric length, width, height in millimeters. |
| `rou` | `car`, `tru` (truck), `cmp` (camper), `van`. |
| `general`, `water` | `1` enables respective hazmat flag, `0` clears. |
| `hClass` | Combined characters from `1`…`9`, `I`; `0` clears all. Example `148`. |
| `adr` | Single `B`, `C`, `D`, `E`; cannot combine; `0` clears. |
| `profile` | Profile ID to modify and activate; default `1`. Range unspecified. |
| `emiss` | Emission class `1`, `2`, `3`, `4`, `5`, `6`. |
| `year` | Production year, example `2017`; minimum/maximum unspecified. |

Legacy encoding: documentation specifically says percent-encode the parameter string including pipes/spaces/reserved characters; example `route_download%7Chttp%3A%2F%2Fdata.my.com%2Fmy%20route.sif`. Other examples retain raw pipes, so test raw versus encoded pipes on the intended product/version. Multiple commands can be chained with `&&&` (example login then back-button). That is side-effecting command composition, not a waypoint list, and should not be exposed by a simple map launcher.

The [Windows page's “Supported standard Android Geo URI schemes” section](https://www.sygic.com/developers/professional-navigation-sdk/windows/api-examples/custom-url) additionally lists `geo:latitude,longitude`, optional `?z=zoom`, `geo:0,0?q=lat,lng(label)`, address search `geo:0,0?q=my+street+address`, and `google.navigation:q=ADDRESS&mode=b|w|d&ll=latitude,longitude`. Zoom bounds/defaults, mode interpretation/actual product support, precedence of q and ll, and callbacks are not defined there. These **latitude-first** forms must not be confused with custom `coordinate`'s longitude-first fields. This cross-platform documentation oddity is not proof of consumer handling.

## Authorization, platform differences and licensing

The consumer section lists HTTPS universal links but is on an iOS documentation page; it supplies no Android intent action/extras, package-targeting recipe, custom consumer detection scheme, Android minimum version, or desktop web-map guarantee. Consumer Android applicability needs vendor/device confirmation; don't transplant the Professional Android contract. On iOS, a generic custom-scheme probe may collide with Truck/Professional and therefore cannot identify the consumer app reliably. Test coexistence.

No API key, client ID, OAuth token, or partner parameter is documented for the consumer links. `/sign-in` opens account UI. A universal link can fall back to a website when no app handles it; destination preservation and installation flow are not documented. This requires runtime testing before offering web support.

The official page's **License terms** restrict “Custom URL scheme” integration to **personal usage**, and direct commercial users to sales. Whether that language applies identically to the later consumer universal-link section is not clarified. **Resolve commercial permission before shipping**, rather than treating a publicly visible URL as a license grant.

[Sygic Maps SDK](https://developers.sygic.com/maps-sdk/) embeds maps/navigation in the caller's app; Professional native APIs and REST activation/routing are separate products/contracts. Their routing profiles, API credentials, method arguments, and itinerary schemas must not be copied into consumer URLs. Legacy download/login/purchase/configuration commands have side effects beyond opening a map and are inappropriate defaults.

## Integration decision and proposed discriminating tests

**Prefer consumer `go.sygic.com/directions` and `/place` candidates over copying `SygicTruck`.** Block a production support claim on commercial-terms clarification, current consumer-app verification, and reliable identity/discovery behavior. Preserve endpoint/waypoint capability only where observed; do not advertise arbitrary marker titles or immediate navigation from the route-planner action.

Privacy: URLs expose exact travel plans; web fallback can add network/history exposure. Do not add sensitive names to a search query, send login credentials via legacy URLs, fetch arbitrary untrusted itinerary URLs, purchase store items, or change app settings as part of a map-open operation.

Proposed tests, **not executed**:

1. Install consumer alone, Truck alone, and both; confirm which app receives each universal/custom link. A successful `com.sygic.aura` probe must not count both products as independently installed.
2. Compare consumer latitude-first `59.3293,18.0686` with deliberately reversed pair; compare with legacy longitude-first only on the documented Professional product.
3. Compare destination-only and explicit remote origin with location allowed/denied. Verify actual start, endpoint, planner versus active guidance.
4. Use two asymmetric repeated `via[]` entries; assert stop order and retention. Test no waypoint versus one versus practical limit only after vendor documents it.
5. Exercise `car`, `walk`, `van`, omitted mode, and invalid mode separately; do not infer motorbike/EV URL support from product marketing.
6. `/place?q=...` versus `coordinates=...`, both together, and a point with no POI; distinguish arbitrary pin support from nearest/first POI result.
7. Reserved characters/Unicode and repeated-key encoding; custom legacy raw pipe versus `%7C` only in an authorized test environment.
8. Tapped links on iOS/Android, cold/warm app, installed/uninstalled, offline/missing maps, and browser fallback. No account changes, purchases, downloads, or license activation without separate consent.
