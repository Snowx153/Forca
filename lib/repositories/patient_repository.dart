import '../api/api_client.dart';

class PatientRepository {
  PatientRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getProfile({required String token}) async {
    return _apiClient.get(
      '/patients/me',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return _apiClient.put(
      '/patients/me',
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: data,
    );
  }

  Future<Map<String, dynamic>> getQuestionnaireAnswers({
    required String token,
  }) async {
    return _apiClient.get(
      '/patients/me/questionnaire-answers',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
