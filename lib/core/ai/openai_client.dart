import 'package:dio/dio.dart';

import '../errors/failures.dart';
import 'llm_client.dart';

class OpenAiClient implements LlmClient {
  OpenAiClient({required this._dio, required this._apiKey, String? model})
    : _model = (model == null || model.isEmpty) ? defaultModel : model;

  static const defaultModel = 'gpt-4o-mini';

  final Dio _dio;
  final String _apiKey;
  final String _model;

  @override
  String get providerName => 'openai';

  @override
  Future<String> complete(LlmRequest request) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        'https://api.openai.com/v1/chat/completions',
        options: Options(headers: {'Authorization': 'Bearer $_apiKey'}),
        data: {
          'model': _model,
          'max_tokens': request.maxTokens,
          'temperature': request.temperature,
          if (request.jsonMode) 'response_format': {'type': 'json_object'},
          'messages': [
            if (request.system != null)
              {'role': 'system', 'content': request.system},
            for (final m in request.messages)
              {'role': m.role, 'content': m.content},
          ],
        },
      );
      final choices = res.data?['choices'] as List<dynamic>?;
      final message =
          (choices?.firstOrNull as Map<String, dynamic>?)?['message']
              as Map<String, dynamic>?;
      final text = message?['content'] as String?;
      if (text == null || text.isEmpty) {
        throw const AiFailure('Empty response from OpenAI');
      }
      return text;
    } on DioException catch (e) {
      throw e.error is Failure
          ? e.error as Failure
          : AiFailure('OpenAI request failed', e);
    }
  }
}
