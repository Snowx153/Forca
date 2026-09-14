import '../api/api_client.dart';

class PsychologistRepository {
  PsychologistRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getProfile({required String token}) async {
    return _apiClient.get(
      '/psychologists/me',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Map<String, dynamic>> getList({required String token}) async {
    return _apiClient.get(
      '/psychologists',
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
      '/psychologists/me',
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: data,
    );
  }
}
