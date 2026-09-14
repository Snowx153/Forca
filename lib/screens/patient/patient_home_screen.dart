import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../models/user_models.dart';
import '../contact/contact_screen.dart';
import '../auth/role_select_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../chat/patient_chat_screen.dart';
import '../../widgets/language_switch.dart';
import 'psy_list_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  Future<void> _joinCall(BuildContext context, RendezVousModel rdv) async {
    final url = Uri.parse(rdv.lienMeet ?? 'https://meet.google.com/new');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final t = appState.t;
    final patient = appState.currentPatient;
    final prochainRdv = appState.prochainRendezVous;
    final tousLesRdv = appState.rendezVousPatient
        .where((r) => r.statut == RendezVousStatut.planifie)
        .toList();
    final monPsy = appState.psychologues.first;

    return Directionality(
      textDirection: appState.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      backgroundColor: AppColors.background,
      // ---------- Bouton flottant : assistant IA ----------
      floatingActionButton: _AiAssistantFab(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        ),
      ),
      body: Column(
        children: [
          // ---------- En-tÃªte avec image de fond + dÃ©gradÃ© ----------
          SizedBox(
            height: 240,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/5.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(
                        gradient: AppGradients.diagonalSplit),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.55),
                        AppColors.secondary.withValues(alpha: 0.25),
                        AppColors.primary.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t('home_title'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const LanguageSwitch(),
                                IconButton(
                              icon: const Icon(Icons.logout_rounded,
                                  color: Colors.white),
                              onPressed: () {
                                appState.logout();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) => const RoleSelectScreen()),
                                  (route) => false,
                                );
                              },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.person,
                                  color: AppColors.primary, size: 30),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patient?.fullName ?? 'Patient',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    patient?.abonnementActif == true
                                        ? t('home_subscription_active')
                                        : t('home_subscription_inactive'),
                                    style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---------- Contenu (fiche arrondie par-dessus le fond) ----------
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 90),
                children: [
                  // ---------- Prochain rendez-vous en avant ----------
            Text(t('home_next_appointment'),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 12),
            if (prochainRdv == null)
              _EmptyAppointmentCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PsyListScreen()),
                ),
              )
            else
              _NextAppointmentCard(
                rdv: prochainRdv,
                psy: appState.psyById(prochainRdv.psyId),
                onJoin: () => _joinCall(context, prochainRdv),
              ),

            // ---------- Planning complet ----------
            if (tousLesRdv.length > 1) ...[
              const SizedBox(height: 24),
              const Text('Tous vos rendez-vous',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark)),
              const SizedBox(height: 12),
              ...tousLesRdv.skip(1).map((rdv) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AppointmentRow(
                      rdv: rdv,
                      psy: appState.psyById(rdv.psyId),
                    ),
                  )),
            ],

            // ---------- Votre psychologue (photo + accÃ¨s rapide) ----------
            const SizedBox(height: 24),
            const Text('Votre psychologue',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 12),
            _PsyProfileCard(
              psy: monPsy,
              onChat: patient == null
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PatientChatScreen(
                            patientId: patient.id,
                            contactName: monPsy.fullName,
                            contactPhotoUrl: monPsy.photoUrl,
                            isPsy: false,
                          ),
                        ),
                      ),
            ),

            const SizedBox(height: 24),
            const Text('Votre profil',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _InfoRow('AnciennetÃ©', patient?.anneesDependance != null
                      ? '${patient!.anneesDependance} an(s)'
                      : '-'),
                  _InfoRow('Substance', patient?.typeDrogue ?? '-'),
                  _InfoRow('FrÃ©quence', patient?.frequence ?? '-'),
                  _InfoRow('QuantitÃ©', patient?.quantite ?? '-', isLast: true),
                ],
              ),
            ),

            // ---------- Actions (menu simplifiÃ©) ----------
            const SizedBox(height: 24),
            const Text('Actions',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.forum_rounded,
              title: 'Parler Ã  un psychologue',
              subtitle:
                  'Consultez les profils et rÃ©servez une sÃ©ance (paiement)',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PsyListScreen()),
              ),
            ),
            const SizedBox(height: 12),
            if (patient != null)
              _ActionTile(
                icon: Icons.chat_bubble_rounded,
                title: 'Contacter mon psychologue',
                subtitle: 'Discuter par message ou lancer un appel vidÃ©o',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PatientChatScreen(
                      patientId: patient.id,
                      contactName: monPsy.fullName,
                      contactPhotoUrl: monPsy.photoUrl,
                      isPsy: false,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.support_agent_rounded,
                    title: 'Contact & sÃ©ances',
                    subtitle:
                        'Contactez votre psychologue, rÃ©servez une sÃ©ance',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ContactScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Bouton flottant "Assistant IA" : icÃ´ne robot + petite bulle "Hello"
/// qui apparaÃ®t quelques secondes aprÃ¨s l'ouverture de l'Ã©cran puis
/// s'estompe, pour attirer l'attention sans gÃªner.
class _AiAssistantFab extends StatefulWidget {
  final VoidCallback onTap;
  const _AiAssistantFab({required this.onTap});

  @override
  State<_AiAssistantFab> createState() => _AiAssistantFabState();
}

class _AiAssistantFabState extends State<_AiAssistantFab> {
  bool _showGreeting = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showGreeting = true);
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showGreeting = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          bottom: 68,
          right: 0,
          child: AnimatedOpacity(
            opacity: _showGreeting ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedSlide(
              offset: _showGreeting ? Offset.zero : const Offset(0, 0.2),
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !_showGreeting,
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'ðŸ¤– Assistant IA â€” Hello ðŸ‘‹',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('ðŸ¤–', style: TextStyle(fontSize: 26)),
                ),
              ),
              // Badge "IA" toujours visible, pour indiquer clairement que
              // c'est une machine (intelligence artificielle) et pas le
              // vrai psychologue.
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Text(
                    'IA',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Carte "Votre psychologue" : affiche la photo, le nom, la spÃ©cialitÃ©,
/// et un accÃ¨s rapide au chat.
class _PsyProfileCard extends StatelessWidget {
  final PsychologueModel psy;
  final VoidCallback? onChat;
  const _PsyProfileCard({required this.psy, required this.onChat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage:
                psy.photoUrl.isNotEmpty ? AssetImage(psy.photoUrl) : null,
            child: psy.photoUrl.isEmpty
                ? const Icon(Icons.person, color: AppColors.primary, size: 30)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(psy.fullName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(psy.specialite,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textLight)),
              ],
            ),
          ),
          if (onChat != null)
            IconButton(
              icon: const Icon(Icons.chat_bubble_rounded,
                  color: AppColors.primary),
              onPressed: onChat,
            ),
        ],
      ),
    );
  }
}

/// Carte mise en avant pour le prochain rendez-vous, avec bouton
/// "Rejoindre l'appel" actif uniquement autour de l'heure prÃ©vue.
class _NextAppointmentCard extends StatelessWidget {
  final RendezVousModel rdv;
  final PsychologueModel psy;
  final VoidCallback onJoin;

  const _NextAppointmentCard({
    required this.rdv,
    required this.psy,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final d = rdv.dateHeure;
    final dateLabel =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final timeLabel =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                backgroundImage: psy.photoUrl.isNotEmpty
                    ? AssetImage(psy.photoUrl)
                    : null,
                child: psy.photoUrl.isEmpty
                    ? const Icon(Icons.person, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(psy.fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    Text(psy.specialite,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.textLight)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$dateLabel  â€¢  $timeLabel',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.videocam_rounded, color: Colors.white),
              label: Text(
                rdv.peutRejoindre
                    ? "Rejoindre l'appel"
                    : "SÃ©ance Ã  venir",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    rdv.peutRejoindre ? AppColors.primary : Colors.grey.shade400,
              ),
              onPressed: rdv.peutRejoindre ? onJoin : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAppointmentCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyAppointmentCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_busy_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Aucun rendez-vous prÃ©vu. RÃ©servez une sÃ©ance avec un psychologue.',
                style: TextStyle(color: AppColors.textLight),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  final RendezVousModel rdv;
  final PsychologueModel psy;
  const _AppointmentRow({required this.rdv, required this.psy});

  @override
  Widget build(BuildContext context) {
    final d = rdv.dateHeure;
    final label =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} Ã  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              color: AppColors.textLight, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text('${psy.fullName} â€” $label',
                style: const TextStyle(color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow(this.label, this.value, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textLight)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.textLight)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

