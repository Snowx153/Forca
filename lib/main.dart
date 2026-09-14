import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'utils/app_state.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ForcaApp());
}

class ForcaApp extends StatelessWidget {
  const ForcaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // init() charge patients + rendez-vous sauvegardés localement sur
      // l'appareil (shared_preferences). Le splash screen laisse le temps
      // à ce chargement de se terminer avant que l'utilisateur navigue.
      create: (_) => AppState()..init(),
      child: MaterialApp(
        title: 'Força',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}
