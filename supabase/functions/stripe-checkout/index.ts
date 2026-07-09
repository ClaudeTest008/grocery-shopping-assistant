// Creates a Stripe PaymentIntent for the premium subscription and
// returns its client secret for the mobile PaymentSheet.
// Secrets: STRIPE_SECRET_KEY. Optional: PREMIUM_PRICE_CENTS (default 499).
import Stripe from "npm:stripe@17";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader } } },
  );
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) {
    return json({ error: "Unauthorized" }, 401);
  }

  const secretKey = Deno.env.get("STRIPE_SECRET_KEY");
  if (!secretKey) return json({ error: "Payments not configured" }, 503);

  const stripe = new Stripe(secretKey);
  const amount = Number(Deno.env.get("PREMIUM_PRICE_CENTS") ?? "499");

  try {
    const intent = await stripe.paymentIntents.create({
      amount,
      currency: "usd",
      metadata: { user_id: user.id, product: "premium_monthly" },
      automatic_payment_methods: { enabled: true },
    });
    return json({ clientSecret: intent.client_secret });
  } catch (e) {
    console.error("stripe error:", e);
    return json({ error: "Payment setup failed" }, 502);
  }
});

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json" },
  });
}
