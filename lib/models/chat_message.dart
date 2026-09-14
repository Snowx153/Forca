/// Représente un message dans la conversation avec le chatbot.
class ChatMessage {
  final String text;
  final bool isUser; // true = message du patient, false = réponse du bot
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();
}
