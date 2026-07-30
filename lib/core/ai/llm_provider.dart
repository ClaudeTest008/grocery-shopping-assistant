import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../network/dio_client.dart';
import 'anthropic_client.dart';
import 'llm_client.dart';
import 'mock_llm_client.dart';
import 'openai_client.dart';
import 'proxy_llm_client.dart';

/// Selects the LLM backend from configuration. Add a provider by
/// implementing [LlmClient] and extending this switch — nothing else in
/// the app changes.
///
/// Resolution order is a security decision, not a convenience one:
///
/// 1. `LLM_PROVIDER=proxy` (or any Supabase-configured build that does
///    not explicitly opt into a direct provider) → the `ai-proxy` edge
///    function. The API key stays server-side and never ships in the
///    binary; on web this is also the only path that works at all,
///    because browsers CORS-block direct provider calls.
/// 2. `anthropic` / `openai` with an `LLM_API_KEY` → direct calls.
///    Development convenience only — the key is embedded in the build,
///    so never use this for anything distributed.
/// 3. Otherwise → the deterministic mock (demo mode).
final llmClientProvider = Provider<LlmClient>((ref) {
  final dio = ref.watch(dioProvider);
  return switch (AppConfig.llmProvider) {
    'proxy' when AppConfig.hasSupabase => ProxyLlmClient(
      dio: dio,
      supabase: Supabase.instance.client,
    ),
    'anthropic' when AppConfig.llmApiKey.isNotEmpty => AnthropicClient(
      dio: dio,
      apiKey: AppConfig.llmApiKey,
      model: AppConfig.llmModel,
    ),
    'openai' when AppConfig.llmApiKey.isNotEmpty => OpenAiClient(
      dio: dio,
      apiKey: AppConfig.llmApiKey,
      model: AppConfig.llmModel,
    ),
    // An explicit mock request stays mock, even on a configured build.
    'mock' => const MockLlmClient(),
    // A backend without an explicit provider choice gets the safe path
    // by default rather than silently degrading to the mock.
    _ when AppConfig.hasSupabase && AppConfig.llmApiKey.isEmpty =>
      ProxyLlmClient(dio: dio, supabase: Supabase.instance.client),
    _ => const MockLlmClient(),
  };
});
