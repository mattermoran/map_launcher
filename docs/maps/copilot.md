# CoPilot

## Current support

`CoPilot` provides coordinate markers (`VIEW`) and destination-only directions (`GOTO`) on Android and iOS. Directions reject explicit origins, nonempty waypoints and every explicit travel mode. No mode is serialized; a licensed vehicle profile is not a generic driving-mode selector. Search, STOPS/TASKS, universal URLs and zoom are not implemented.

Configuration: Android `com.alk.copilot.mapviewer`, iOS App Store ID `378870891`, query scheme `copilot`. See [provider](../../lib/src/maps/copilot.dart), [capabilities](../../lib/src/maps/map_app.dart), and [URL builder](../../lib/src/utils/url_builder.dart). Both actions send separate decimal `lat` and `long` fields, with optional `name`; empty names are omitted.

Source check: **2026-10-02**. Native acceptance remains unverified.

## Current primary documentation and product restrictions

| Reference | Source date/version and scope |
| --- | --- |
| [Multiple URLs][multi] | Live primary page, updated **2026-02-09**. Explicit note: “URL launch is only supported on our Truck licensed application.” Covers app launch, not merely embedded APIs. |
| [Single URL / TASKS][tasks] | Live primary page, updated **2026-01-26**; requires **10.26.1.345+**. |
| [Standalone integration][standalone] | Live primary page, updated **2025-12-23**. Explicit app-store/MDM standalone deployment and licensed asset requirement. |
| [Integration overview](https://developer.trimblemaps.com/copilot-navigation/) | Separates one-way standalone URL intents from SDK two-way APIs and CPIK embedded navigation. Do not infer SDK callbacks or embedded API features for this launcher. |

Presence of the consumer app/package alone is **not** proof of the required Truck entitlement. The legacy `http://www.copilotlive.com/copilot/android?...` endpoint is documented, but not fully compatible with Android 12+. The recommended custom scheme is `copilot://`; clickable HTTP(S) links on Android 12+ require CoPilot **10.19.3.48+** and `https://copilotgps.com/copilotgps?…` (HTTP also documented). `copilotv9://` is a CoPilot 9 legacy alias, not a preferred current endpoint.

## Single-location action contract

Base: `copilot://mydestination?type=LOCATION`. Field names are case-sensitive. All rows below derive from [Multiple URLs → Send a Single Stop][multi].

| Field | Requiredness / type | Values, defaults and limits |
| --- | --- | --- |
| `type` | Fixed selector | `LOCATION` |
| `action` | Required string | `VIEW` shows location; `GOTO` clears current trip and sets sole destination; `ADDNEXTSTOP` prepends a stop. No default documented. |
| `lat`, `long` | Both required without address; decimal numbers | Latitude then longitude as **separate keys**. `+` optional; `-` required for negative values. Coordinates take precedence over address in this endpoint. Explicit datum/range/error policy not given. |
| `name` | Optional string | Up to **164 characters**. |
| `address`, `city`, `juris`, `state`, `zip` | Address alternative; optional when coordinates supplied | Street, city, jurisdiction, state/country, postal code. Recommended combination: address + city + state/jurisdiction + ZIP. Outside North America `state` means country. No per-field limits/defaults stated. |
| `customPlaceID`, `trimblePlaceID` | Optional identifiers | Company-assigned place ID / Trimble Maps place ID. No precedence rule stated here. |

Unresolved locations are ignored. `GOTO` and `ADDNEXTSTOP` behavior is specified for navigation mode; planning mode can differ. `ADDNEXTSTOP` is GPS-state-sensitive: the documented no-fix/saved-trip case may replace instead of add. No explicit origin, route-avoidance field, travel-mode enum, zoom, or mandatory callback exists in this endpoint. `GOTO` sets a trip; do not promise that every app state starts guidance without interaction.

The examples `lat=+40388249&long=-74654724` contradict the same page's decimal-coordinate prose and later decimal-degree examples. **Do not change the builder to microdegrees on that evidence.** Use decimal degrees and verify the legacy example separately on supported versions. Normal geographic bounds are latitude −90…90, longitude −180…180; the page does not specify rejection or clamping. No explicit datum selector is documented; GPS/WGS84 is expected, not independently stated by this page.

## Multi-stop route and search actions

Base: `copilot://options?type=STOPS` (**10.19+**, Account Manager licensing in the feature summary). [Primary source][multi].

| Field/action | Contract |
| --- | --- |
| Repeated `stop` | Ordered string fields `name\|address\|city\|zip\|juris\|state\|lat\|long`. Preserve empty positions; no individual field mandatory. Coordinates decimal degrees, optional `+`, required negative sign. Local map geocoding. |
| Repeated `query` | `name\|single search string`; can accompany fielded address to narrow results. Requires reliable internet for the single-search service. Coordinates supplied with search act as search center, not necessarily final destination. |
| `IncludeCustomPlaceIdOnly=true` | With `query=customPlaceID`, available **10.26.1.585+**. |
| `ExternalTripId` | Optional caller trip identifier, **10.28.2.142+**, for RouteReporter correlation. |
| Stop limits / label encoding | No stop-count limit specified for Android/iOS; some browsers limit URIs to 2,000 characters. **Do not include `&`, `=`, `\|` in stop names**: vendor parsing restrictions, not solved by merely percent-encoding. Other text should be URI-encoded once. |

Sending stops replaces the existing itinerary and opens PLAN; the driver taps navigate. One stop gets GPS origin inserted. With multiple stops, **first stop is replaced by current GPS location when navigation begins**: duplicate the desired first stop or send an expected starting location first. This is not an arbitrary fixed-origin route API. Mixed street/coordinate handling is nuanced: when the named street is within one mile, snap near the coordinates on that street; otherwise snap to nearest street and report `ERROR_STREET_NOT_FOUND`. UK postcode can override coordinate geocoding; do not send both when coordinates must win. No general callback transport for that error is specified in the URL page.

## Management and routing actions

These are publicly documented standalone actions, **not currently emitted by this library**. They require appropriate licensed deployments, not a free consumer launch entitlement. Source: [Multiple URLs][multi], with [full configuration key/value reference][configs].

| Endpoint selector (`copilot://options?type=`) | Fields / types / constraints |
| --- | --- |
| `CONFIG`: direct activation | Required alphanumeric `CompanyID`, `AssetID`; optional boolean `showconfirmation`, default false. Current format 10.19+; activation section also mentions 10.14+ for Account Manager generally. |
| `CONFIG`: reseller activation | Required alphanumeric `PartnerID`, `ExternalAccountID`, `AssetID`; optional `showconfirmation=false`. 10.19+. |
| `Activation` | Required string `ProductKey`; separate call, cannot combine with stops or other configs. |
| `CONFIG`: identification | Alphanumeric `VehicleID`, `DriverID` identify active vehicle/driver; 10.19+. Per-field requiredness not given. |
| `CONFIG`: settings | Repeat distinct `ConfigName=ConfigValue` entries. Generic user.cfg or CPIK-style names accepted; boolean true/false or documented enum values. This endpoint explicitly incorporates the [configuration registry][configs]; it is not an unrestricted promise that every embedded API works via URL. Per-key defaults/ranges belong to that registry. Some changes require restart. |
| Confirmation / restart | `showconfirmation=true` or `SETTINGS_CONFIRMATION_DIALOG=true`; `RestartCoPilot=true` or `RESTART_COPILOT=true`. |
| Return-to-app button | Android 10.19+: both `EnableCustomButton=true` and `AppLaunchBundleID=<caller bundle id>` required to configure button. User-initiated return, not arrival/result callback. |
| `VehicleProfile` | `SelectByName=<profile name>`, case-insensitive matching, 10.19.4.348+. Only when no active trip; separate call, not with other configs/stops. Missing profile keeps current profile. `&` forbidden even escaped. |
| `FLEETPORTAL` | `action=Set`; alphanumeric `DriverID`, `DeviceID`, `PartnerID`; booleans `EnableCompliance`, `EnableFleetPortal`, `showconfirmation`. No complete required-field table. `ShowCompliancePopup` default false, **deprecated 10.19.3.48**. Feature 10.9.0.1098+. |

Fleet settings apply automatically with Account Manager asset activation when assets represent vehicle/driver. Device-based assets may additionally need vehicle `DeviceID`; non-Account-Manager licensing needs explicit FleetPortal connection. The separately versioned configuration registry supplies the authoritative per-setting inventory; it is not a universal mode or truck-dimension query syntax.

## Consolidated JSON tasks

Base `copilot://options?type=TASKS&JSON=<Base64 JSON>`; **10.26.1.345+**. Standard Base64, then safe query encoding to preserve `+`, `/`, `=`. Field casing below follows [primary tables/examples][tasks]; example casing inconsistencies do not justify assuming case-insensitivity. Only include task objects needed. Defaults/limits not listed below are unspecified, not zero/unlimited.

| JSON object / field | Type, requiredness and semantics |
| --- | --- |
| `Ams` | Optional task object. Direct activation requires `AssetID`, `CompanyID`; reseller requires `AssetID`, `ExternalAccountID`, `PartnerID` (alphanumeric strings). |
| `FleetPortal` | Optional task object with `DeviceID`, `PartnerID`, `DriverID` strings and `EnableCompliance`, `EnableFleetPortal`, `ForceSync` booleans. Compliance requires RouteReporter license. ForceSync refreshes without restart. |
| `Trip` | Task object containing optional `ExternalTripId` (10.28.2.142+), `RoutingProfile`, `Stops`. |
| `Trip.RoutingProfile` | Table says alphanumeric; example uses **`{"Name":"profile"}`**. Selects an existing profile when no active trip. Unmatched dispatched profile prompts user. Resolve table/example mismatch before implementation. |
| `Trip.Stops[]` | Objects containing `Location` and optional stop metadata. GPS-origin replacement rules above still apply. |
| `Location.Address` | String `StreetAddress`, `City`, `State`, `Zip`, `County`, `Country`; supply enough to geocode, individual requiredness not specified. |
| `Location.Coords` | String `Lat`, `Lon`, decimal degrees; vendor recommends ≥6 fractional digits. Coordinates take precedence over address in this API. |
| `Location.Label`, `Location.CustomPlaceID` | String label (shown in example), company Place ID (10.26.1.585+). No label length given for this JSON API; do not automatically borrow the old 164-character limit. |
| Stop `StopType` | Optional string `Waypoint`; otherwise ordinary stop. Example puts it beside `Location`, although descriptive prose suggests location containment: follow up this discrepancy before implementation. |
| Stop `PlannedDuration` | Optional integer dwell time; used for ETA except licensed advanced optimization. **Unit/range not specified by this page.** |
| Stop `EarliestArrivalTime`, `LatestArrivalTime` | Optional ISO-8601 strings; no date means current date. Used for ETA except licensed advanced optimization. |
| Stop `AtRiskThreshold` | Optional integer minutes before window end; no bounds given. |
| Root `ShowConfirmation` | Optional boolean for testing/configuration confirmation; no stated default in TASKS page. |

## Android geo fallback

[CoPilot's own reference][multi] explicitly supports `geo:lat,long?q=address` (coordinates win), or `geo:0,0?q=address`. From **10.14.0.368**, `geo:0,0?q=address@lat,long` and the reverse order are accepted. From **10.19.0.1360**, address can label the stop; from **10.19.0.1715**, `geo:0,0?q=lat,long(label)` supports caller labels. One address-label example appears longitude-first while the stated grammar and other examples are latitude-first: preserve latitude-first and test rather than copy that inconsistency. This documented app fallback is stronger evidence than merely assuming all apps accept Android common intents.

## Unimplemented actions and unresolved details

Search, ADDNEXTSTOP, STOPS/TASKS, vehicle profiles and management operations are documented but not emitted by this provider. Their version and licensing prerequisites apply independently. Truck entitlement, the legacy coordinate example, TASKS nesting/type discrepancies, active-trip/profile interaction, GPS-state behavior and automatic guidance require vendor or native-app confirmation. URL generation alone establishes none of those outcomes.

[multi]: https://developer.trimblemaps.com/copilot-navigation/feature-guide/advanced-features/url-launch/
[tasks]: https://developer.trimblemaps.com/copilot-navigation/feature-guide/advanced-features/url-launch2/
[standalone]: https://developer.trimblemaps.com/copilot-navigation/standalone-app/integration/
[configs]: https://developer.trimblemaps.com/copilot-navigation/feature-guide/operating-features/configuration-options/
