import '../api/api_client.dart';

class QuestionnaireRepository {
  QuestionnaireRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getInitialQuestionnaire({
    required String token,
  }) async {
    return _apiClient.get(
      '/questionnaires/initial',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Map<String, dynamic>> submitInitialAnswers({
    required String token,
    required List<Map<String, dynamic>> answers,
  }) async {
    return _apiClient.post(
      '/questionnaires/initial/answers',
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {'answers': answers},
    );
  }

  Future<Map<String, dynamic>> getQuestionnaires({required String token}) async {
    return _apiClient.get(
      '/questionnaires',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Map<String, dynamic>> submitAnswers({
    required String token,
    required int questionnaireId,
    required Map<String, dynamic> answers,
  }) async {
    return _apiClient.post(
      '/questionnaires/$questionnaireId/answers',
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'answers': answers,
      },
    );
  }
}
