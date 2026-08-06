// Scheduled function (cron via Supabase dashboard: e.g. hourly).
// Finds products whose current price dropped >= 15% below their 90-day
// average and notifies users who favorited them. Also flags coupons
// expiring within 48h for users who clipped them.
import { createClient } from "npm:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  // Deployed with verify_jwt=false so the scheduler can call it — which
  // means the URL alone must not be enough. The scheduler sends a shared
  // secret; anyone else gets a 401. Fail closed when unconfigured.
  const cronSecret = Deno.env.get("CRON_SECRET");
  if (!cronSecret || req.headers.get("x-cron-secret") !== cronSecret) {
    return new Response("Unauthorized", { status: 401 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // Dedup window: an hourly cron must not re-notify the same user about
  // the same drop/coupon every run. One query, then set lookups.
  const dayAgo = new Date(Date.now() - 24 * 3600 * 1000).toISOString();
  const { data: recent } = await supabase
    .from("notifications")
    .select("user_id, type, title")
    .gte("created_at", dayAgo)
    .in("type", ["priceDrop", "couponExpiring"]);
  const seen = new Set(
    (recent ?? []).map((r) => `${r.user_id}|${r.type}|${r.title}`),
  );

  const notifications: Array<Record<string, unknown>> = [];
  const push = (n: {
    user_id: string;
    type: string;
    title: string;
    body: string;
    route: string;
  }) => {
    const key = `${n.user_id}|${n.type}|${n.title}`;
    if (seen.has(key)) return;
    seen.add(key);
    notifications.push(n);
  };

  // --- Price drops -----------------------------------------------------
  const { data: drops, error: dropsError } = await supabase.rpc(
    "find_price_drops",
    { threshold_percent: 15 },
  );
  if (dropsError) console.error("find_price_drops:", dropsError.message);

  for (const drop of drops ?? []) {
    const { data: fans } = await supabase
      .from("favorites")
      .select("user_id")
      .eq("product_id", drop.product_id);
    for (const fan of fans ?? []) {
      push({
        user_id: fan.user_id,
        type: "priceDrop",
        title: `Price drop: ${drop.product_name}`,
        body:
          `Now $${drop.price} at ${drop.store_name} — ${drop.percent_below}% below its 90-day average.`,
        route: `/products/${drop.product_id}`,
      });
    }
  }

  // --- Expiring clipped coupons -----------------------------------------
  const soon = new Date(Date.now() + 48 * 3600 * 1000).toISOString();
  const { data: expiring } = await supabase
    .from("user_coupons")
    .select("user_id, coupons!inner(id, title, expires_at)")
    .lt("coupons.expires_at", soon)
    .gt("coupons.expires_at", new Date().toISOString());

  for (const clip of expiring ?? []) {
    const coupon = clip.coupons as unknown as {
      id: string;
      title: string;
    };
    push({
      user_id: clip.user_id,
      type: "couponExpiring",
      // Coupon title in the notification title: it doubles as the dedup
      // key, so two different coupons still both notify.
      title: `Coupon expiring soon: ${coupon.title}`,
      body: `"${coupon.title}" expires within 48 hours.`,
      route: "/coupons",
    });
  }

  if (notifications.length > 0) {
    const { error } = await supabase.from("notifications").insert(
      notifications,
    );
    if (error) console.error("insert notifications:", error.message);
  }

  return new Response(
    JSON.stringify({ created: notifications.length }),
    { headers: { "content-type": "application/json" } },
  );
});
