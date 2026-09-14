import '../api/api_client.dart';

class MessageRepository {
  MessageRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getMessages({
    required String token,
    required String patientId,
  }) async {
    return _apiClient.get(
      '/messages',
      headers: {
        'Authorization': 'Bearer $token',
      },
      queryParameters: {
        'patient_id': patientId,
      },
    );
  }

  Future<Map<String, dynamic>> sendMessage({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return _apiClient.post(
      '/messages',
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: data,
    );
  }
}
