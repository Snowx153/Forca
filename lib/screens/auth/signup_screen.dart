import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../patient/patient_qcm_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
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

    try {
      await context.read<AppState>().registerPatient(
            fullName: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
      return;
    }

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PatientQcmScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final t = appState.t;
    return Directionality(
      textDirection: appState.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      appBar: AppBar(title: Text(t('signup_appbar'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  t('signup_title'),
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                Text(
                  t('signup_subtitle'),
                  style: TextStyle(color: AppColors.textLight),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: t('signup_name_label'),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                      ? t('signup_field_required')
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: t('login_email_label'),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                    validator: (v) => (v == null || !v.contains('@'))
                      ? t('login_email_invalid')
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: t('login_password_label'),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                    validator: (v) => (v == null || v.length < 6)
                      ? t('login_password_invalid')
                      : null,
                ),
                const SizedBox(height: 26),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ],
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(t('signup_submit')),
                ),
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
