// Stripe webhook: the only writer of users.is_premium.
// Until this existed, nothing server-side ever fulfilled a payment —
// and the RLS fix in 20260806000000 removed the client's ability to
// (illegitimately) set the flag itself.
// Secrets: STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET.
// Deployed with verify_jwt=false: Stripe cannot send a Supabase JWT;
// authentication is the webhook signature instead.
import Stripe from "npm:stripe@17";
import { createClient } from "npm:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const secretKey = Deno.env.get("STRIPE_SECRET_KEY");
  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
  if (!secretKey || !webhookSecret) {
    return new Response("Not configured", { status: 503 });
  }

  const signature = req.headers.get("stripe-signature");
  if (!signature) return new Response("Missing signature", { status: 400 });

  const stripe = new Stripe(secretKey);
  const body = await req.text();
  let event: Stripe.Event;
  try {
    // Async variant: Deno's WebCrypto has no sync HMAC.
    event = await stripe.webhooks.constructEventAsync(
      body,
      signature,
      webhookSecret,
    );
  } catch {
    return new Response("Invalid signature", { status: 400 });
  }

  const setPremium = async (userId: string, value: boolean) => {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );
    const { error } = await supabase
      .from("users")
      .update({ is_premium: value })
      .eq("id", userId);
    return error;
  };

  if (event.type === "payment_intent.succeeded") {
    const intent = event.data.object as Stripe.PaymentIntent;
    // Only intents this backend created carry our metadata shape
    // (stripe-checkout sets both fields); ignore anything else.
    if (
      intent.metadata?.user_id &&
      intent.metadata?.product === "premium_monthly"
    ) {
      const error = await setPremium(intent.metadata.user_id, true);
      if (error) {
        console.error("premium grant failed:", error.message);
        // Non-2xx makes Stripe retry with backoff — the payment
        // succeeded, so fulfillment must eventually happen.
        return new Response("Fulfillment failed", { status: 500 });
      }
    }
  }

  // The grant must not be one-way: money returned means the
  // entitlement goes with it. Charges don't inherit PaymentIntent
  // metadata, so resolve the intent to find whose premium this was.
  if (
    event.type === "charge.refunded" ||
    event.type === "charge.dispute.created"
  ) {
    const object = event.data.object as { payment_intent?: string | null };
    const intentId = object.payment_intent;
    if (typeof intentId === "string") {
      try {
        const intent = await stripe.paymentIntents.retrieve(intentId);
        if (
          intent.metadata?.user_id &&
          intent.metadata?.product === "premium_monthly"
        ) {
          const error = await setPremium(intent.metadata.user_id, false);
          if (error) {
            console.error("premium revoke failed:", error.message);
            return new Response("Revoke failed", { status: 500 });
          }
        }
      } catch (e) {
        console.error("intent lookup failed:", e);
        return new Response("Lookup failed", { status: 500 });
      }
    }
  }

  return new Response(JSON.stringify({ received: true }), {
    headers: { "content-type": "application/json" },
  });
});
