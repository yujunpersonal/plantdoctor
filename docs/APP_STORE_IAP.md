# Leafwise — App Store IAP & Subscription Catalog

Source of truth for the uploader script. Bundle ID: `cn.buddy.plantdoctor`.

> ASC field limits: Display Name ≤ 30 · Description ≤ 45 · Reference Name ≤ 64.

Supported locales (11): `en-US`, `zh-Hans`, `zh-Hant`, `de-DE`, `fr-FR`, `ja`, `ko`, `es-ES`, `pt-BR`, `ru`, `it`.

---

## Summary

| # | Type | Product ID | Reference Name | USD |
|---|---|---|---|---|
| 1 | Consumable | `cn.buddy.plantdoctor.credits.100` | 100 Credits | 4.99 |
| 2 | Consumable | `cn.buddy.plantdoctor.credits.500` | 500 Credits | 19.99 |
| 3 | Consumable | `cn.buddy.plantdoctor.credits.1200` | 1200 Credits | 39.99 |
| 4 | Subscription (monthly) | `cn.buddy.plantdoctor.sub.silver` | Leafwise Silver | 2.99 |
| 5 | Subscription (monthly) | `cn.buddy.plantdoctor.sub.gold` | Leafwise Gold | 4.99 |

---

## 1 · 100 Credits (Consumable)

- **Product ID:** `cn.buddy.plantdoctor.credits.100`
- **Reference Name:** `100 Credits`
- **Price (USD):** $4.99
- **Review note:** Grants 100 plant-diagnose credits on successful purchase. Consumed one per diagnosis after the subscription daily quota is used up.

| Locale | Display Name | Description |
|---|---|---|
| en-US | 100 Credits | 100 AI plant diagnose credits. |
| zh-Hans | 100 积分 | 100 次 AI 植物诊断积分。 |
| zh-Hant | 100 點數 | 100 次 AI 植物診斷點數。 |
| de-DE | 100 Guthaben | 100 KI-Pflanzendiagnose-Guthaben. |
| fr-FR | 100 crédits | 100 crédits de diagnostic IA. |
| ja | 100 クレジット | 100 回の AI 植物診断クレジット。 |
| ko | 100 크레딧 | 100회 AI 식물 진단 크레딧. |
| es-ES | 100 créditos | 100 créditos de diagnóstico IA. |
| pt-BR | 100 créditos | 100 créditos de diagnóstico por IA. |
| ru | 100 кредитов | 100 кредитов на ИИ-диагностику. |
| it | 100 crediti | 100 crediti per diagnosi con IA. |

---

## 2 · 500 Credits (Consumable)

- **Product ID:** `cn.buddy.plantdoctor.credits.500`
- **Reference Name:** `500 Credits`
- **Price (USD):** $19.99
- **Review note:** Grants 500 plant-diagnose credits on successful purchase. Consumable — stacks with subscription daily quota.

| Locale | Display Name | Description |
|---|---|---|
| en-US | 500 Credits | 500 AI plant diagnose credits. |
| zh-Hans | 500 积分 | 500 次 AI 植物诊断积分。 |
| zh-Hant | 500 點數 | 500 次 AI 植物診斷點數。 |
| de-DE | 500 Guthaben | 500 KI-Pflanzendiagnose-Guthaben. |
| fr-FR | 500 crédits | 500 crédits de diagnostic IA. |
| ja | 500 クレジット | 500 回の AI 植物診断クレジット。 |
| ko | 500 크레딧 | 500회 AI 식물 진단 크레딧. |
| es-ES | 500 créditos | 500 créditos de diagnóstico IA. |
| pt-BR | 500 créditos | 500 créditos de diagnóstico por IA. |
| ru | 500 кредитов | 500 кредитов на ИИ-диагностику. |
| it | 500 crediti | 500 crediti per diagnosi con IA. |

---

## 3 · 1200 Credits (Consumable)

- **Product ID:** `cn.buddy.plantdoctor.credits.1200`
- **Reference Name:** `1200 Credits`
- **Price (USD):** $39.99
- **Review note:** Grants 1,200 plant-diagnose credits on successful purchase. Best-value consumable top-up.

| Locale | Display Name | Description |
|---|---|---|
| en-US | 1,200 Credits | 1,200 AI plant diagnose credits. |
| zh-Hans | 1,200 积分 | 1,200 次 AI 植物诊断积分。 |
| zh-Hant | 1,200 點數 | 1,200 次 AI 植物診斷點數。 |
| de-DE | 1.200 Guthaben | 1.200 KI-Pflanzendiagnose-Guthaben. |
| fr-FR | 1 200 crédits | 1 200 crédits de diagnostic IA. |
| ja | 1,200 クレジット | 1,200 回の AI 植物診断クレジット。 |
| ko | 1,200 크레딧 | 1,200회 AI 식물 진단 크레딧. |
| es-ES | 1.200 créditos | 1.200 créditos de diagnóstico IA. |
| pt-BR | 1.200 créditos | 1.200 créditos de diagnóstico por IA. |
| ru | 1 200 кредитов | 1 200 кредитов на ИИ-диагностику. |
| it | 1.200 crediti | 1.200 crediti per diagnosi con IA. |

---

## Subscription Group · Leafwise Plus

- **Reference Name:** `Leafwise Plus`
- **Group ID (StoreKit):** `LEAFWISE_GROUP`
- **Rank ordering:** 1 = Gold (highest), 2 = Silver. Users upgrading from Silver → Gold move up the rank.

| Locale | Group Display Name |
|---|---|
| en-US | Leafwise Plus |
| zh-Hans | Leafwise 会员 |
| zh-Hant | Leafwise 會員 |
| de-DE | Leafwise Plus |
| fr-FR | Leafwise Plus |
| ja | Leafwise プラス |
| ko | Leafwise 플러스 |
| es-ES | Leafwise Plus |
| pt-BR | Leafwise Plus |
| ru | Leafwise Plus |
| it | Leafwise Plus |

---

## 4 · Leafwise Silver (Auto-Renewable Subscription)

- **Product ID:** `cn.buddy.plantdoctor.sub.silver`
- **Reference Name:** `Leafwise Silver`
- **Group:** Leafwise Plus · rank **2**
- **Duration:** 1 month · auto-renewing
- **Price (USD):** $2.99
- **Review note:** Auto-renewing monthly subscription. Grants 10 AI plant diagnoses per day. Cancelable anytime in App Store settings.
- **Benefits:** 10 AI diagnoses per day (stacks with consumable credit packs).

| Locale | Display Name | Description |
|---|---|---|
| en-US | Leafwise Silver | 10 AI plant diagnoses every day. |
| zh-Hans | Leafwise 银级 | 每日 10 次 AI 植物诊断。 |
| zh-Hant | Leafwise 銀級 | 每日 10 次 AI 植物診斷。 |
| de-DE | Leafwise Silber | 10 KI-Pflanzendiagnosen pro Tag. |
| fr-FR | Leafwise Silver | 10 diagnostics IA de plantes par jour. |
| ja | Leafwise シルバー | 1 日 10 回の AI 植物診断。 |
| ko | Leafwise 실버 | 매일 10회 AI 식물 진단. |
| es-ES | Leafwise Silver | 10 diagnósticos IA de plantas al día. |
| pt-BR | Leafwise Silver | 10 diagnósticos IA de plantas por dia. |
| ru | Leafwise Silver | 10 ИИ-диагностик растений в день. |
| it | Leafwise Silver | 10 diagnosi IA di piante al giorno. |

---

## 5 · Leafwise Gold (Auto-Renewable Subscription)

- **Product ID:** `cn.buddy.plantdoctor.sub.gold`
- **Reference Name:** `Leafwise Gold`
- **Group:** Leafwise Plus · rank **1** (highest)
- **Duration:** 1 month · auto-renewing
- **Price (USD):** $4.99
- **Review note:** Auto-renewing monthly subscription. Grants 25 AI plant diagnoses per day. Cancelable anytime in App Store settings.
- **Benefits:** 25 AI diagnoses per day (stacks with consumable credit packs).

| Locale | Display Name | Description |
|---|---|---|
| en-US | Leafwise Gold | 25 AI plant diagnoses every day. |
| zh-Hans | Leafwise 金级 | 每日 25 次 AI 植物诊断。 |
| zh-Hant | Leafwise 金級 | 每日 25 次 AI 植物診斷。 |
| de-DE | Leafwise Gold | 25 KI-Pflanzendiagnosen pro Tag. |
| fr-FR | Leafwise Gold | 25 diagnostics IA de plantes par jour. |
| ja | Leafwise ゴールド | 1 日 25 回の AI 植物診断。 |
| ko | Leafwise 골드 | 매일 25회 AI 식물 진단. |
| es-ES | Leafwise Gold | 25 diagnósticos IA de plantas al día. |
| pt-BR | Leafwise Gold | 25 diagnósticos IA de plantas por dia. |
| ru | Leafwise Gold | 25 ИИ-диагностик растений в день. |
| it | Leafwise Gold | 25 diagnosi IA di piante al giorno. |

---

## Required per-product assets (manual in ASC)

Each IAP and subscription requires, before it can pass review:

- **Review screenshot** — ≥ 640 × 920 PNG or JPG showing the product as it appears in the app paywall. Upload per product in ASC → In-App Purchases / Subscriptions → the product → Review Information.
- **Review note** — already generated above; the uploader pushes it with each product.

---

## App-level legal fields

Set these on the **app listing** (not per-product) before subscriptions pass review:

- **EULA URL:** `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/` (Apple's standard EULA — already referenced in §2 of `docs/APP_STORE_SUBMISSION.md`)
- **Privacy Policy URL:** `https://support.buddy.cn/en/privacy-policy` (per-locale variants are already set via `fastlane deliver`)
- **Auto-renew disclosure** — already embedded in each locale's app Description and the subscription description above.

---

## Cross-check

- StoreKit config: [`plantdoctor/Store.storekit`](plantdoctor/Store.storekit)
- Product IDs (Swift): [`plantdoctor/Features/Paywall/ProductIDs.swift`](plantdoctor/Features/Paywall/ProductIDs.swift)
- Tier ranks (Swift): `SubscriptionTier.rank` — Silver = 1, Gold = 2 (local ordering; ASC inverts: rank 1 = highest).
