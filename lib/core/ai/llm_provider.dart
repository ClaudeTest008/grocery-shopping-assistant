import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../network/dio_client.dart';
import 'anthropic_client.dart';
import 'llm_client.dart';
import 'mock_llm_client.dart';
import 'openai_client.dart';

/// Selects the LLM backend from configuration. Add a provider by
/// implementing [LlmClient] and extending this switch — nothing else in
/// the app changes.
final llmClientProvider = Provider<LlmClient>((ref) {
  final dio = ref.watch(dioProvider);
  return switch (AppConfig.llmProvider) {
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
    _ => const MockLlmClient(),
  };
});
