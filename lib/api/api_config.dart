/// Configuration centralisée pour le backend Laravel futur.
///
/// Les valeurs sont séparées entre environnement de développement et
/// production pour éviter de modifier l'application partout dans le code.
class ApiConfig {
  static const String _devBaseUrl = 'http://127.0.0.1:8000/api';
  static const String _prodBaseUrl = 'https://api.forca.example.com/api';

  static const bool isProduction = false;

  static String get baseUrl => isProduction ? _prodBaseUrl : _devBaseUrl;

  static String get authBaseUrl => '$baseUrl/auth';

  static String get patientsBaseUrl => '$baseUrl/patients';

  static String get psychologistsBaseUrl => '$baseUrl/psychologists';

  static String get appointmentsBaseUrl => '$baseUrl/appointments';

  static String get questionnairesBaseUrl => '$baseUrl/questionnaires';

  static String get messagesBaseUrl => '$baseUrl/messages';

  static String get subscriptionsBaseUrl => '$baseUrl/subscriptions';

  static String get paymentsBaseUrl => '$baseUrl/payments';
}
