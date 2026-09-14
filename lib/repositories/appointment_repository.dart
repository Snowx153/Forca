import '../api/api_client.dart';

class AppointmentRepository {
  AppointmentRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getAppointments({required String token}) async {
    return _apiClient.get(
      '/appointments',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Map<String, dynamic>> createAppointment({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return _apiClient.post(
      '/appointments',
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: data,
    );
  }

  Future<Map<String, dynamic>> updateAppointment({
    required String token,
    required String appointmentId,
    required Map<String, dynamic> data,
  }) async {
    return _apiClient.put(
      '/appointments/$appointmentId',
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: data,
    );
  }

  Future<Map<String, dynamic>> cancelAppointment({
    required String token,
    required String appointmentId,
  }) async {
    return _apiClient.delete(
      '/appointments/$appointmentId',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
