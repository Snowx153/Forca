import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';

class LanguageFlags extends StatelessWidget {
  const LanguageFlags({super.key});

  static const _flags = {'fr': '🇫🇷', 'ar': '🇩🇿'};

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _flags.entries.map((entry) {
          final active = appState.languageCode == entry.key;
          return GestureDetector(
            onTap: () => appState.setLanguage(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34,
              height: 34,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
                border: active
                    ? null
                    : Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: Text(entry.value, style: const TextStyle(fontSize: 18)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
