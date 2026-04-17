// Local signing helper for manual smoke tests.
// Usage:
//   SHARED_SECRET=... DEVICE=... IMAGE=./path/to/plant.jpg \
//     npx tsx test/sign.ts http://localhost:8787/diagnose

import { createHash, createHmac, randomUUID } from "node:crypto";
import { readFileSync } from "node:fs";

const url = process.argv[2];
if (!url) {
  console.error("usage: tsx test/sign.ts <url>");
  process.exit(1);
}

const secret = process.env.SHARED_SECRET;
if (!secret) throw new Error("SHARED_SECRET env required");

const imagePath = process.env.IMAGE;
if (!imagePath) throw new Error("IMAGE env (path to JPEG) required");

const deviceId = process.env.DEVICE ?? randomUUID();
const imageBytes = readFileSync(imagePath);
const imageBase64 = imageBytes.toString("base64");

const body = JSON.stringify({
  imageBase64,
  mime: "image/jpeg",
  locale: "en-US",
});

const timestamp = Math.floor(Date.now() / 1000).toString();
const bodyHash = createHash("sha256").update(body).digest("hex");
const message = `${timestamp}\n${deviceId}\n${bodyHash}`;
const signature = createHmac("sha256", secret).update(message).digest("hex");

const res = await fetch(url, {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "X-PD-Timestamp": timestamp,
    "X-PD-Device": deviceId,
    "X-PD-Signature": signature,
  },
  body,
});

console.log("status:", res.status);
console.log("body:", await res.text());
