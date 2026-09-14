import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';

class LanguageSwitch extends StatelessWidget {
  final bool onDarkBackground;

  const LanguageSwitch({super.key, this.onDarkBackground = true});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final fg = onDarkBackground ? Colors.white : Colors.black87;
    final bg = onDarkBackground
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.grey.shade200;
    final activeBg = onDarkBackground ? Colors.white : fg;
    final activeFg = onDarkBackground ? AppColors.primary : Colors.white;

    Widget pill(String label, String code) {
      final active = appState.languageCode == code;
      return GestureDetector(
        onTap: () => appState.setLanguage(code),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: active ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? activeFg : fg,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12.5,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: appState.isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [pill('FR', 'fr'), pill('AR', 'ar')],
      ),
    );
  }
}
