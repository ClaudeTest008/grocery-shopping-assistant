import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../errors/failures.dart';
import 'llm_client.dart';

/// Routes completions through the `ai-proxy` Supabase edge function.
///
/// This is the only LLM path suitable for release builds: the provider
/// API key lives server-side, the function validates the caller's
/// session, and — decisively for the deployed web target — it avoids
/// the CORS block that direct `api.anthropic.com` calls hit in a
/// browser. The direct [AnthropicClient]/[OpenAiClient] remain for
/// local development with a personal key.
class ProxyLlmClient implements LlmClient {
  ProxyLlmClient({required this._dio, required this._supabase});

  final Dio _dio;
  final SupabaseClient _supabase;

  @override
  String get providerName => 'proxy';

  @override
  Future<String> complete(LlmRequest request) async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      throw const AuthFailure('Sign in to use the assistant');
    }
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '${AppConfig.supabaseUrl}/functions/v1/ai-proxy',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'apikey': AppConfig.supabaseAnonKey,
          },
        ),
        data: {
          'messages': [
            for (final m in request.messages)
              {'role': m.role, 'content': m.content},
          ],
          if (request.system != null) 'system': request.system,
          'max_tokens': request.maxTokens,
          'temperature': request.temperature,
        },
      );
      final text = res.data?['text'] as String?;
      if (text == null || text.isEmpty) {
        throw const AiFailure('Empty response from AI service');
      }
      return text;
    } on DioException catch (e) {
      throw e.error is Failure
          ? e.error as Failure
          : AiFailure('AI request failed', e);
    }
  }
}
