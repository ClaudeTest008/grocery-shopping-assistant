import 'package:dio/dio.dart';

import '../errors/failures.dart';
import 'llm_client.dart';

class AnthropicClient implements LlmClient {
  AnthropicClient({
    required Dio dio,
    required String apiKey,
    String? model,
  })  : _dio = dio,
        _apiKey = apiKey,
        _model = (model == null || model.isEmpty) ? defaultModel : model;

  static const defaultModel = 'claude-sonnet-5';

  final Dio _dio;
  final String _apiKey;
  final String _model;

  @override
  String get providerName => 'anthropic';

  @override
  Future<String> complete(LlmRequest request) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        'https://api.anthropic.com/v1/messages',
        options: Options(headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        }),
        data: {
          'model': _model,
          'max_tokens': request.maxTokens,
          'temperature': request.temperature,
          if (request.system != null) 'system': request.system,
          'messages': [
            for (final m in request.messages)
              {'role': m.role, 'content': m.content},
          ],
        },
      );
      final content = res.data?['content'] as List<dynamic>?;
      final text = content
          ?.cast<Map<String, dynamic>>()
          .where((b) => b['type'] == 'text')
          .map((b) => b['text'] as String)
          .join();
      if (text == null || text.isEmpty) {
        throw const AiFailure('Empty response from Anthropic');
      }
      return text;
    } on DioException catch (e) {
      throw e.error is Failure
          ? e.error as Failure
          : AiFailure('Anthropic request failed', e);
    }
  }
}
