import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_message.dart';

/// Service responsable de la communication avec l'API Gemini.
///
/// Utilise l'endpoint REST generateContent (gratuit via Google AI Studio).
class ChatbotService {
  /// Instruction système : cadre le comportement du bot pour un contexte
  /// d'accompagnement de patients en addictologie. Le bot doit rester
  /// bienveillant, ne jamais remplacer un vrai psychologue, et rediriger
  /// vers un professionnel ou une ligne d'aide en cas de détresse.
  static const String _systemInstruction = '''
Tu es l'assistant virtuel de l'application Força, une app d'accompagnement
pour personnes en difficulté avec une dépendance (alcool, tabac, jeux,
substances, etc.).

Règles à respecter strictement :
- Sois bienveillant, à l'écoute, sans jugement.
- Tu peux donner des informations générales sur les dépendances et des
  conseils de bien-être (respiration, gestion du stress, hygiène de vie).
- Tu n'es PAS un psychologue et tu ne remplaces jamais un vrai professionnel
  de santé. Rappelle-le si le patient pose une question clinique précise
  ou évoque une situation grave.
- Si le patient exprime une détresse importante, des idées suicidaires ou
  un danger immédiat, encourage-le fermement à contacter immédiatement un
  professionnel de santé, les urgences, ou une ligne d'écoute, et reste
  une présence calme et rassurante dans ta réponse.
- Réponds en français par défaut, ou dans la langue utilisée par le patient.
- Reste concis (quelques phrases), clair, chaleureux.
''';

  final http.Client _client;

  ChatbotService({http.Client? client}) : _client = client ?? http.Client();

  /// Envoie l'historique de la conversation à Gemini et retourne la réponse.
  ///
  /// [history] doit contenir les messages précédents (dans l'ordre),
  /// le dernier élément étant le message du patient auquel il faut répondre.
  Future<String> sendMessage(List<ChatMessage> history) async {
    if (ApiConfig.geminiApiKey.isEmpty ||
        ApiConfig.geminiApiKey == 'COLLE_TA_CLE_API_ICI') {
      throw ChatbotException(
        "Clé API manquante. Ajoute ta clé Gemini dans lib/config/api_config.dart",
      );
    }

    // Jusqu'à 3 tentatives en cas de code 503 (serveur Gemini surchargé,
    // erreur temporaire côté Google très fréquente sur le plan gratuit).
    ChatbotException? lastError;
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        return await _sendOnce(history);
      } on _ServerOverloadedException {
        lastError = ChatbotException(
          "Le service IA est surchargé en ce moment. Réessaie dans "
          "quelques secondes.",
        );
        if (attempt < 3) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }
    throw lastError!;
  }

  Future<String> _sendOnce(List<ChatMessage> history) async {
    final contents = history
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'parts': [
                {'text': m.text}
              ],
            })
        .toList();

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': _systemInstruction}
        ]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 512,
      },
    });

    try {
      final response = await _client
          .post(
            Uri.parse(ApiConfig.endpoint),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': ApiConfig.geminiApiKey,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final candidates = data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          throw ChatbotException("Le chatbot n'a pas pu générer de réponse.");
        }
        final parts = candidates[0]['content']['parts'] as List;
        final text = parts.map((p) => p['text'] ?? '').join();
        if (text.trim().isEmpty) {
          throw ChatbotException("Réponse vide reçue du chatbot.");
        }
        return text.trim();
      } else if (response.statusCode == 429) {
        throw ChatbotException(
          "Limite de requêtes gratuites atteinte. Réessaie dans quelques instants.",
        );
      } else if (response.statusCode == 503) {
        throw _ServerOverloadedException();
      } else if (response.statusCode == 400 || response.statusCode == 403) {
        throw ChatbotException(
          "Clé API invalide ou requête refusée (code ${response.statusCode}).",
        );
      } else {
        throw ChatbotException(
          "Erreur serveur (code ${response.statusCode}). Réessaie plus tard.",
        );
      }
    } on ChatbotException {
      rethrow;
    } on _ServerOverloadedException {
      rethrow;
    } catch (e) {
      throw ChatbotException(
        "Impossible de contacter le chatbot. Vérifie ta connexion internet.",
      );
    }
  }
}

/// Exception interne utilisée pour déclencher le retry automatique sur
/// erreur 503 dans sendMessage(). Ne remonte jamais jusqu'à l'UI.
class _ServerOverloadedException implements Exception {}

class ChatbotException implements Exception {
  final String message;
  ChatbotException(this.message);

  @override
  String toString() => message;
}
