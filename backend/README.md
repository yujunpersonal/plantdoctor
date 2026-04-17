# Leafwise API (Cloudflare Worker)

Minimal proxy between the Leafwise iOS app and OpenAI GPT-4o vision.
No database. No KV. No Durable Objects. Rate limiting via native CF bindings.

## Endpoints

- `GET /health` → `200 "ok"`
- `POST /diagnose` → `200 { plantName, ... }` (JSON-schema-enforced)

### Auth (HMAC-SHA256)

Every `/diagnose` request must include:

| Header | Value |
| --- | --- |
| `X-PD-Timestamp` | Unix seconds |
| `X-PD-Device` | Stable per-device UUID (iOS `identifierForVendor`) |
| `X-PD-Signature` | Lowercase hex `HMAC-SHA256(SHARED_SECRET, "{ts}\n{device}\n{sha256(body)}")` |

Requests with a timestamp more than 5 minutes off are rejected.

### Request body

```json
{ "imageBase64": "<base64 JPEG>", "mime": "image/jpeg", "locale": "en-US" }
```

## Setup

```bash
npm install
cp .dev.vars.example .dev.vars
# fill in OPENAI_API_KEY and SHARED_SECRET in .dev.vars

npm run dev          # wrangler dev on http://localhost:8787
```

## Smoke test

```bash
SHARED_SECRET=<your-secret> IMAGE=./sample.jpg \
  npx tsx test/sign.ts http://localhost:8787/diagnose
```

## Deploy

```bash
wrangler login
wrangler secret put OPENAI_API_KEY
wrangler secret put SHARED_SECRET     # SAME value baked into iOS Secrets.swift
wrangler deploy
```

URL will be `https://plantdoctor-api.<account>.workers.dev` — paste that into
`plantdoctor/Shared/Secrets.swift`.

## Rate limiting

CF Rate Limiting bindings cap at 60-second periods, so we approximate:

| Spec | Binding |
| --- | --- |
| Global 10 000/hour | `RL_GLOBAL` 200 per 60s |
| Per-device 100/hour | `RL_DEVICE` 2 per 60s |

The iOS client enforces an additional true-rolling 100/hour hard cap per device.
If you need tighter server-side hourly enforcement, add a Durable Object
counter — intentionally out of scope for v1.
