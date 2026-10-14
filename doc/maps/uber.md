# Uber rider app

**Not included in map_launcher.** Requested in [issue 111](https://github.com/mattermoran/map_launcher/issues/111). The documented surface is a rider-UI handoff, not marker display or turn-by-turn navigation.

Source check: **2026-10-02**. Current native behavior remains unverified.

## Product and suitability

Uber remains available. The rider app is [Android `com.ubercab`](https://play.google.com/store/apps/details?id=com.ubercab) (live listing updated September 25, 2026) and [Apple ID `368677368`](https://apps.apple.com/us/app/uber-rides-eats-hotels/id368677368), published by Uber Technologies, Inc. Store titles vary by locale and include additional services; this is not Uber Driver, Uber Eats, or Uber Lite. A store ID does not establish an iOS bundle ID.

**Feasible as an explicit “request a ride” handoff, not as an ordinary map marker or turn-by-turn directions provider.** A deep link prepopulates the rider UI; it does not establish a booking, fare, driver assignment, or completed trip. An OS launch success is not a booking success. Require a user gesture and accurately label the action.

## External URL contracts

Contract sources: [deep-link introduction](https://developer.uber.com/docs/riders/ride-requests/tutorials/deep-links/introduction), [FAQ](https://developer.uber.com/docs/riders/ride-requests/tutorials/deep-links/faq), [widget migration](https://developer.uber.com/docs/riders/ride-requests/tutorials/widget/migration-to-deep-links), and [promotions](https://developer.uber.com/docs/riders/ride-promotions/introduction). These primary pages have no reliable publication/version date and retain historical Windows Phone/iOS 9/May 2016 wording. Those OS minimums are not current installation requirements.

| Entry point | Action/platform/fallback |
| --- | --- |
| `uber://` | Launch native rider app; Android/iOS custom scheme. No built-in web fallback. |
| `uber://riderequest?...` | Native ride-request setup using nested pickup/dropoff keys below. |
| `uber://?action=setPickup&...` | Older action-selector vocabulary used by the documentation/SDK generation; do not confuse it with JSON location syntax. |
| `https://m.uber.com/looking?...` | Recommended universal ride link. Installed app handoff; documentation describes store fallback on mobile, signup on other devices, and an open/download interstitial where detection fails. |
| `https://m.uber.com/?...` | Explicit mobile-web rider experience, documented to open in the browser. |
| `uber://?action=applyPromo&client_id=...&promo=...` | Native promotion entry screen, not a ride request. |
| `https://m.uber.com/ul/?action=applyPromo&client_id=...&promo=...` | Documented universal promotion link. Older SDK/migration examples also use `/ul/` for ride links; avoid rewriting `/looking` to `/ul/` without testing. |

### Native/legacy nested parameters

Source: [native example and notes](https://developer.uber.com/docs/riders/ride-requests/tutorials/deep-links/introduction), [FAQ constraints](https://developer.uber.com/docs/riders/ride-requests/tutorials/deep-links/faq), [legacy web migration example](https://developer.uber.com/docs/riders/ride-requests/tutorials/widget/migration-to-deep-links).

| Parameter | Type, requiredness, values and semantics |
| --- | --- |
| `action` | String selector where action-style URLs are used: `setPickup` or `applyPromo`. No multiple actions in one URL. `riderequest` instead puts the ride action in the URL host. |
| `client_id` | Developer application's public client-ID string, included in documented integration examples. Introduction does not formally mark requiredness; do not promise anonymous attribution or invent an ID. Never a client secret. |
| `pickup` | Optional literal `my_location` instead of coordinate subkeys. Delegates location to Uber; do not combine with an explicit pickup pair. Omission behavior is not precisely specified. |
| `pickup[latitude]`, `pickup[longitude]` | Optional explicit pickup pair, decimal coordinates. Both needed to specify a point. Product selection requires this explicit pickup, not `my_location`. |
| `pickup[nickname]`, `pickup[formatted_address]` | Optional strings supplying human-readable pickup context. |
| `dropoff[latitude]`, `dropoff[longitude]` | Optional destination pair, decimal coordinates. Single destination contract; no documented native nested-waypoint list. |
| `dropoff[nickname]`, `dropoff[formatted_address]` | Strings; **at least one is required for the destination to appear**, per FAQ and migration guide. Include a meaningful label even for a coordinate-only caller. |
| `product_id` | Optional opaque product-ID string, usually UUID-shaped; valid for the explicit pickup location. Same product name can have different IDs in different markets. Not a generic `driving`, `walking`, or `transit` mode. |
| `link_text` | Optional return-link label string shown in the native example. No documented length/default or availability guarantee. |
| `partner_deeplink` | Optional percent-encoded URL to the originating app, paired with `link_text` in the example. Not a reliable trip-completion callback; no documented success/error result payload or authentication guarantee. |
| `promo` | Required payload for useful `applyPromo` operation; opaque promotion-code string. Eligibility/expiry/account constraints are decided by Uber. No public length/range limit specified. |

Coordinates use separate latitude/longitude fields (decimal geographical degrees); these pages do not explicitly name a datum or numerical validation ranges. Use normal WGS84 GPS coordinates as the integration convention, validating finite latitude −90…90 and longitude −180…180 locally, rather than claiming Uber documents these limits. No maximum address length, URL size, precision, or callback length is stated.

Encode keys and values once with a URI query builder: brackets may be `%5B`/`%5D`, spaces `%20`, literal `+` `%2B`, and reserved characters in labels or callback URLs encoded. Do not copy the documentation's rendered spaces around `=` into actual URLs.

### Current universal/mobile-web JSON parameters

Source: [introduction query table and Location object](https://developer.uber.com/docs/riders/ride-requests/tutorials/deep-links/introduction).

| Parameter | Type, requiredness and semantics |
| --- | --- |
| `client_id` | Public client-ID string; no explicit required flag in table. |
| `pickup` | Optional URL-encoded JSON Location object. Do not send legacy `pickup[latitude]` as if it were a JSON property. Introduction links to current-location guidance but does not define a JSON sentinel; native `my_location` is documented separately. |
| `drop[0]`, `drop[1]`, … | Indexed Location objects, each JSON-serialized and URL-encoded. The table calls this `drop: list[Location]`; example establishes `drop[0]`, prose permits multiple stops. No documented maximum stops or index-gap behavior. |
| Location `latitude`, `longitude` | JSON numbers defining point; provide both. Requiredness not formally annotated, but coordinates determine location. |
| Location `addressLine1` | String nickname; optionality not formally annotated. Supply useful text. |
| Location `addressLine2` | Display-address string, concatenated with line 1. Does **not** override the coordinates. |
| `product_id` | Optional string; explicit pickup required; no current-location product selection. |
| `payment_method_id` | Optional UUID string preselecting a payment method. No authorization to retrieve someone else's IDs or guarantee that selection is accepted. Omit in a basic launcher. |

Serialize raw Unicode strings inside JSON, then encode that JSON as one query value. The prose calls address lines “URL encoded” while its example demonstrates the outer JSON encoding; double encoding needs a discriminating test, not an assumption. No documented schedule time, passenger count, accessibility option, avoidances, arbitrary route shape, fare cap, or automatic-confirm parameter was found in these contracts.

**Documentation conflict:** the FAQ says deep links cannot target the mobile website, while the introduction and migration guide explicitly document it and a dedicated web fallback. Record the conflict; use current introduction syntax as the implementation candidate, and verify actual browser behavior before advertising a fallback.

## Authorization, platform and privacy boundaries

- Basic native handoff carries no OAuth bearer token. Rider login, available products, payment, pricing, and confirmation remain inside Uber. [Riders API introduction](https://developer.uber.com/docs/riders) states API access requires Uber approval/business-development contact; do not assume API access merely because a URI launches.
- REST products/estimates/requests and `PATCH /v1.2/me` promotions are **separate authenticated API contracts**, not URI parameters. An embedded Ride Request Button or SDK builder is a helper/UI component; its server-token/client-secret examples are not a reason to put secrets in URLs or ship them in a launcher.
- iOS scheme discovery needs the host's query-scheme configuration. Android installed-app targeting should identify `com.ubercab`, with package visibility handled by the host. Neither proves market service availability.
- Documentation warns that pasted Safari address-bar universal links and iOS simulators differ from physical-device tapped links; test a real link tap. Android's destination may appear only after “Set Pickup Location”.
- Sending pickup/dropoff, labels, callback data, or payment IDs discloses them to Uber and potentially browser history/logging systems. Avoid patient/customer names in labels, redact URL telemetry, and do not silently collect caller GPS just to enable product selection. Universal-link fallback can send data to a website even when no app is installed.
- No ride-booking transaction, callback authentication, or business attribution should be inferred from a returned URL. Prefer no callbacks and no payment-method selection in the initial integration.

## Remaining compatibility questions

Current acceptance of legacy versus JSON links, JSON address-line encoding, mobile-web fallback and multi-stop limits require confirmation. Product selection is pickup-local and is not a generic travel-mode guarantee. Promotions, return links and payment-method selection are separate account-sensitive features, not necessary parts of a basic ride handoff.
