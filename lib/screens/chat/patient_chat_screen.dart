import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../widgets/language_switch.dart';

/// Ã‰cran de chat texte entre un patient et le psychologue.
/// UtilisÃ© des deux cÃ´tÃ©s pour la MÃŠME conversation, identifiÃ©e par
/// [patientId] :
///  - cÃ´tÃ© patient : isPsy = false
///  - cÃ´tÃ© psychologue : isPsy = true
class PatientChatScreen extends StatefulWidget {
  final String patientId;
  final String contactName; // nom de l'interlocuteur affichÃ© en haut
  final String contactPhotoUrl; // photo de l'interlocuteur (peut Ãªtre vide)
  final bool isPsy;

  const PatientChatScreen({
    super.key,
    required this.patientId,
    required this.contactName,
    required this.isPsy,
    this.contactPhotoUrl = '',
  });

  @override
  State<PatientChatScreen> createState() => _PatientChatScreenState();
}

class _PatientChatScreenState extends State<PatientChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(AppState appState) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    appState.envoyerMessage(
      patientId: widget.patientId,
      text: text,
      fromPsy: widget.isPsy,
    );
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _appeler() async {
    final url = Uri.parse('https://meet.google.com/new');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final t = appState.t;
    final msgs = appState.messagesForPatient(widget.patientId);
    _scrollToBottom();

    return Directionality(
      textDirection: appState.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              backgroundImage: widget.contactPhotoUrl.isNotEmpty
                  ? AssetImage(widget.contactPhotoUrl)
                  : null,
              child: widget.contactPhotoUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(widget.contactName,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
        actions: [
          const LanguageSwitch(),
          IconButton(
            icon: const Icon(Icons.videocam_rounded, color: Colors.white),
            tooltip: 'Appeler',
            onPressed: _appeler,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: msgs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        t('chat_empty'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textLight),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: msgs.length,
                    itemBuilder: (context, index) {
                      final m = msgs[index];
                      final isMine = m.fromPsy == widget.isPsy;
                      return _Bubble(text: m.text, isMine: isMine);
                    },
                  ),
          ),
          _buildInputBar(appState, t),
        ],
      ),
      ),
    );
  }

  Widget _buildInputBar(AppState appState, String Function(String) t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(appState),
                decoration: InputDecoration(
                  hintText: t('chat_hint'),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () => _send(appState),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool isMine;
  const _Bubble({required this.text, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          border: isMine ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMine ? Colors.white : AppColors.textDark,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

