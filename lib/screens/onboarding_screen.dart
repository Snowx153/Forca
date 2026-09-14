import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import 'auth/role_select_screen.dart';

class _OnboardingPage {
  final String image; // chemin vers assets/images/X.jpg
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingPage(this.image, this.icon, this.title, this.description);
}

// Place tes photos dans assets/images/ sous ces noms exacts :
// 1.jpg, 2.jpg, 3.jpg, 4.jpg (une image par slide, format portrait
// de prÃ©fÃ©rence, min. 1080x1920 pour un rendu net sur tous les Ã©crans).
const List<_OnboardingPage> _pages = [
  _OnboardingPage(
    'assets/images/1.jpg',
    Icons.favorite_rounded,
    'Bienvenue sur ForÃ§a',
    "ForÃ§a est une application d'accompagnement pensÃ©e pour les personnes "
        "qui font face Ã  une dÃ©pendance. Notre mission : vous offrir un "
        "espace bienveillant, confidentiel et toujours disponible pour "
        "avancer, Ã  votre rythme.",
  ),
  _OnboardingPage(
    'assets/images/2.jpg',
    Icons.verified_user_rounded,
    'Un accompagnement 100% humain',
    "Ã‰changez directement avec des psychologues qualifiÃ©s et vÃ©rifiÃ©s. "
        "Suivi personnalisÃ©, sÃ©ances en visio via Google Meet, et un "
        "dashboard dÃ©diÃ© pour votre spÃ©cialiste afin de suivre votre "
        "progression dans le temps.",
  ),
  _OnboardingPage(
    'assets/images/3.jpg',
    Icons.psychology_alt_rounded,
    'Un profil pensÃ© pour vous',
    "RÃ©pondez Ã  un QCM intelligent qui permet de mieux comprendre votre "
        "situation. Vos rÃ©ponses restent confidentielles et aident votre "
        "psychologue Ã  vous proposer un accompagnement adaptÃ© dÃ¨s la "
        "premiÃ¨re rencontre.",
  ),
  _OnboardingPage(
    'assets/images/4.jpg',
    Icons.language_rounded,
    'Choisissez votre langue',
    "ForÃ§a s'adapte Ã  vous : sÃ©lectionnez la langue dans laquelle vous "
        "souhaitez utiliser l'application. Vous pourrez la modifier Ã  tout "
        "moment depuis les paramÃ¨tres.",
  ),
];

// Code langue (ISO) associÃ© Ã  chaque langue affichÃ©e.
const Map<String, String> _languageCodes = {
  'FranÃ§ais': 'fr',
  'Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©': 'ar',
  'English': 'en',
};

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  String _selectedLang = 'FranÃ§ais';

  void _confirmLanguageAndGo() {
    // Enregistre la langue choisie dans l'Ã©tat global de l'app.
    // -> AppState doit rÃ©percuter ce choix sur tout le reste de
    //    l'application (voir app_state.dart / main.dart).
    context.read<AppState>().setLanguage(_languageCodes[_selectedLang]!);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
    );
  }

  void _next() {
    if (_index == _pages.length - 1) {
      _confirmLanguageAndGo();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) {
          final page = _pages[i];
          final isLast = i == _pages.length - 1;

          return Stack(
            fit: StackFit.expand,
            children: [
              // --- Image plein fond, avec repli en dÃ©gradÃ© si absente ---
              Image.asset(
                page.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration:
                      const BoxDecoration(gradient: AppGradients.diagonalSplit),
                ),
              ),

              // --- Voile dÃ©gradÃ© pour la lisibilitÃ© du texte ---
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.55),
                      AppColors.secondary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.35),
                      AppColors.primary.withValues(alpha: 0.92),
                    ],
                    stops: const [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // --- Barre du haut : logo + bouton passer ---
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.4)),
                                ),
                                child: const Icon(Icons.favorite_rounded,
                                    color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'ForÃ§a',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: _confirmLanguageAndGo,
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            child: const Text(
                              'Passer',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // --- IcÃ´ne flottante au-dessus de la carte ---
                    Container(
                      width: 64,
                      height: 64,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(page.icon,
                          size: 30, color: AppColors.primary),
                    ),

                    // --- Carte "verre dÃ©poli" avec titre + description ---
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.5,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.55,
                            ),
                          ),
                          if (isLast) ...[
                            const SizedBox(height: 22),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: _languageCodes.keys.map((lang) {
                                final selected = lang == _selectedLang;
                                return ChoiceChip(
                                  label: Text(lang),
                                  selected: selected,
                                  selectedColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? AppColors.primary
                                        : Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.15),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                  onSelected: (_) =>
                                      setState(() => _selectedLang = lang),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    SmoothPageIndicator(
                      controller: _controller,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Colors.white,
                        dotColor: Colors.white.withValues(alpha: 0.4),
                        dotHeight: 8,
                        dotWidth: 8,
                      ),
                    ),
                    const SizedBox(height: 22),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        onPressed: _next,
                        child: Text(
                          _index == _pages.length - 1
                              ? 'Commencer'
                              : 'Suivant',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

