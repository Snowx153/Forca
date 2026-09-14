import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import 'role_select_screen.dart';
import 'signup_screen.dart';
import '../patient/patient_qcm_screen.dart';
import '../patient/patient_home_screen.dart';
import '../psychologue/psy_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final UserRole role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  bool get isPatient => widget.role == UserRole.patient;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final appState = context.read<AppState>();
    await Future.delayed(const Duration(milliseconds: 500));

    bool success;
    if (isPatient) {
      try {
        success = await appState.loginPatient(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
      } catch (_) {
        success = false;
      }
    } else {
      success =
          appState.loginPsychologue(_emailCtrl.text.trim(), _passCtrl.text);
    }

    setState(() => _loading = false);

    if (!mounted) return;

    if (!success) {
      setState(() => _error = 'Email ou mot de passe incorrect.');
      return;
    }

    if (isPatient) {
      final patient = appState.currentPatient!;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => patient.qcmComplete
              ? const PatientHomeScreen()
              : const PatientQcmScreen(),
        ),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PsyDashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final t = appState.t;
    return Directionality(
      textDirection: appState.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      appBar: AppBar(title: Text(isPatient ? t('login_patient_appbar') : t('login_psy_appbar'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Connexion',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                Text(
                  isPatient
                      ? 'Connectez-vous pour continuer votre suivi'
                      : 'Connectez-vous à votre tableau de bord',
                  style: const TextStyle(color: AppColors.textLight),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Email invalide' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Minimum 6 caractères'
                      : null,
                ),
                if (!isPatient) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Accès test : yacinezino@gmail.com / 12345678',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                        fontStyle: FontStyle.italic),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(color: AppColors.danger)),
                ],
                const SizedBox(height: 26),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Se connecter'),
                ),
                if (isPatient) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SignupScreen()),
                      ),
                      child: const Text("Pas encore de compte ? S'inscrire"),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}
