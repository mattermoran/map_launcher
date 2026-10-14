# Lyft rider app

**Not included in map_launcher.** Requested in [issue 111](https://github.com/mattermoran/map_launcher/issues/111). The available contract evidence supports a candidate rider-UI handoff, not map markers or turn-by-turn navigation.

Source check: **2026-10-02**. Current native support remains unverified.

## Availability and evidence quality

The current rider product is **Lyft**, published by Lyft, Inc., [Apple ID `529379082`](https://apps.apple.com/us/app/lyft/id529379082); Android identity is [`me.lyft.android`](https://play.google.com/store/apps/details?id=me.lyft.android), independently used in the official Android source below. Do not confuse Lyft Driver with the rider app. [Lyft's download page](https://www.lyft.com/ride-with-lyft) still offers rider onboarding. Availability of the app does not establish ride coverage at an arbitrary destination.

The [old developer deep-link page](https://developer.lyft.com/docs/deeplinking) could not be retrieved on this date (connection failure). This is not evidence of a discontinued rider app. The strongest readable parameter evidence is **official but dormant SDK source**, not a current native-app specification:

- iOS [`LyftDeepLink.swift`](https://github.com/lyft/Lyft-iOS-sdk/blob/b0c5e3324cb3ac1aa585003c952d5b2d2f756359/Sources/LyftUI/LyftDeepLink.swift), head dated 2019-06-24.
- Android [`DeepLink.java`](https://github.com/lyft/lyft-android-sdk/blob/4ba28e33346da908ff15dea84ab7c7c42231beec/deeplink/src/main/java/com/lyft/deeplink/DeepLink.java) and [`DeepLinkParams.java`](https://github.com/lyft/lyft-android-sdk/blob/4ba28e33346da908ff15dea84ab7c7c42231beec/deeplink/src/main/java/com/lyft/deeplink/DeepLinkParams.java), head dated 2021-09-20, SDK release 2.0.2.
- Both repositories have `archived: false`; they are dormant, not archived. SDK source demonstrates generated links, not present-day binary support.

**Candidate integration:** explicitly labelled ride-request handoff. It is not a map marker API or turn-by-turn navigation API, and launch success is not a booking result. Reconfirm supported parameters with Lyft and test current app versions before claiming full support.

## External actions and parameters

Official-source-inferred bases: `lyft://ridetype` for the native app and `https://ride.lyft.com/u` for the iOS SDK's web behavior. The iOS helper defaults to native; its web behavior opens a Safari view controller. Native-open failure uses a signup URL. Do not claim `/u` is a verified current universal link or that the Android SDK implements the same web behavior.

Parameter source: [iOS builder](https://github.com/lyft/Lyft-iOS-sdk/blob/b0c5e3324cb3ac1aa585003c952d5b2d2f756359/Sources/LyftUI/LyftDeepLink.swift), [Android builder](https://github.com/lyft/lyft-android-sdk/blob/4ba28e33346da908ff15dea84ab7c7c42231beec/deeplink/src/main/java/com/lyft/deeplink/DeepLink.java). Requiredness below describes **builder behavior**, not a server-enforced contract.

| Parameter | Syntax/type, requiredness, defaults and restrictions |
| --- | --- |
| `id` | Ride-type string, always emitted; default `lyft` (standard). Built-in historical values listed below. Not a trip ID. |
| `pickup[latitude]`, `pickup[longitude]` | Optional decimal-number pair. Android emits only when both are non-null; iOS takes an optional `CLLocationCoordinate2D`. No explicit `my_location` sentinel. Omitted-pickup app behavior must be tested rather than borrowing Uber's rule. |
| `destination[latitude]`, `destination[longitude]` | Optional decimal-number pair for one destination; **`destination`, not Uber's `dropoff`**. Same pairing rule. |
| `pickup[address]` | Optional string in Android builder. Not emitted by the inspected iOS builder. No source-defined precedence when inconsistent with coordinates. |
| `destination[address]` | Optional string in Android builder. Not established on iOS by that source. |
| `partner` | Optional public developer/client-ID string; iOS obtains it from developer configuration. No embedded secret or OAuth token. Attribution/partner acceptance is not guaranteed by source. |
| `credits` | Optional coupon/promo-code string. User/account/market eligibility remains Lyft-controlled. Source supplies no length or expiry syntax. |

Coordinates are named latitude and longitude (decimal geographical degrees; iOS Core Location uses WGS84). No numeric ranges are enforced in these builders. An integrating caller should validate finite latitude −90…90 and longitude −180…180; those are application-side checks, not a verified Lyft parser range. No precision limit, maximum URL size, string length, address format, or list-size contract is published here.

Historical ride types from [iOS `RideKind`](https://github.com/lyft/Lyft-iOS-sdk/blob/b0c5e3324cb3ac1aa585003c952d5b2d2f756359/Sources/LyftModels/RideKind.swift) and [Android `RideTypeEnum`](https://github.com/lyft/lyft-android-sdk/blob/4ba28e33346da908ff15dea84ab7c7c42231beec/deeplink/src/main/java/com/lyft/deeplink/RideTypeEnum.java):

| Wire value | Historical meaning |
| --- | --- |
| `lyft` | Standard; default |
| `lyft_line` | Line/Shared |
| `lyft_plus` | Plus/XL |
| `lyft_premier` | Lux |
| `lyft_lux` | Lux Black |
| `lyft_luxsuv` | Lux Black XL |

iOS uses a raw-representable struct allowing other strings; Android's helper uses a closed enum. **These historical product names are not a claim that those products are still sold.** Do not map generic walking/transit/bicycle modes to ride types. No external waypoints, scheduling, passenger count, accessibility selection, avoidance, route geometry, or callback fields were found in either builder. Absence from a builder is not proof that private partner contracts do not exist.

### Encoding and fallbacks

The iOS builder applies its query encoder. The Android builder directly concatenates addresses, client ID, and promo strings without encoding. This is evidence of an old implementation flaw/limitation, **not a recommended escaping contract**. For new code, percent-encode query keys/values once (including brackets, `&`, `#`, Unicode, and literal `+`) and verify app behavior. Do not use malformed sample links to establish support.

Fallbacks from [iOS source](https://github.com/lyft/Lyft-iOS-sdk/blob/b0c5e3324cb3ac1aa585003c952d5b2d2f756359/Sources/LyftUI/LyftDeepLink.swift) and [Android source](https://github.com/lyft/lyft-android-sdk/blob/4ba28e33346da908ff15dea84ab7c7c42231beec/deeplink/src/main/java/com/lyft/deeplink/DeepLink.java):

| Form / field | Meaning and evidence boundary |
| --- | --- |
| `https://www.lyft.com/signup/{signUpIdentifier}` | iOS acquisition fallback, not a directions endpoint. |
| `https://www.lyft.com/signup/SDKSIGNUP` | Android acquisition fallback. |
| `clientId` | Fallback public client ID, camelCase unlike native `partner`; iOS substitutes `unknown` when unconfigured. |
| `sdkName` | SDK attribution string, e.g. iOS; not a transport mode. |
| `sdkVersion` | SDK version metadata; iOS uses `?.?.?` if absent. |

These signup URLs are SDK implementation details, not permission to impersonate SDK attribution. A launcher should prefer explicit install fallback rather than constructing tracking metadata it does not own. The Android helper gets the launch intent for `me.lyft.android`, adds `FLAG_ACTIVITY_NEW_TASK`, and attaches the deep-link data; it is not evidence of a named public Lyft-specific intent action or arbitrary extras.

## API, authorization and product boundaries

The official SDK also supports ride types/estimates and other network/UI operations. Those are separate API/embedded SDK integrations, not external URL fields. Do not infer OAuth scopes, access availability, credentials, or current partner enrollment rules from the fact that a deep-link builder accepts `partner`. No active public partner entitlement policy was established from the inaccessible developer portal; obtain current confirmation if attribution, custom types, or promotions are requirements.

Basic URI generation requires no bearer token in the inspected code; the rider still signs in and chooses/confirms inside Lyft. No documented success/error/cancel callback or completed-booking receipt exists in the inspected contract. Current iOS query-scheme registration and Android package visibility are host integration requirements, not Lyft authorization.

**Privacy:** a ride action sends destination/pickup to Lyft and may associate them with an account. Web fallback additionally exposes those values to browser history and network services. Avoid sensitive labels, redact URL logs, and ask before collecting the caller's location. Do not apply coupons or initiate paid requests as incidental testing. Label the action “Open Lyft”/“Request a ride”, not “Show marker”.

## Remaining compatibility questions

Current parameter acceptance, omitted-pickup behavior, address/coordinate precedence, iOS address parity, historical ride-type availability and `/u` fallback need confirmation. Store acquisition is separate from destination retention; attribution requires a legitimately assigned partner ID and cannot be established from an OS launch result.
