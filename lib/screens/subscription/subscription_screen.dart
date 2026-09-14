import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _paymentMethod = 'BaridiMob';

  void _confirmPayment(AppState appState) {
    final t = appState.t;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.primary, size: 40),
              const SizedBox(height: 16),
              Text(
                t('subscription_confirm_title'),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                appState.subscriptionConfirmDesc(_paymentMethod),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textLight),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // DÃ©mo : on active directement l'abonnement.
                  // En production, l'activation doit se faire aprÃ¨s
                  // vÃ©rification manuelle ou via une API de paiement.
                  appState.activerAbonnement();
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t('subscription_success_message')),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: Text(t('subscription_confirm_button')),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final t = appState.t;
    final isRtl = appState.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(t('subscription_title'))),
        body: Stack(
          children: [
            const _ModernBackground(),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('subscription_plan_title'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          t('subscription_plan_desc'),
                          style: const TextStyle(
                              color: Colors.white70, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('1500',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 6),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(t('subscription_price_unit'),
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(t('subscription_payment_method_label'),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  _PaymentOption(
                    label: 'BaridiMob',
                    icon: Icons.phone_android_rounded,
                    selected: _paymentMethod == 'BaridiMob',
                    onTap: () => setState(() => _paymentMethod = 'BaridiMob'),
                  ),
                  const SizedBox(height: 10),
                  _PaymentOption(
                    label: 'CCP',
                    icon: Icons.account_balance_rounded,
                    selected: _paymentMethod == 'CCP',
                    onTap: () => setState(() => _paymentMethod = 'CCP'),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('subscription_payment_details_title'),
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                          _paymentMethod == 'BaridiMob'
                              ? t('subscription_baridimob_details')
                              : t('subscription_ccp_details'),
                          style: const TextStyle(
                              color: AppColors.textLight, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () => _confirmPayment(appState),
                    child: Text(t('subscription_pay_button')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fond moderne cohÃ©rent avec l'Ã©cran d'onboarding : dÃ©gradÃ© diagonal
/// discret + halos, pour unifier l'identitÃ© visuelle de l'app.
class _ModernBackground extends StatelessWidget {
  const _ModernBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: _DiagonalSplitPainter(),
            ),
            Positioned(
              top: -100,
              right: -80,
              child: _GradientBlob(color: AppColors.primary, size: 240),
            ),
            Positioned(
              bottom: -120,
              left: -90,
              child: _GradientBlob(color: AppColors.secondary, size: 280),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagonalSplitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final leftGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.secondary.withValues(alpha: 0.10),
        AppColors.secondary.withValues(alpha: 0.02),
      ],
    );
    final rightGradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        AppColors.primary.withValues(alpha: 0.10),
        AppColors.primary.withValues(alpha: 0.02),
      ],
    );

    final leftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.62, 0)
      ..lineTo(size.width * 0.38, size.height)
      ..lineTo(0, size.height)
      ..close();

    final rightPath = Path()
      ..moveTo(size.width * 0.62, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.38, size.height)
      ..close();

    canvas.drawPath(leftPath, Paint()..shader = leftGradient.createShader(rect));
    canvas.drawPath(
        rightPath, Paint()..shader = rightGradient.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GradientBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;
  const _GradientBlob(
      {required this.color, required this.size, this.opacity = 0.20});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.textLight),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.normal)),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? AppColors.primary : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
