import '../api/api_client.dart';

class AuthRepository {
  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String role = 'patient',
  }) async {
    return _apiClient.post(
      '/login',
      body: {
        'email': email,
        'password': password,
        'role': role,
      },
    );
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    String? passwordConfirmation,
    String role = 'patient',
  }) async {
    return _apiClient.post(
      '/register',
      body: {
        'name': fullName,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation ?? password,
        'role': role,
      },
    );
  }

  Future<Map<String, dynamic>> logout({
    required String token,
  }) async {
    return _apiClient.post(
      '/logout',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Map<String, dynamic>> getCurrentUser({
    required String token,
  }) async {
    return _apiClient.get(
      '/me',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
