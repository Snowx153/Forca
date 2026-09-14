import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../widgets/language_switch.dart';

/// Page de contact.
/// Accès conditionné : seul le compte psychologue autorisé
/// (contactAuthorizedEmail) peut proposer des séances Google Meet.
/// Les patients peuvent envoyer un message mais ne voient pas les
/// outils de gestion des séances.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _messageCtrl = TextEditingController();
  final _meetLinkCtrl = TextEditingController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    _meetLinkCtrl.dispose();
    super.dispose();
  }

  Future<void> _openMeet(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAuthorizedPsy = appState.currentPsychologue?.email ==
        AppState.contactAuthorizedEmail;
    final t = appState.t;

    return Directionality(
      textDirection: appState.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      appBar: AppBar(title: Text(t('contact_appbar')), actions: const [LanguageSwitch()]),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded,
                      color: AppColors.primary, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t('contact_intro'),
                      style: TextStyle(color: AppColors.textDark, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(t('contact_your_message'),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 10),
            TextField(
              controller: _messageCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: t('contact_hint'),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                if (_messageCtrl.text.trim().isEmpty) return;
                _messageCtrl.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t('contact_sent')),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Text(t('contact_send')),
            ),
            const SizedBox(height: 30),
            if (isAuthorizedPsy) ...[
              const Divider(),
              const SizedBox(height: 10),
              Text(t('contact_propose_session_title'),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 6),
              Text(
                t('contact_propose_session_desc'),
                style: TextStyle(color: AppColors.textLight, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _meetLinkCtrl,
                decoration: InputDecoration(
                  hintText: t('contact_meet_link_hint'),
                  prefixIcon: Icon(Icons.videocam_outlined),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        // Ouvre l'interface de création d'une réunion Meet
                        await _openMeet('https://meet.google.com/new');
                      },
                      child: Text(t('contact_create_meet')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_meetLinkCtrl.text.trim().isEmpty) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t('contact_session_proposed')),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        _meetLinkCtrl.clear();
                      },
                      child: Text(t('contact_propose')),
                    ),
                  ),
                ],
              ),
            ] else if (appState.currentPsychologue != null) ...[
              const SizedBox(height: 10),
              Text(
                t('contact_not_authorized'),
                style: TextStyle(color: AppColors.textLight, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
}
