/// Configuration de l'API Gemini (Google AI Studio - gratuit).
///
/// ⚠️ IMPORTANT SÉCURITÉ :
/// Ne mets JAMAIS ta vraie clé API en dur dans ce fichier si le code est
/// public (GitHub, etc.). Pour le développement/démo c'est acceptable,
/// mais pour la mise en ligne réelle, utilise plutôt --dart-define :
///
///   flutter run --dart-define=GEMINI_API_KEY=ta_cle_ici
///   flutter build apk --release --dart-define=GEMINI_API_KEY=ta_cle_ici
///
/// et remplace la ligne ci-dessous par :
///   static const String apiKey =
///       String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
class ApiConfig {
  // 👉 Colle ta clé API obtenue sur https://aistudio.google.com/apikey
  static const String geminiApiKey = 'AQ.Ab8RN6Ita_d5rFUPmiFgBA_WhWDwkGms4InFNRSOzo-tS8TJ4g';

  // Alias "latest" recommandé : pointe toujours vers le Flash actuel
  // même si Google renomme/retire une version précise (évite les 404).
  static const String geminiModel = 'gemini-flash-latest';

  static String get endpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';
}
