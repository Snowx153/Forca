import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette de couleurs de l'application ForÃ§a
/// Vert = espoir / guÃ©rison, Bleu = confiance / calme
class AppColors {
  static const Color primary = Color(0xFF1E7A6F); // vert profond
  static const Color primaryLight = Color(0xFF3FA791);
  static const Color secondary = Color(0xFF264D73); // bleu confiance
  static const Color secondaryLight = Color(0xFF3E6C9E);
  static const Color background = Color(0xFFF7FAF9);
  static const Color card = Colors.white;
  static const Color textDark = Color(0xFF1B1F23);
  static const Color textLight = Color(0xFF6B7280);
  static const Color danger = Color(0xFFD64545);
  static const Color success = Color(0xFF2E9E5B);
}

/// DÃ©gradÃ©s rÃ©utilisables pour habiller les backgrounds de l'app.
class AppGradients {
  /// DÃ©gradÃ© diagonal (coupe l'Ã©cran en 2 zones de couleur, du vert
  /// profond en haut-gauche vers le bleu confiance en bas-droite).
  static const LinearGradient diagonalSplit = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.secondary,
    ],
  );

  /// Variante plus douce, utilisÃ©e derriÃ¨re du contenu clair
  /// (cartes blanches, textes sombres) : dÃ©gradÃ© radial pastel.
  static RadialGradient softRadial({double opacity = 1}) => RadialGradient(
        center: const Alignment(-0.3, -0.6),
        radius: 1.4,
        colors: [
          AppColors.primaryLight.withValues(alpha: 0.18 * opacity),
          AppColors.background,
        ],
        stops: const [0.0, 1.0],
      );

  /// DÃ©gradÃ© "cercle" en haut de l'Ã©cran faÃ§on halo, pour les pages
  /// d'onboarding / splash â€” un cercle de couleur qui se fond dans le fond.
  static BoxDecoration circleHalo({
    Color color = AppColors.primary,
    Alignment alignment = Alignment.topCenter,
  }) {
    return BoxDecoration(
      gradient: RadialGradient(
        center: alignment,
        radius: 1.1,
        colors: [
          color.withValues(alpha: 0.35),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ),
    );
  }
}

/// Background rÃ©utilisable : dÃ©gradÃ© diagonal vert -> bleu en haut,
/// qui se fond vers le fond clair de l'app en bas. Ã€ utiliser en tant
/// que premier enfant d'un Stack derriÃ¨re le contenu de la page.
class AppGradientBackground extends StatelessWidget {
  final Widget child;
  final bool splitDiagonal;

  const AppGradientBackground({
    super.key,
    required this.child,
    this.splitDiagonal = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fond de base
        Container(color: AppColors.background),

        // Zone haute : dÃ©gradÃ© diagonal vert -> bleu (coupe en 2 couleurs)
        if (splitDiagonal)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.diagonalSplit,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
            ),
          ),

        // Halo circulaire dÃ©coratif superposÃ©
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: AppGradients.circleHalo(
              color: Colors.white,
              alignment: Alignment.center,
            ),
          ),
        ),

        child,
      ],
    );
  }
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

