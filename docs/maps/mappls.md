# Mappls / MapmyIndia external links

Checked **2026-10-02** against current provider [web/app links](https://developer.mappls.com/mappls-apps/mappls-app), [Android](https://developer.mappls.com/mappls-apps/android), and [iOS](https://developer.mappls.com/mappls-apps/ios) documentation, plus the [provider Android overview](https://about.mappls.com/api/move-api/android). These live pages expose no revision date or minimum application version. The provider's corresponding [navigation source revision dated 2025-05-16](https://github.com/mappls-api/mapmyindia-api-addendums/blob/e70a44e3d2e363277716e803361c62515ff5d35a/mapmyindia-mappls-deeplinks/android/readme.md) matches the current navigation text. No native application was tested.

Baseline: [`8aa7a6e`](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131), verified as fetched `origin/master`; [builder](../../lib/src/maps/mappls.dart), [capabilities](../../lib/src/maps/map_app.dart), [existing tests](../../test/maps/mapy_mappls_test.dart).

## Current navigation links and mode verification

Native form: `mappls://navigation?places={lat},{lng}[,{name}]&isNav=true&mode={mode}`. HTTPS form: `https://mappls.com/navigation?...` with the same documented fields. The provider says HTTPS can open the browser or redirect to the installed app; the raw scheme requires the app. Android package is `com.mmi.maps`. **The iOS page currently repeats Android-specific prose/package instructions**, so it is evidence of published iOS documentation but not independent proof of identical iOS runtime behavior.

Sources beside the parameter table: [Android navigation](https://developer.mappls.com/mappls-apps/android#_3-navigation), [iOS navigation](https://developer.mappls.com/mappls-apps/ios#_3-navigation).

| Field | Syntax / requiredness | Values, defaults, limits |
| --- | --- | --- |
| `places` | Destination `latitude,longitude` with optional third comma-separated name | Needed for the documented destination action. Current mobile table documents **one destination**, not an origin/via list. Coordinate values are decimal numbers; label is text. |
| `isNav` | Literal `true` | Triggers immediate turn-by-turn navigation. The page does not explicitly define `false` or an omission default; do not claim an omitted value starts navigation. |
| `mode` | Optional string | Exact published values: **`driving`, `trucking`, `biking`, `walking`**. No default is explicitly stated; examples use `driving` and `biking`. |

### Transit and bicycle are not verified capabilities

**`transit` is not in the provider's supported navigation-mode list.** Neither `bicycling` nor `cycling` is listed. `biking` *is* the documented spelling, but the deep-link page does **not define it as pedal-cycle routing**. The provider's separate [getDistance documentation](https://developer.mappls.com/mapping/getDistance/) associates `biking` with “two wheelers” and `trucking` with heavy vehicles. That related API is a terminology warning, **not proof that a deep-link mode shares every REST/SDK semantic**. A mapping from this package's `TravelMode.bicycling` to `biking` therefore needs provider confirmation/device validation; do not call it verified bicycle routing. No alternative transit or bicycle deep-link token was established.

The REST route API's coordinate order, profiles, avoid flags, and waypoint limits do not define the external app URL contract. Do not substitute REST `longitude,latitude` or transfer its stop limits to these links.

## Web directions, search, markers, and other actions

Unless otherwise shown, base URL is `https://mappls.com`. Some provider examples use `www.mappls.com`; both spellings appear in the sources, not proof of identical app-association handling. Source for web rows: [Mappls app link guide](https://developer.mappls.com/mappls-apps/mappls-app). Additional mobile actions: [Android](https://developer.mappls.com/mappls-apps/android), [iOS](https://developer.mappls.com/mappls-apps/ios).

| Path / action | Every documented field, requiredness, and syntax |
| --- | --- |
| `/{search-keywords}/near/{lat},{lng}` | Search text and numeric latitude,longitude needed for nearby search. Keyword list below is provider examples, not a formal exhaustive enum. No radius, result count, mode, or language field specified. |
| `/direction?places={point};{point}[;...]` | `places` needed; semicolon-separated route entries. Each point can be a six-character Mappls Pin, `lat,lng`, or `lat,lng,name`. Examples specify origin then destination; further entries support via points. Natural first-origin/last-destination ordering should be preserved and confirmed in UI. No maximum count is stated. |
| `/@{lat},{lng}` | Share/display coordinate; both coordinates needed. No name/zoom field documented. |
| `/pom/{lat},{lng}` | Point-on-map details, navigation/share/report entry. Android example uses `%2C`; iOS uses literal comma. |
| `/{mappls-pin}` | Share provider six-character digital address, e.g. `9ADJ1X`, `MMI000`. Examples also use lowercase pins; no full validation grammar or case policy specified. |
| `/get-pin` | No parameters; interactively create/get a Pin. **User login required** per guide. No callback returning the selected Pin is documented. |
| `/report` | No parameters; interactive issue reporting. **User login required**. Report category, subcategory, location, attachments and comments are UI steps, not documented URL query fields. |
| `/report/{mappls-pin}/{reportID}` | Both path identifiers needed to open/share report; report ID examples are UUID-shaped, but no formal validation rule/default. Mobile guide lists this form under both “Report (Place Detail)” and “View Reported Issue.” |
| `/review/{mappls-pin}/{reviewID}` | Both identifiers needed to open/share review; examples use UUID-shaped review ID. Do not infer link opening automatically submits a review. |
| `/profile/{username}` | Username path value needed to open user profile; mobile guides. No login/auth token parameter specified. |
| `/corona` | COVID dashboard with default layer selection. Still published, but legacy-topic functionality and current data freshness are unverified. |
| `/corona?containment_zone_gradient,corona_testing_centre,corona_treatment_centre` | Literal comma-separated **bare query tokens**, not a `layers=` field: containment zones, testing labs, treatment centers. No full layer enum or arbitrary combination grammar specified. |
| `/corona?safety_alert` | Bare query token enabling safety-check widget; still published, runtime unverified. |

All published nearby keyword examples, from the [web guide](https://developer.mappls.com/mappls-apps/mappls-app#_1-nearby-facilities): `corona isolation`, `corona testing`, `corona sample`, `vaccination centers`, `corona treatment`, `coffee`, `restaurants`, `pubs & bars`, `atms`, `pharmacy`, `parking`, `ev charging`, `charging stations`, `petrol pump`, `transports`, `entertainment`, `hotels`, `shopping`, `groceries`, `hospitals`, `police stations`, `post office`, `banks`, `spas`, `toilets`, `cng station`, `monuments`, `college`, `school`, `hunger relief centre`, `clinic`, `food`, `grocery`, `medical equipment`. The guide's visible “Veccination” label is a typo; its URL uses `vaccination%20centers`.

### Coordinate, encoding, and policy constraints

External link examples specify **latitude,longitude** in decimal degrees. These pages do not explicitly name a CRS, coordinate bounds/precision, max text length, URL length, stop limit, or routing-distance limit. WGS84 is a conventional interpretation, not a projection-selector parameter. Encode user text as UTF-8 URL components; e.g. `pubs%20%26%20bars` in a path. For `places`, preserve logical comma tuple separators and semicolon point separators after a single query decode. The provider itself shows an encoded semicolon (`%3B`) in a sample, so literal delimiters need not remain unescaped on the wire.

**Delimiter ambiguity:** percent-encoding a comma or semicolon inside a label does not necessarily disambiguate it after the app decodes the entire `places` value. The provider does not specify an inner escaping grammar. Test those labels separately rather than treating a Dart query round-trip as proof of correct app parsing.

No API key, `appname`, source-app attribution field, callback URL, route-completion callback, avoid-toll/highway policy, departure/arrival time, or selection-result return contract is specified for these links. Authentication for `/report` and `/get-pin` is user login, not an API key. Provider branding/terms links exist on the docs site; absence of an attribution *query parameter* is not a waiver of general terms.

## Legacy MapmyIndia Move forms

These are historical primary documentation, **not recommended current defaults**. Sources: [legacy Android](https://github.com/mappls-api/mapmyindia-api-addendums/blob/a6233a7f6d3388b5a6338cc33cc1e52784e6e1db/mapmyindia-move-deeplinks/android/readme.md), [legacy iOS](https://github.com/mappls-api/mapmyindia-api-addendums/blob/a6233a7f6d3388b5a6338cc33cc1e52784e6e1db/mapmyindia-move-deeplinks/iOS/readme.md), [legacy web](https://github.com/mappls-api/mapmyindia-api-addendums/blob/a6233a7f6d3388b5a6338cc33cc1e52784e6e1db/mapmyindia-move-deeplinks/web/readme.md), source revision **2021-07-08**. Successor Mappls links were introduced in the [2022-05-30 revision](https://github.com/mappls-api/mapmyindia-api-addendums/commit/da012ad96539b3fd76c079fb2b6ccc0669dfe259).

| Legacy form | Fields and source caveats |
| --- | --- |
| `mapmyindia://navigation?places={lat},{lng},{start-name};{lat},{lng},{destination-name}` | Android origin/destination list; latitude,longitude and labels; no mode, immediate-navigation flag, or maximum via count defined in that mobile page. |
| `com.mapmyindia.move://navigation?d_lat=...&d_lng=...&s_lat=...&s_lng=...&placeName={destination-name}&{start-name}` | iOS template uses `d_lat`/`d_lng` destination, `s_lat`/`s_lng` start. Its sample instead uses **`c_lat`/`c_lng`**, and appends start name as an unnamed query token. Internally inconsistent; do not normalize into an invented supported contract. |
| `https://maps.mapmyindia.com/{keywords}/near/{lat},{lng}` | Nearby search; same listed keyword examples as successor. |
| `https://maps.mapmyindia.com/direction?places={point};{point}[;...]` | eLoc or coordinate tuples, optional labels, appended via points; no stop limit. |
| `https://maps.mapmyindia.com/@{lat},{lng}` | Coordinate sharing. |
| `https://maps.mapmyindia.com/get-eLoc` | Interactive eLoc creation/retrieval. |
| `https://maps.mapmyindia.com/eloc/{eLoc}` or `http://eloc.me/{eLoc}` | Six-character eLoc sharing, predecessor terminology to Mappls Pin. |
| `https://maps.mapmyindia.com/report` and `/report/{eLoc}/{reportID}` | Report UI and sharing. |
| `https://maps.mapmyindia.com/corona` | Same bare query tokens `safety_alert` or `containment_zone_gradient,corona_testing_centre,corona_treatment_centre` as successor. |

Do not copy the old Android two-point `places` template into current `/navigation` and claim current documented origin/waypoint support: the current reference specifies one destination. Current `/direction` is the documented multi-point web interface.

## Implementation comparison

| Field / capability | Current builder | Assessment |
| --- | --- | --- |
| Marker path | `https://www.mappls.com/location/{lat},{lng}` | **Not a documented marker form in retrieved current/legacy references**; documented forms are `/@...` and `/pom/...`. This is a source mismatch, not proof `/location/` is rejected. |
| Marker title / zoom | Ignored | Neither is defined on the documented coordinate sharing forms. |
| Route destination | `https://mappls.com/navigation?places=lat,lng[,title]` | Matches current one-destination tuple shape; optional title encoded with shared helper. |
| Origin / waypoints | Both ignored; `supportsWaypoints=false` | Current `/navigation` does not define these; `/direction` supports multi-point routes. Omitted alternative action, not proof current query needs extra `origin` key. |
| Driving / walking | `mode=driving` / `mode=walking` | Both documented. |
| Transit | Emits `mode=transit` and advertises support | **Contradicts documented allowed-value list**; runtime handling unknown. No verified replacement transit token. |
| Bicycling | Emits `mode=biking` and advertises support | Spelling documented, bicycle semantics **unproven**; related provider terminology suggests two-wheeler routing. Do not silently equate bicycle and motorcycle. |
| Trucking | Not representable by generic travel-mode enum | Omitted documented provider mode. |
| Immediate navigation | Never emits `isNav=true` | Omitted feature; a directions method need not automatically start guidance. Do not claim omission is itself an error. |
| Native transport | `iosScheme=mappls://` for discovery but no custom navigation builder; falls back to HTTPS | HTTPS navigation documented; iOS app association still device-unverified. `hasUniversalLink=true` describes intended package behavior. |
| Search, Pin, profile/report/review, COVID | No builders; search flags false | Omitted actions, not provider incapability. |

## Concrete follow-up tests

1. Use destination `(28.612964,77.229463)` and different origin `(28.550716,77.268928)`; independently assert latitude-first tuple, origin preservation only on an explicit `/direction` implementation, and ordered intermediates.
2. Test `driving` and `walking` against literal expected strings; reject/mark unsupported `transit` rather than allowing a test to canonize the existing undocumented value. Request provider clarification before advertising bicycle semantics for `biking`.
3. Marker contract test should choose the documented `/@` or `/pom` action and separately device-test old `/location` compatibility. A test that merely checks `contains('mappls.com/location')` validates implementation, not provider support.
4. Keep `/navigation` with/without `isNav=true` separate from `/direction` route preview; do not start guidance unintentionally while adding origin support.
5. Existing `Café & Tea/入口? #1` test confirms Dart decoding, not provider behavior. Add comma/semicolon label experiments and a three-point asymmetric route. No maximum via limit should be invented from unrelated REST quotas.
6. Real-device/browser checks remain: both host spellings, Android/iOS installation and fallback, `biking` vehicle meaning, omitted mode, unsupported mode, `/location` versus documented markers, and legacy redirects. No navigation or report submission was performed.
