/// Provider-agnostic LLM abstraction.
///
/// The app talks only to [LlmClient]; concrete providers (Anthropic,
/// OpenAI, a Supabase edge-function proxy, or the offline mock) are
/// selected by configuration. Swapping providers never touches feature
/// code.
library;

class LlmMessage {
  const LlmMessage.user(this.content) : role = 'user';
  const LlmMessage.assistant(this.content) : role = 'assistant';

  final String role;
  final String content;
}

class LlmRequest {
  const LlmRequest({
    required this.messages,
    this.system,
    this.maxTokens = 1024,
    this.temperature = 0.7,
    this.jsonMode = false,
  });

  final List<LlmMessage> messages;
  final String? system;
  final int maxTokens;
  final double temperature;

  /// Hint that the reply must be a single JSON object/array.
  final bool jsonMode;
}

abstract interface class LlmClient {
  String get providerName;

  Future<String> complete(LlmRequest request);
}

/// Strips markdown fences an LLM may wrap around JSON.
String extractJson(String raw) {
  var s = raw.trim();
  final fence = RegExp(r'^```(?:json)?\s*([\s\S]*?)\s*```$');
  final m = fence.firstMatch(s);
  if (m != null) s = m.group(1)!.trim();
  final start = s.indexOf(RegExp(r'[\[{]'));
  if (start > 0) s = s.substring(start);
  return s;
}
