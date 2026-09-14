import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../models/user_models.dart';
import 'booking_screen.dart';

class PsyProfileScreen extends StatelessWidget {
  final String psyId;
  const PsyProfileScreen({super.key, required this.psyId});

  @override
  Widget build(BuildContext context) {
    final psy = context.watch<AppState>().psyById(psyId);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil du psychologue')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    backgroundImage: psy.photoUrl.isNotEmpty
                        ? AssetImage(psy.photoUrl)
                        : null,
                    child: psy.photoUrl.isEmpty
                        ? const Icon(Icons.person,
                            color: AppColors.primary, size: 46)
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(psy.fullName,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(
                    '${psy.specialite} Â· ${psy.anneesExperience} ans d\'expÃ©rience',
                    style: const TextStyle(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFF5A623), size: 20),
                      const SizedBox(width: 4),
                      Text(
                        psy.avis.isEmpty
                            ? 'Pas encore notÃ©'
                            : '${psy.noteMoyenne.toStringAsFixed(1)} / 5',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark),
                      ),
                      const SizedBox(width: 6),
                      Text('(${psy.nombreAvis} avis)',
                          style: const TextStyle(color: AppColors.textLight)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (psy.bio.isNotEmpty) ...[
              const Text('Ã€ propos',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text(psy.bio,
                  style: const TextStyle(
                      color: AppColors.textLight, height: 1.5)),
              const SizedBox(height: 26),
            ],
            const Text('Avis des patients',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 12),
            if (psy.avis.isEmpty)
              const Text('Aucun avis pour le moment.',
                  style: TextStyle(color: AppColors.textLight))
            else
              ...psy.avis.map((a) => _AvisTile(avis: a)),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
            label: const Text('Prendre rendez-vous'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BookingScreen(psy: psy)),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvisTile extends StatelessWidget {
  final AvisModel avis;
  const _AvisTile({required this.avis});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
                child: Text(
                  avis.auteur.isNotEmpty ? avis.auteur[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: AppColors.secondary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(avis.auteur,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFF5A623), size: 16),
                  const SizedBox(width: 2),
                  Text(avis.note.toStringAsFixed(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(avis.commentaire,
              style:
                  const TextStyle(color: AppColors.textLight, height: 1.4)),
        ],
      ),
    );
  }
}

