export interface RateLimiter {
  limit: (args: { key: string }) => Promise<{ success: boolean }>;
}

export interface RateLimitResult {
  ok: boolean;
  scope?: "global" | "device";
}

export async function enforceRateLimits(
  rlGlobal: RateLimiter,
  rlDevice: RateLimiter,
  deviceId: string,
): Promise<RateLimitResult> {
  const globalCheck = await rlGlobal.limit({ key: "global" });
  if (!globalCheck.success) return { ok: false, scope: "global" };

  const deviceCheck = await rlDevice.limit({ key: `device:${deviceId}` });
  if (!deviceCheck.success) return { ok: false, scope: "device" };

  return { ok: true };
}
