import '../api/api_client.dart';

class SubscriptionRepository {
  SubscriptionRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getCurrentSubscription({
    required String token,
  }) async {
    return _apiClient.get(
      '/subscriptions/me',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Map<String, dynamic>> createSubscription({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return _apiClient.post(
      '/subscriptions',
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: data,
    );
  }

  Future<Map<String, dynamic>> getPayments({
    required String token,
  }) async {
    return _apiClient.get(
      '/payments/me',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
