import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'patient_home_screen.dart';
import 'psy_list_screen.dart';

/// Ã‰cran affichÃ© juste aprÃ¨s la fin du QCM. Propose au patient de
/// parler tout de suite Ã  un psychologue (rÃ©servation) ou d'y aller
/// plus tard depuis son espace.
class QcmResultScreen extends StatelessWidget {
  const QcmResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 52),
              ),
              const SizedBox(height: 24),
              const Text(
                'Merci, votre profil est enregistrÃ©',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Vos rÃ©ponses restent confidentielles. La prochaine Ã©tape "
                "consiste Ã  Ã©changer avec un psychologue qualifiÃ© pour "
                "dÃ©marrer votre accompagnement.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, height: 1.5),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.forum_rounded, color: Colors.white),
                  label: const Text('Parler Ã  un psychologue'),
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const PsyListScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
                  (route) => false,
                ),
                child: const Text(
                  'Plus tard, aller Ã  mon espace',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

