import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../models/user_models.dart';
import '../auth/role_select_screen.dart';
import '../contact/contact_screen.dart';
import '../chat/patient_chat_screen.dart';
import '../../widgets/language_switch.dart';

class PsyDashboardScreen extends StatelessWidget {
  const PsyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final patients = appState.patients;
    final demandes = appState.demandesEnAttente;
    final suivis = appState.patientsSuivis;
    final t = appState.t;

    return Directionality(
      textDirection: appState.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ---------- En-tÃªte avec image de fond + dÃ©gradÃ© ----------
          SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/7.jpg',
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
                        AppColors.secondary.withValues(alpha: 0.6),
                        AppColors.secondary.withValues(alpha: 0.3),
                        AppColors.primary.withValues(alpha: 0.88),
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
                              t('psy_dashboard_title'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                              children: [
                                const LanguageSwitch(),
                                IconButton(
                                  icon: const Icon(Icons.mail_outline_rounded,
                                      color: Colors.white),
                                  tooltip: 'Contact',
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => const ContactScreen()),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.logout_rounded,
                                      color: Colors.white),
                                  onPressed: () {
                                    appState.logout();
                                    Navigator.of(context)
                                        .pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const RoleSelectScreen()),
                                      (route) => false,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            appState.currentPsychologue?.fullName ??
                                'Psychologue',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            appState.currentPsychologue?.specialite ??
                                'Addictologie',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
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
              child: patients.isEmpty
                  ? Center(
                      child: Text(
                        t('psy_no_patients'),
                        style: TextStyle(color: AppColors.textLight),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: t('psy_stat_followed'),
                                value: '${suivis.length}',
                                icon: Icons.groups_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: t('psy_stat_new_requests'),
                                value: '${demandes.length}',
                                icon: Icons.mark_email_unread_rounded,
                                highlight: demandes.isNotEmpty,
                              ),
                            ),
                          ],
                        ),

                        // ---------- Nouvelles demandes (invitations) ----------
                        if (demandes.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Text(t('psy_new_requests_title'),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('${demandes.length}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t('psy_new_requests_desc'),
                            style: TextStyle(
                                fontSize: 12.5, color: AppColors.textLight),
                          ),
                          const SizedBox(height: 12),
                          ...demandes.map((patient) => _PatientTile(
                                patient: patient,
                                isInvitation: true,
                                onAccepter: () =>
                                    appState.accepterPatient(patient.id),
                              )),
                        ],

                        // ---------- Patients suivis ----------
                        const SizedBox(height: 24),
                        Text(t('psy_followed_title'),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark)),
                        const SizedBox(height: 12),
                        if (suivis.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              t('psy_no_followed'),
                              style: TextStyle(color: AppColors.textLight),
                            ),
                          )
                        else
                          ...suivis.map((patient) => _PatientTile(
                                patient: patient,
                                isSuivi: true,
                              )),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? AppColors.primary : Colors.grey.shade200,
          width: highlight ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        ],
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  final PatientModel patient;
  final bool isInvitation;
  final bool isSuivi;
  final VoidCallback? onAccepter;

  const _PatientTile({
    required this.patient,
    this.isInvitation = false,
    this.isSuivi = false,
    this.onAccepter,
  });

  Future<void> _appeler() async {
    final url = Uri.parse('https://meet.google.com/new');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _fixerRendezVous(BuildContext context, AppState appState) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Choisir une date',
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      helpText: 'Choisir une heure',
    );
    if (time == null) return;

    final dateHeure = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    appState.planifierRendezVous(patientId: patient.id, dateHeure: dateHeure);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rendez-vous fixÃ© pour ${patient.fullName} le '
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
            'Ã  ${time.format(context)}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final prochainRdv =
        isSuivi ? appState.prochainRendezVousDe(patient.id) : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isInvitation
              ? AppColors.primary.withValues(alpha: 0.35)
              : Colors.grey.shade200,
          width: isInvitation ? 1.4 : 1,
        ),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            patient.fullName.isNotEmpty
                ? patient.fullName[0].toUpperCase()
                : '?',
            style: const TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(patient.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          isInvitation
              ? 'Nouvelle demande â€” abonnement payÃ©'
              : (prochainRdv != null
                  ? 'RDV le ${_fmtDate(prochainRdv.dateHeure)}'
                  : (patient.qcmComplete
                      ? 'Profil complÃ©tÃ© â€” aucun RDV fixÃ©'
                      : 'Profil incomplet')),
          style: TextStyle(
              fontSize: 12,
              fontWeight: isInvitation ? FontWeight.w600 : FontWeight.normal,
              color: isInvitation
                  ? AppColors.primary
                  : (prochainRdv != null
                      ? AppColors.success
                      : AppColors.textLight)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Email', patient.email),
                _detailRow('AnciennetÃ©',
                    patient.anneesDependance != null
                        ? '${patient.anneesDependance} an(s)'
                        : '-'),
                _detailRow('Substance', patient.typeDrogue ?? '-'),
                _detailRow('FrÃ©quence', patient.frequence ?? '-'),
                _detailRow('QuantitÃ©', patient.quantite ?? '-'),
                _detailRow('Abonnement',
                    patient.abonnementActif ? 'Actif' : 'Inactif'),
                if (isSuivi)
                  _detailRow(
                    'Prochain RDV',
                    prochainRdv != null
                        ? _fmtDate(prochainRdv.dateHeure)
                        : 'Aucun',
                  ),

                if (isInvitation) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_rounded,
                          color: Colors.white),
                      label: const Text('Accepter le patient'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: onAccepter,
                    ),
                  ),
                ],

                if (isSuivi) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.chat_bubble_rounded,
                              size: 18),
                          label: const Text('Discuter'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side:
                                const BorderSide(color: AppColors.primary),
                          ),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PatientChatScreen(
                                patientId: patient.id,
                                contactName: patient.fullName,
                                isPsy: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.videocam_rounded, size: 18),
                          label: const Text('Appeler'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side:
                                const BorderSide(color: AppColors.primary),
                          ),
                          onPressed: _appeler,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.event_available_rounded,
                          color: Colors.white, size: 18),
                      label: Text(prochainRdv != null
                          ? 'Modifier le rendez-vous'
                          : 'Fixer un rendez-vous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: () => _fixerRendezVous(context, appState),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} Ã  '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textLight, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

