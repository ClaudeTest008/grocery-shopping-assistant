// Scheduled function (cron via Supabase dashboard: e.g. hourly).
// Finds products whose current price dropped >= 15% below their 90-day
// average and notifies users who favorited them. Also flags coupons
// expiring within 48h for users who clipped them.
import { createClient } from "npm:@supabase/supabase-js@2";

Deno.serve(async (_req) => {
  // Service role: this function is invoked by the platform scheduler,
  // not by end users.
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const notifications: Array<Record<string, unknown>> = [];

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
      notifications.push({
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
    notifications.push({
      user_id: clip.user_id,
      type: "couponExpiring",
      title: "Coupon expiring soon",
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
