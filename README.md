# Força — Application Flutter

Application mobile d'accompagnement pour personnes dépendantes,
mettant en relation patients et psychologues.

## 1. Structure du projet

```
forca_app/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── user_models.dart          # Modèles Patient / Psychologue
│   ├── utils/
│   │   ├── app_theme.dart            # Couleurs, thème global
│   │   └── app_state.dart            # État global (session, patients)
│   └── screens/
│       ├── splash_screen.dart        # 1. Splash screen
│       ├── onboarding_screen.dart    # 2. Page pub + choix langue
│       ├── auth/
│       │   ├── role_select_screen.dart   # Choix Patient / Psychologue
│       │   ├── login_screen.dart         # 3. Connexion
│       │   └── signup_screen.dart        # 3. Inscription patient
│       ├── patient/
│       │   ├── patient_qcm_screen.dart   # 5. QCM intelligent
│       │   └── patient_home_screen.dart  # Accueil patient
│       ├── psychologue/
│       │   └── psy_dashboard_screen.dart # 6. Dashboard psychologue
│       ├── subscription/
│       │   └── subscription_screen.dart  # 7. Abonnements
│       └── contact/
│           └── contact_screen.dart       # 8. Contact + Google Meet
└── assets/images/                    # Mettre splash_bg.jpg ici
```

## 2. Prérequis

1. Installer **Flutter SDK** : https://docs.flutter.dev/get-started/install
2. Installer **Android Studio** (pour le SDK Android + émulateur)
3. Vérifier l'installation :
   ```bash
   flutter doctor
   ```
   Corrigez toutes les erreurs affichées (licences Android à accepter avec
   `flutter doctor --android-licenses`).

## 3. Lancer le projet en local

```bash
cd forca_app
flutter pub get          # installe les dépendances
flutter run               # lance sur un émulateur ou téléphone branché
```

## 4. Ajouter l'image du Splash Screen

Placez une photo professionnelle (spécialiste dans un bureau) nommée
`splash_bg.jpg` dans `assets/images/`. Si le fichier est absent,
un dégradé de couleur s'affiche automatiquement à la place —
l'app compile donc même sans image.

## 5. Compte de test Psychologue

```
Email : yacinezino@gmail.com
Mot de passe : 12345678
```

⚠️ Ce compte est codé en dur uniquement pour la démonstration.
Avant toute mise en ligne réelle, il faut le remplacer par un vrai
système d'authentification sécurisé (Firebase Auth, backend avec
mots de passe hashés, etc.).

## 6. Générer l'APK

### APK de test (debug, rapide à générer)
```bash
flutter build apk --debug
```
Fichier généré : `build/app/outputs/flutter-apk/app-debug.apk`

### APK de production (release, optimisé et plus léger)
```bash
flutter build apk --release
```
Fichier généré : `build/app/outputs/flutter-apk/app-release.apk`

### APK optimisé par architecture (recommandé pour réduire la taille)
```bash
flutter build apk --split-per-abi
```
Génère 3 fichiers plus légers (armeabi-v7a, arm64-v8a, x86_64) au lieu
d'un seul gros fichier universel.

## 7. Installer l'APK sur un téléphone Android

1. Copiez le fichier `.apk` généré sur le téléphone (câble USB, lien, etc.)
2. Sur le téléphone : Paramètres > Sécurité > autoriser
   "Installation depuis des sources inconnues"
3. Ouvrez le fichier `.apk` sur le téléphone pour l'installer

## 8. Ce qui est fonctionnel dans cette version (démo)

- Toutes les pages de l'UI sont créées et connectées entre elles
- Authentification patient (inscription/connexion) et psychologue
  fonctionnent **en mémoire** (les données sont perdues si l'app redémarre)
- QCM patient → sauvegarde du profil → visible dans le dashboard psychologue
- Simulation de paiement (BaridiMob/CCP) : active l'abonnement sans
  vraie vérification bancaire
- Bouton "Créer sur Meet" ouvre `meet.google.com/new` dans le navigateur

## 9. Ce qu'il reste à faire pour une vraie mise en production

1. **Backend réel** : remplacer `AppState` (en mémoire) par Firebase
   (Auth + Firestore) ou une API REST avec base de données.
2. **Sécurité** : hasher les mots de passe, supprimer les identifiants
   codés en dur, chiffrer les données sensibles des patients.
3. **Paiement** : intégrer une vraie vérification BaridiMob/CCP
   (upload de reçu + validation manuelle, ou API si disponible).
4. **Validation clinique** : faire relire le QCM et le parcours patient
   par de vrais professionnels de santé / addictologues.
5. **Icône et nom de l'app** : personnaliser via `flutter_launcher_icons`
   et modifier `android/app/src/main/AndroidManifest.xml`.
6. **Politique de confidentialité** : obligatoire avant publication sur
   le Play Store, vu la sensibilité des données collectées.

## 10. Dépendances utilisées

| Package | Usage |
|---|---|
| provider | Gestion d'état global |
| google_fonts | Typographie (Poppins) |
| smooth_page_indicator | Indicateurs du diaporama onboarding |
| url_launcher | Ouvrir Google Meet |
| shared_preferences | (prêt à l'emploi pour persister la langue/session) |
