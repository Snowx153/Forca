import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../models/user_models.dart';
import 'patient_home_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final RendezVousModel rendezVous;
  final PsychologueModel psy;
  const BookingConfirmationScreen({
    super.key,
    required this.rendezVous,
    required this.psy,
  });

  @override
  Widget build(BuildContext context) {
    final d = rendezVous.dateHeure;
    final dateLabel =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} Ã  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_available_rounded,
                    color: AppColors.success, size: 50),
              ),
              const SizedBox(height: 24),
              const Text(
                'Rendez-vous confirmÃ© !',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Votre sÃ©ance avec ${psy.fullName} est planifiÃ©e pour le\n$dateLabel.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textLight, height: 1.5),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.dashboard_rounded, color: Colors.white),
                  label: const Text('Voir mon planning'),
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
                    (route) => false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

