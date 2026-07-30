// Permanently deletes the calling user's account and all their data.
//
// Required for App Store 5.1.1(v) and Google Play account-deletion
// policies. The caller proves identity with their own JWT; the deletion
// itself needs the service role because a user cannot remove their own
// auth record. Every user-owned table references public.users with
// ON DELETE CASCADE, so removing the auth user removes everything.
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
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  // Identify the caller from their own session.
  const authHeader = req.headers.get("Authorization") ?? "";
  const userClient = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader } } },
  );
  const { data: { user }, error: authError } = await userClient.auth.getUser();
  if (authError || !user) {
    return json({ error: "Unauthorized" }, 401);
  }

  // Delete with the service role. auth.users -> public.users cascades
  // through every owned table (lists, items, pantry, receipts, plans,
  // favourites, notifications, coupons-clips, preferences, tokens).
  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { error } = await admin.auth.admin.deleteUser(user.id);
  if (error) {
    console.error("delete-account failed:", error.message);
    return json({ error: "Deletion failed" }, 500);
  }

  return json({ deleted: true });
});

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json" },
  });
}
