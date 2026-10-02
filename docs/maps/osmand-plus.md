# OsmAnd+ external launch contract

Checked **2026-10-02**. Audited map_launcher at fetched `origin/master`/HEAD [`8aa7a6e1152a80c4482003bdfaad8f850bdb6131`](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131). **Installed-app behavior remains unverified.**

## Paid Android identity, not a separate URL language

OsmAnd+ is the Android package **`net.osmand.plus`**, versus free `net.osmand`. Both production variants share the same parser sources and manifest. [Official flavor definitions](https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/build.gradle#L117-L149), [Google Play listing](https://play.google.com/store/apps/details?id=net.osmand.plus). Source evidence is pinned to [Android 344beca, 2026-10-02](https://github.com/osmandapp/OsmAnd/commit/344beca32335ab3c24c104667ba808e7ab64abc1), not asserted to equal the current binary release.

There is **no distinct OsmAnd+ iOS app identity established here**. The iOS app is OsmAnd Maps, Apple ID `934850257`. Its in-app Maps+/Pro purchases are not justification for assigning that ID to a second `OsmAndPlus` map entry. Our null `appStoreId` and `iosScheme` overrides are appropriate. The inherited URL methods can still be called directly with `platform: ios`; that produces the regular OsmAnd scheme, not evidence that Plus exists on iOS.

| Surface | Contract and free/paid difference |
| --- | --- |
| Native Android package-targeted VIEW | Set package `net.osmand.plus`. Same data URI syntax as free OsmAnd; correct package matters when both installed. |
| HTTP(S) `/go` | Auto-verified manifest filter explicitly intended for both Google Play Free and Plus. Verification/chooser defaults can vary on device. |
| HTTP(S) `/map`, `/add-tile-source`, `/open-gpx` | Browsable registrations shared with Free; `/map` not auto-verified in audited manifest. |
| `osmand.api://ACTION` | VIEW/DEFAULT, no BROWSABLE category; explicit native Intent is the reliable integration model, not a promised browser launch. |
| Browser/desktop | OsmAnd web map is shared, not a Plus-specific web product. Paid Android identity must not be inferred from opening that website. |
| Paid features/plugins | Same action vocabulary; commands depending on recording plugins or data still require them enabled/available. Purchase does not remove permission, plugin, map-data or GPS prerequisites. |

Source beside platform table: [official manifest](https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/AndroidManifest.xml#L125-L188), [custom-scheme filters](https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/AndroidManifest.xml#L546-L580).

## Complete shared contract and Plus-specific field inventory

The [OsmAnd audit](osmand.md) contains the full shared action/field/default/result catalog, including exact result-extra names and source links; **every Android row applies to Plus**, while iOS rows do not. The inventory here records the Plus launch surface explicitly to avoid treating inheritance as platform support. Current [official intent docs](https://osmand.net/docs/technical/algorithms/osmand-intents/) are incomplete and include `finish` examples inconsistent with source's `end`; the following is labeled **official-source inference** from [IntentHelper][intent] and [ExternalApiHelper][external].

| Plus action | Input fields, requiredness and semantics |
| --- | --- |
| `/go` | Required numeric `lat`,`lon`; optional integer `z` (generic parser also accepts `zoom`). Opens point, **not route**. No Android title consumption established in simple-domain parser. |
| `/map?pin=...` | Required `pin=latitude,longitude`; optional fragment `#zoom/latitude/longitude`. Location marker. |
| `/map#zoom/latitude/longitude` | Numeric map viewport fragment; no separate pin. |
| `/map/navigate` | Required `end=lat,lon`; optional `start=lat,lon`, `via=lat,lon;lat,lon`, `profile`, `params`. Route planning rather than unconditional guidance. |
| `/map/poi` | Required `pin`; optional `type`, `name`, `wikidataId`, `osmId`, fragment zoom. `type` chooses amenity lookup, otherwise `name` favorite lookup. |
| `/go?url=...` | Encoded nested URL, validated redirect. |
| `/add-tile-source` | Query dictionary opens map-source editor, including `name`, `url_template`, `min_zoom`, `max_zoom`; not a tile REST API. |
| `/open-gpx` | Required `url`, optional `name`; downloads/sanitizes name and appends `.gpx` if absent. Does not itself start GPX guidance. |
| `/premium?token=...` | Device/cloud authorization workflow. Token is sensitive. |
| `osmand.api://navigate` | Expected destination pair `dest_lat`,`dest_lon`; optional `dest_name`, `start_lat`,`start_lon`,`start_name`; valid available routable `profile` required; `force=false`, `location_permission=false`. Names default empty. |
| `osmand.api://navigate_search` | Required nonempty `dest_search_query`, numeric `search_lat`,`search_lon`, valid `profile`; optional start pair/name; `show_search_results=false`, `force=false`, `location_permission=false`. |
| `osmand.api://show_gpx`, `navigate_gpx` | Required GPX source precedence: query `path` → Intent string extra `data` → query `uri=true` with first `ClipData` URI. `uri=false` default; grant read URI access. Navigation additionally accepts `force`, `location_permission` false by default. |
| `pause_navigation`, `resume_navigation`, `stop_navigation`, `mute_navigation`, `unmute_navigation` | `osmand.api` actions without fields; depend on route/navigation state. |
| `record_audio`, `record_video`, `record_photo` | `osmand.api` actions, required `lat`,`lon`; enabled A/V plugin. |
| `stop_av_rec` | No fields; stops/saves recording. |
| `get_info` | No fields; activity result extras, not URL callback. |
| `add_favorite` | Required `lat`,`lon`; optional `name`,`desc`,`category` empty, `color` fallback 0, `visible=true`. |
| `add_map_marker` | Required `lat`,`lon`; `name` optional/empty. |
| `show_location` | Required `lat`,`lon`; opens context at zoom 15. |
| `start_gpx_rec`, `stop_gpx_rec`, `save_gpx`, `clear_gpx` | Optional `close_after_command=true`; recording plugin, including destructive clear action. |
| `execute_quick_action`, `get_quick_action_info` | Required zero-based `quick_action_number`, optional `close_after_command=true`; valid index depends on user's configured list. |
| `subscribe_voice_notifications` | Recognized but unimplemented, result 1002. |

All `osmand.api` actions in the table use that scheme; they are not paths appended to `/go`. The host/action is lowercased; fields use their literal names. Booleans are values, not the presence-only flags used by some other maps.

Coordinate pairs are latitude then longitude in geographic decimal degrees; no caller-selectable coordinate system. Android parses doubles without explicit local geographic range enforcement; use finite latitude −90…90 and longitude −180…180. No documented fixed waypoint/URL length limit. Query-encode values once; preserve ordered `via` pairs. `via` on Android splits commas or semicolons. [IntentHelper][intent].

`profile`: available built-ins `car`, `bicycle`, `pedestrian`, `truck`, `motorcycle`, `moped`, `public_transport`, `train`, `boat`, `aircraft`, `ski`, `horse`; custom routable profile keys may work. External `navigate` rejects `default`/unavailable/unroutable profiles; map-link unknown profile falls through default handling. `params`: comma-separated entries `key`, `key:value`, `key=value`, bare key true, routing-profile-specific vocabulary. [ApplicationMode](https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/src/net/osmand/plus/settings/backend/ApplicationMode.java#L55-L103), [IntentHelper parameter parser][intent].

Favorite color values: `darkyellow`, `red`, `orange`, `yellow`, `lightgreen`, `green`, `lightblue`, `blue`, `purple`, `pink`, `brown`, `black`. [DefaultColors](https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/src/net/osmand/plus/card/color/palette/solid/data/DefaultColors.java#L14-L42).

### Results, compatibility links and imports

Activity result: −1 OK, 0 canceled/default, 1001 exception, 1002 not implemented, 1003 inactive plugin, 1004 GPX not found, 1005 bad profile, 1006 empty search, 1007 missing search location, 1008 missing quick action. `get_info` returns optional position/map/destination doubles, route timing/distance, turn bundles and `version=1`. Exact keys (including `time_distance_left` and `after_next` without underscore) are listed in [OsmAnd callbacks](osmand.md#results-and-callbacks) and [source lines 431–466, 647–706][external]. No URL callback field established.

Shared external inputs also include Android `geo:lat,lon[?z=...]`, `geo:0,0?q=address`, `google.navigation:`, `osmand.navigation:`, registered `geo.action:`/`geo.action.offline:`, and provider-link compatibility formats listed in the [official intent page](https://osmand.net/docs/technical/algorithms/osmand-intents/). Provider-specific coordinate conventions must not be generalized to latitude-first. File VIEW imports include GPX/ZIP, KML, KMZ, OBF/ZIP, SQLite/SQLITEDB, OSF/ZIP, XML, WPT/3D chart. SEND uses `Intent.EXTRA_STREAM`; GPX MIME `application/gpx+xml` supports SEND_MULTIPLE. Exact MIME/scheme filters differ by file format in [manifest](https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/AndroidManifest.xml#L190-L445). These imports do not inherit `osmand.api` result payloads.

## Comparison with map_launcher and discriminating tests

Local implementation: [`OsmAndPlus extends OsmAnd`](../../lib/src/maps/osmand.dart), [base flags](../../lib/src/maps/map_app.dart), [package query](../../android/src/main/AndroidManifest.xml).

| Observation | Assessment |
| --- | --- |
| `playStoreId=net.osmand.plus`, id `osmandplus`; null iOS IDs/scheme | Correct product separation. No store identity mismatch found. |
| Inherits Android marker `/go?lat&lon[&z]` | Consistent with point-display source behavior. |
| Inherits Android directions `/go?lat&lon` | **Concrete semantic mismatch:** opens point rather than constructing a route. Destination-only shape is not an alternate directions form. |
| Origin/waypoints/travelMode ignored; supportsDirectionsCoords true and all modes true | Overstates implemented directions/mode capability. Waypoint flag false accurately reports omission. |
| All web URL methods null, `hasUniversalLink=false`, searches unsupported | Omitted app capabilities, not proof Plus lacks web links or search. |
| iOS custom URL inherited when method called directly | Does not change Android-only identity; test higher-level availability/dispatch separately. |

Proposed tests, not executed on devices:

1. Install Plus only, Free only, both; explicitly target `net.osmand.plus` and verify no fallback into Free. Test availability/store URL identity and iOS absence.
2. Compare current directions output for `(59.3293,18.0686)` with `https://osmand.net/map/navigate?start=58.4108,15.6214&end=59.3293,18.0686&profile=pedestrian&via=59.2,17.5;59.25,17.8`. Verify actual route planning and waypoint order, not just Intent acceptance.
3. Test `osmand.api://navigate?dest_lat=59.3293&dest_lon=18.0686&profile=car` via explicit VIEW, and invalid `profile=default` result 1005. Compare with browser click because BROWSABLE is absent.
4. Test disabled plugin, inaccessible GPX URI, no GPS permission, no offline maps, already navigating with `force=false`/`true`, and all four wrapper travel modes.
5. Decode `A&B + café/港` exactly once; asymmetric southern/eastern coordinates catch order errors. Check malformed/missing inputs outside `LocationCoords` only in a disposable native test harness.

## Limitations

This is official current-source inference with incomplete official prose docs, not an installed-binary certification. Full shared field semantics are in the companion OsmAnd audit rather than duplicated as an independently diverging contract. No Plus-only URL action, paid-specific callback, or separate iOS Plus protocol was established. Bound AIDL, embedded SDK and unrelated REST APIs remain out of scope.

[intent]: https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/src/net/osmand/plus/helpers/IntentHelper.java
[external]: https://github.com/osmandapp/OsmAnd/blob/344beca32335ab3c24c104667ba808e7ab64abc1/OsmAnd/src/net/osmand/plus/helpers/ExternalApiHelper.java
