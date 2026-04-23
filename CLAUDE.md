# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repo layout

Two deployables in one repo:

- `plantdoctor/` — SwiftUI iOS app (target iOS 17). Xcode project at `plantdoctor.xcodeproj`, scheme `plantdoctor`, bundle ID `cn.buddy.plantdoctor`.
- `backend/` — Cloudflare Worker (`plantdoctor-api`), TypeScript, deployed via wrangler. Single `/diagnose` endpoint + `/health`.

User-facing product name is **"Leafwise"**. Internal target/folder names are still `plantdoctor` — do not rename, it breaks Xcode paths. Keep "Leafwise" in user-visible copy (paywall, Settings, `Info.plist` `CFBundleDisplayName`, store metadata).

## Commands

### iOS (run from repo root)

```bash
# Build for simulator
xcodebuild -project plantdoctor.xcodeproj -scheme plantdoctor \
  -destination 'platform=iOS Simulator,name=iPhone 15' build

# Unit + UI tests
xcodebuild -project plantdoctor.xcodeproj -scheme plantdoctor \
  -destination 'platform=iOS Simulator,name=iPhone 15' test
```

`plantdoctor/Shared/Secrets.swift` is gitignored. Copy `Secrets.swift.example` and fill in `apiBaseURL` + `sharedSecret` before the app will build/run usefully.

Local IAP testing uses `plantdoctor/Store.storekit` (attached to the scheme).

### Backend (run from `backend/`)

```bash
npm install
cp .dev.vars.example .dev.vars        # fill in OPENAI_API_KEY + SHARED_SECRET
npm run dev                            # wrangler dev → http://localhost:8787
npm run typecheck                      # tsc --noEmit
npm run deploy                         # wrangler deploy
```

Smoke-test a signed request against local or prod:

```bash
SHARED_SECRET=<secret> IMAGE=./sample.jpg \
  npx tsx test/sign.ts http://localhost:8787/diagnose
```

Deploy prerequisites: `wrangler secret put OPENAI_API_KEY` and `wrangler secret put SHARED_SECRET`. The `SHARED_SECRET` value **must** match the one baked into iOS `Secrets.swift` — rotating one without the other breaks auth.

### App Store submission / IAP

`docs/APP_STORE_SUBMISSION.md` and `docs/APP_STORE_IAP.md` are the sources of truth for `fastlane deliver` and the IAP uploader skill. Edit the docs, then re-run the relevant skill (`app-store-submission`, `app-store-iap-subs-upload`) — do not edit `fastlane/metadata/` or `fastlane/Deliverfile` by hand.

Use default stored App Store Connect API Key when use "app-store-submission" and "app-store-iap-subs-update" skill

Use default Copy Right and Contact Information from "app-store-submission" skill

## Architecture

### Request flow

iOS `DiagnosisClient` resizes the image (`ImageResizer`), base64-encodes, signs with `HMACSigner`, POSTs to the Worker. Worker verifies HMAC, runs two CF rate-limit bindings, calls OpenAI GPT-4o vision with a JSON-schema-constrained response, returns the structured diagnosis. Client persists it via SwiftData (`DiagnoseRecord`).

### HMAC auth (both sides must agree)

Signature is `hex(HMAC-SHA256(SHARED_SECRET, "{ts}\n{device}\n{sha256(body)}"))`, lowercase, sent in headers `X-PD-Timestamp` / `X-PD-Device` / `X-PD-Signature`. Server rejects >5-minute clock skew. Device ID is iOS `identifierForVendor`, stashed in Keychain so it survives reinstall within the same device/vendor scope.

If you add new endpoints, route them through the same `verifyHMAC` path — do not add unauthenticated POST endpoints.

### No-database constraint (backend)

The Worker has **no DB, no KV, no Durable Objects** — this is an explicit product constraint, not an oversight. Rate limiting uses native CF `[[unsafe.bindings]] type = "ratelimit"` in `wrangler.toml`. The period max is 60s, so hourly caps are approximated (`200/60s` ≈ 10k/hr global, `2/60s` ≈ 100/hr per device). The iOS client enforces a true rolling 100/hour cap in `CreditsLedger.wouldExceedHourlyCap` as belt-and-suspenders.

Do not introduce KV/DO/D1 without first confirming with the user.

### Paywall / credits model (iOS)

Two product types, stacked in a specific order — do not flip without user consent:

1. **Subscription daily quota first** (`SubscriptionTier.dailyQuota`: Silver 10/day, Gold 25/day). Resets at local midnight.
2. **Consumable credits next** (100/500/1200 packs). Starter grant: `AppLimits.freeStarterCredits` (10) once per iCloud account.

Key pieces:

- `CreditsLedger` (`@MainActor`) — single source of truth for balance, sub daily count, and the hourly ring buffer. Persists to Keychain via `KeychainHelper` so state survives reinstall.
- `StoreManager` — StoreKit 2 wrapper; publishes `activeTier` and credits purchases back into the ledger via `bind(credits:)`.
- `EntitlementStore` — combines ledger + store into `preflight()` (check) / `commit(using:)` (spend) for the diagnose flow.
- `CreditsMirror` — writes balance to the iCloud private DB (`iCloud.cn.buddy.plantdoctor`, record type `CreditsMirror`, single record `singleton`). Used **only** as a reinstall guard so free credits aren't re-granted on the same iCloud account; Keychain remains the source of truth for day-to-day reads.

Product IDs live in `ProductIDs.swift` and must stay in sync with `Store.storekit`, `docs/APP_STORE_IAP.md`, and ASC.

### SwiftData + CloudKit history

`DiagnoseRecord` is a `@Model` with all fields defaulted (CloudKit requirement). The container is initialized in `plantdoctorApp.init` with `.private("iCloud.cn.buddy.plantdoctor")` — the same container used by `CreditsMirror`. Image data uses `@Attribute(.externalStorage)`.

Adding a new non-optional field will break existing users' CloudKit sync — always give new properties a default value.

### Localization (runtime language switch)

`L10n.swift` bypasses `Bundle.main.preferredLocalizations` so the user can change language mid-session without a relaunch. Flow:

1. `LanguageStore.current` (persisted in `UserDefaults`) drives the active language.
2. On change, `L10n.setCurrentLanguage` swaps `L10n.activeBundle` to the matching `.lproj` bundle.
3. `RootView` is keyed by `language.current`, forcing a tree rebuild.
4. `AppleLanguages` is also updated so StoreKit dialogs etc. pick it up on next launch.

When adding user-facing strings, route them through `L10n` with an English default fallback — a missing key falls back to the default instead of crashing. Supported languages are listed in `AppLanguage` (11 locales, must match `Localizable.xcstrings` and the IAP catalog).

### App bootstrap ordering

`AppBootstrap.run` must run before the first diagnose. It (1) stashes the shared secret in Keychain, (2) warms the device ID, (3) consults `CreditsMirror` before seeding free credits so reinstalls on the same iCloud account don't re-grant. Don't move the free-credit seed out of this path.
