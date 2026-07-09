// AI proxy edge function.
// Keeps LLM API keys server-side: the app can target this endpoint
// instead of calling providers directly. Provider chosen by env:
//   LLM_PROVIDER = anthropic | openai   (secret: LLM_API_KEY)
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface LlmMessage {
  role: "user" | "assistant";
  content: string;
}

interface CompletionRequest {
  messages: LlmMessage[];
  system?: string;
  max_tokens?: number;
  temperature?: number;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // Require a valid Supabase user session.
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

  let body: CompletionRequest;
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON body" }, 400);
  }
  if (!Array.isArray(body.messages) || body.messages.length === 0) {
    return json({ error: "messages required" }, 400);
  }
  const maxTokens = Math.min(body.max_tokens ?? 1024, 4096);

  const provider = Deno.env.get("LLM_PROVIDER") ?? "anthropic";
  const apiKey = Deno.env.get("LLM_API_KEY");
  if (!apiKey) return json({ error: "LLM not configured" }, 503);

  try {
    const text = provider === "openai"
      ? await openai(apiKey, body, maxTokens)
      : await anthropic(apiKey, body, maxTokens);
    return json({ text });
  } catch (e) {
    console.error("LLM call failed:", e);
    return json({ error: "Upstream LLM error" }, 502);
  }
});

async function anthropic(
  apiKey: string,
  body: CompletionRequest,
  maxTokens: number,
): Promise<string> {
  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model: Deno.env.get("LLM_MODEL") ?? "claude-sonnet-5",
      max_tokens: maxTokens,
      temperature: body.temperature ?? 0.7,
      system: body.system,
      messages: body.messages,
    }),
  });
  if (!res.ok) throw new Error(`anthropic ${res.status}`);
  const data = await res.json();
  return data.content
    .filter((b: { type: string }) => b.type === "text")
    .map((b: { text: string }) => b.text)
    .join("");
}

async function openai(
  apiKey: string,
  body: CompletionRequest,
  maxTokens: number,
): Promise<string> {
  const res = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model: Deno.env.get("LLM_MODEL") ?? "gpt-4o-mini",
      max_tokens: maxTokens,
      temperature: body.temperature ?? 0.7,
      messages: [
        ...(body.system ? [{ role: "system", content: body.system }] : []),
        ...body.messages,
      ],
    }),
  });
  if (!res.ok) throw new Error(`openai ${res.status}`);
  const data = await res.json();
  return data.choices[0].message.content;
}

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json" },
  });
}
