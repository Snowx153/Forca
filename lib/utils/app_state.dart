import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../repositories/questionnaire_repository.dart';
import '../services/secure_storage_service.dart';
import '../models/user_models.dart';

/// Gère l'état global : utilisateur connecté, liste des patients,
/// messages de chat, rendez-vous, langue sélectionnée + traductions.
///
/// Les données sont sauvegardées localement sur l'appareil via
/// `shared_preferences`, donc elles survivent au redémarrage de l'app.
/// C'est un stockage LOCAL A L'APPAREIL : si tu utilises un seul
/// téléphone en changeant de rôle (patient / psy), tout fonctionne. Si
/// patient et psy sont sur deux appareils différents, il faudra
/// remplacer ceci par un vrai backend partagé (Firebase, etc.).
class AppState extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final QuestionnaireRepository _questionnaireRepository =
      QuestionnaireRepository();
  final SecureStorageService _secureStorageService = SecureStorageService();

  // ---- Compte psychologue de test (fourni dans le cahier des charges) ----
  static final PsychologueModel testPsychologue = PsychologueModel(
    id: 'psy_001',
    fullName: 'Dr. Nadira Belkacemi',
    email: 'yacinezino@gmail.com',
    password: '12345678',
    specialite: 'Addictologie',
    anneesExperience: 10,
    bio:
        "Psychologue clinicienne basée à Aïn Témouchent, spécialisée dans "
        "l'accompagnement des dépendances depuis plus de 10 ans. Approche "
        "bienveillante et centrée sur la personne, sans jugement.",
    // Place le fichier "psycho.jpg" dans assets/images/ pour que la photo
    // s'affiche (sinon un avatar générique s'affiche automatiquement).
    photoUrl: 'assets/images/psycho.jpg',
    avis: [
      AvisModel(
        id: 'a1',
        auteur: 'Sarah B.',
        note: 5,
        commentaire:
            "Un accompagnement humain et très professionnel. Je me suis "
            "sentie écoutée dès la première séance.",
        date: DateTime(2025, 3, 12),
      ),
      AvisModel(
        id: 'a2',
        auteur: 'Karim M.',
        note: 4.5,
        commentaire:
            "Des séances utiles et un vrai suivi dans le temps. Merci pour "
            "votre patience.",
        date: DateTime(2025, 5, 2),
      ),
      AvisModel(
        id: 'a3',
        auteur: 'Patient anonyme',
        note: 5,
        commentaire: "Merci de m'avoir aidé à reprendre confiance en moi.",
        date: DateTime(2025, 6, 20),
      ),
    ],
  );

  // Email autorisé à accéder à la page de contact du psychologue
  static const String contactAuthorizedEmail = 'yacinezino@gmail.com';

  // Clés de stockage local (shared_preferences)
  static const String _prefsKeyPatients = 'forca_patients_v1';
  static const String _prefsKeyRendezVous = 'forca_rendezvous_v1';
  static const String _prefsKeyMessages = 'forca_messages_v1';

  /// True une fois que les données locales ont été chargées au démarrage.
  bool isReady = false;

  // ============================================================
  // LANGUE / TRADUCTIONS
  // ============================================================

  String languageCode = 'fr';

  String get selectedLanguage => t('lang_${languageCode}_self');

  bool get isRtl => languageCode == 'ar';

  void setLanguage(String code) {
    if (!_translations.containsKey(code)) return;
    languageCode = code;
    notifyListeners();
  }

  String t(String key) {
    return _translations[languageCode]?[key] ??
      _screenTranslations[languageCode]?[key] ??
        _translations['fr']?[key] ??
      _screenTranslations['fr']?[key] ??
        key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'fr': {
      'app_name': 'Força',
      'lang_fr': 'Français',
      'lang_ar': 'العربية',
      'lang_en': 'English',
      'lang_fr_self': 'Français',
      'lang_ar_self': 'Français',
      'lang_en_self': 'Français',
      'onboarding_slide1_title': 'Un accueil humain et bienveillant',
      'onboarding_slide1_desc':
          "Dès votre inscription, vous êtes accompagné(e) avec respect, "
              "écoute et confidentialité, sans aucun jugement.",
      'onboarding_slide2_title': 'Un suivi intelligent et personnalisé',
      'onboarding_slide2_desc':
          "Nos outils aident votre psychologue à visualiser votre "
              "progression et à adapter le suivi, étape par étape.",
      'onboarding_slide3_title': 'La technologie au service de votre santé',
      'onboarding_slide3_desc':
          "Força combine expertise humaine et innovation pour un "
              "accompagnement moderne, simple et efficace.",
      'onboarding_skip': 'Passer',
      'onboarding_next': 'Suivant',
      'onboarding_start': 'Commencer',
      'subscription_title': 'Abonnement',
      'subscription_plan_title': 'Pack Suivi Mensuel',
      'subscription_plan_desc':
          "Accès complet au suivi psychologique, échanges illimités "
              "et séances en ligne.",
      'subscription_price_unit': 'DA / mois',
      'subscription_payment_method_label': 'Mode de paiement',
      'subscription_payment_details_title': 'Coordonnées de paiement',
      'subscription_baridimob_details':
          'Numéro BaridiMob : 00799999XXXXXXXXXX\n(à remplacer par le vrai identifiant)',
      'subscription_ccp_details':
          'Compte CCP : XXXXXXXX Clé XX\n(à remplacer par le vrai identifiant)',
      'subscription_pay_button': "J'ai effectué le virement",
      'subscription_confirm_title': 'Confirmer le paiement',
      'subscription_confirm_desc_prefix': 'Après votre virement via ',
      'subscription_confirm_desc_suffix':
          ", votre abonnement sera activé par notre équipe sous 24h. "
              "Vous pouvez aussi envoyer votre preuve de paiement via la page Contact.",
      'subscription_confirm_button': "J'ai effectué le paiement",
      'subscription_success_message': 'Demande enregistrée avec succès !',
    },
    'ar': {
      'app_name': 'Força',
      'lang_fr': 'Français',
      'lang_ar': 'العربية',
      'lang_en': 'English',
      'lang_fr_self': 'العربية',
      'lang_ar_self': 'العربية',
      'lang_en_self': 'العربية',
      'onboarding_slide1_title': 'استقبال إنساني وداعم',
      'onboarding_slide1_desc':
          'منذ لحظة التسجيل، نرافقك باحترام وإصغاء وسرية تامة، دون أي حكم.',
      'onboarding_slide2_title': 'متابعة ذكية ومخصصة لك',
      'onboarding_slide2_desc':
          'أدواتنا تساعد أخصائيك النفسي على رؤية تقدمك وتكييف المتابعة خطوة بخطوة.',
      'onboarding_slide3_title': 'التكنولوجيا في خدمة صحتك',
      'onboarding_slide3_desc':
          'تجمع Força بين الخبرة الإنسانية والابتكار لمرافقة عصرية، بسيطة وفعالة.',
      'onboarding_skip': 'تخطي',
      'onboarding_next': 'التالي',
      'onboarding_start': 'ابدأ',
      'subscription_title': 'الاشتراك',
      'subscription_plan_title': 'باقة المتابعة الشهرية',
      'subscription_plan_desc':
          'وصول كامل إلى المتابعة النفسية، تبادل غير محدود وجلسات عبر الإنترنت.',
      'subscription_price_unit': 'دج / شهر',
      'subscription_payment_method_label': 'طريقة الدفع',
      'subscription_payment_details_title': 'معلومات الدفع',
      'subscription_baridimob_details':
          'رقم BaridiMob : 00799999XXXXXXXXXX\n(يجب استبداله بالمعرف الحقيقي)',
      'subscription_ccp_details':
          'حساب CCP : XXXXXXXX المفتاح XX\n(يجب استبداله بالمعرف الحقيقي)',
      'subscription_pay_button': 'لقد قمت بالتحويل',
      'subscription_confirm_title': 'تأكيد الدفع',
      'subscription_confirm_desc_prefix': 'بعد تحويلك عبر ',
      'subscription_confirm_desc_suffix':
          '، سيتم تفعيل اشتراكك من طرف فريقنا خلال 24 ساعة. '
              'يمكنك أيضًا إرسال إثبات الدفع عبر صفحة الاتصال.',
      'subscription_confirm_button': 'لقد قمت بالدفع',
      'subscription_success_message': 'تم تسجيل طلبك بنجاح!',
    },
    'en': {
      'app_name': 'Força',
      'lang_fr': 'Français',
      'lang_ar': 'العربية',
      'lang_en': 'English',
      'lang_fr_self': 'English',
      'lang_ar_self': 'English',
      'lang_en_self': 'English',
      'onboarding_slide1_title': 'A warm, human welcome',
      'onboarding_slide1_desc':
          "From the moment you sign up, you're supported with respect, "
              "listening, and full confidentiality, with no judgment.",
      'onboarding_slide2_title': 'Smart, personalized follow-up',
      'onboarding_slide2_desc':
          "Our tools help your psychologist track your progress and "
              "adapt your care, step by step.",
      'onboarding_slide3_title': 'Technology serving your health',
      'onboarding_slide3_desc':
          "Força combines human expertise with innovation for modern, "
              "simple, and effective support.",
      'onboarding_skip': 'Skip',
      'onboarding_next': 'Next',
      'onboarding_start': 'Start',
      'subscription_title': 'Subscription',
      'subscription_plan_title': 'Monthly follow-up plan',
      'subscription_plan_desc':
          "Full access to psychological support, unlimited messaging, "
              "and online sessions.",
      'subscription_price_unit': 'DA / month',
      'subscription_payment_method_label': 'Payment method',
      'subscription_payment_details_title': 'Payment details',
      'subscription_baridimob_details':
          'BaridiMob number: 00799999XXXXXXXXXX\n(to be replaced with the real ID)',
      'subscription_ccp_details':
          'CCP account: XXXXXXXX Key XX\n(to be replaced with the real ID)',
      'subscription_pay_button': "I've made the transfer",
      'subscription_confirm_title': 'Confirm payment',
      'subscription_confirm_desc_prefix': 'After your transfer via ',
      'subscription_confirm_desc_suffix':
          ", your subscription will be activated by our team within 24h. "
              "You can also send proof of payment via the Contact page.",
      'subscription_confirm_button': "I've made the payment",
      'subscription_success_message': 'Request successfully recorded!',
    },
  };

  static const Map<String, Map<String, String>> _screenTranslations = {
    'fr': {
      'onboarding_slide4_title': 'Choisissez votre langue',
      'onboarding_slide4_desc': 'Sélectionnez la langue de l’application.',
      'home_title': 'Mon espace', 'home_subscription_active': 'Abonnement actif',
      'home_subscription_inactive': 'Aucun abonnement actif', 'home_next_appointment': 'Prochain rendez-vous',
      'home_all_appointments': 'Tous vos rendez-vous', 'home_your_psychologist': 'Votre psychologue',
      'home_your_profile': 'Votre profil', 'home_actions': 'Actions', 'home_field_seniority': 'Ancienneté',
      'home_field_substance': 'Substance', 'home_field_frequency': 'Fréquence', 'home_field_quantity': 'Quantité',
      'home_empty_appointment': 'Aucun rendez-vous prévu. Réservez une séance avec un psychologue.',
      'home_join_call': "Rejoindre l'appel", 'home_upcoming_session': 'Séance à venir',
      'home_action_talk_title': 'Parler à un psychologue', 'home_action_talk_subtitle': 'Consultez les profils et réservez une séance (paiement)',
      'home_action_contact_psy_title': 'Contacter mon psychologue', 'home_action_contact_psy_subtitle': 'Discuter par message ou lancer un appel vidéo',
      'home_action_contact_sessions_title': 'Contact & séances', 'home_action_contact_sessions_subtitle': 'Contactez votre psychologue, réservez une séance',
      'ai_hello_bubble': '🤖 Assistant IA — Hello 👋', 'psy_dashboard_title': 'Tableau de bord',
      'psy_no_patients': 'Aucun patient inscrit pour le moment.', 'psy_stat_followed': 'Patients suivis', 'psy_stat_new_requests': 'Nouvelles demandes',
      'psy_new_requests_title': 'Nouvelles demandes', 'psy_new_requests_desc': 'Ces patients ont payé leur abonnement et attendent votre validation.',
      'psy_followed_title': 'Patients suivis', 'psy_no_followed': 'Aucun patient accepté pour le moment.',
      'psy_new_request_badge': 'Nouvelle demande — abonnement payé', 'psy_accept_button': 'Accepter le patient',
      'psy_discuss_button': 'Discuter', 'psy_call_button': 'Appeler', 'psy_set_appointment': 'Fixer un rendez-vous', 'psy_edit_appointment': 'Modifier le rendez-vous',
      'chat_empty': 'Aucun message pour le moment.\nÉcrivez le premier message ci-dessous.', 'chat_hint': 'Écrire un message...',
      'bot_title': 'Assistant IA Força', 'bot_disclaimer': 'Assistant automatisé par intelligence artificielle — ne remplace pas un vrai psychologue.',
      'bot_hint': 'Écris ton message...', 'bot_welcome': "Bonjour 👋 Je suis l'assistant Força. Comment te sens-tu aujourd'hui ?",
      'role_title': 'Qui êtes-vous ?', 'role_subtitle': 'Choisissez votre espace pour continuer', 'role_patient_title': 'Je suis Patient', 'role_patient_subtitle': 'Je souhaite être accompagné(e)',
      'role_psy_title': 'Je suis Psychologue', 'role_psy_subtitle': "J'accompagne des patients", 'login_title': 'Connexion',
      'login_patient_subtitle': 'Connectez-vous pour continuer votre suivi', 'login_psy_subtitle': 'Connectez-vous à votre tableau de bord',
      'login_patient_appbar': 'Espace Patient', 'login_psy_appbar': 'Espace Psychologue', 'login_email_label': 'Email', 'login_email_invalid': 'Email invalide',
      'login_password_label': 'Mot de passe', 'login_password_invalid': 'Minimum 6 caractères', 'login_test_access': 'Accès test : yacinezino@gmail.com / 12345678',
      'login_error': 'Email ou mot de passe incorrect.', 'login_submit': 'Se connecter', 'login_no_account': "Pas encore de compte ? S'inscrire",
      'signup_appbar': 'Créer un compte', 'signup_title': 'Inscription', 'signup_subtitle': 'Créez votre compte patient en toute confidentialité', 'signup_name_label': 'Nom complet',
      'signup_field_required': 'Champ requis', 'signup_submit': "S'inscrire", 'qcm_title': 'Votre profil', 'qcm_next': 'Suivant', 'qcm_finish': 'Terminer',
      'qcm_step1_title': 'Depuis combien de temps ?', 'qcm_step1_subtitle': "Depuis combien d'années es-tu confronté(e) à cette dépendance ?", 'qcm_step2_title': 'Type de substance',
      'qcm_step2_subtitle': 'Quelle substance concerne principalement ta dépendance ?', 'qcm_step3_title': 'Fréquence', 'qcm_step3_subtitle': 'À quelle fréquence consommes-tu ?',
      'qcm_step4_title': 'Quantité', 'qcm_step4_subtitle': 'Comment évaluerais-tu la quantité consommée ?', 'qcm_years_less_than_one': "Moins d'un an", 'qcm_years_suffix': 'ans',
      'qcm_sub_alcohol': 'Alcool', 'qcm_sub_tobacco': 'Tabac', 'qcm_sub_cannabis': 'Cannabis', 'qcm_sub_cocaine': 'Cocaïne', 'qcm_sub_meds': 'Médicaments détournés', 'qcm_sub_other': 'Autre',
      'qcm_freq_occasional': 'Occasionnelle', 'qcm_freq_weekly': 'Hebdomadaire', 'qcm_freq_daily': 'Quotidienne', 'qcm_freq_multiple': 'Plusieurs fois par jour',
      'qcm_qty_low': 'Faible', 'qcm_qty_moderate': 'Modérée', 'qcm_qty_high': 'Élevée', 'qcm_qty_very_high': 'Très élevée',
      'contact_appbar': 'Contact', 'contact_intro': "Besoin d'aide ou d'un accompagnement ? Écrivez-nous, un professionnel vous répondra.", 'contact_your_message': 'Votre message',
      'contact_hint': 'Écrivez votre message ici...', 'contact_send': 'Envoyer', 'contact_sent': 'Message envoyé.', 'contact_propose_session_title': 'Proposer une séance en ligne',
      'contact_propose_session_desc': 'Générez un lien Google Meet et partagez-le avec votre patient.', 'contact_meet_link_hint': 'https://meet.google.com/xxx-xxxx-xxx', 'contact_create_meet': 'Créer sur Meet',
      'contact_propose': 'Proposer', 'contact_session_proposed': 'Séance proposée au patient.', 'contact_not_authorized': 'Seul le compte psychologue autorisé peut proposer des séances en ligne depuis cette page.',
      'psylist_appbar': 'Nos psychologues', 'psylist_title': 'Choisissez un psychologue', 'psylist_subtitle': "Consultez leur profil, leurs avis, puis réservez un rendez-vous en visio directement dans l'application.",
      'psylist_new': 'Nouveau', 'psylist_reviews_suffix': 'avis', 'psylist_years_exp_suffix': 'ans exp.',
    },
    'ar': {
      'onboarding_slide4_title': 'اختر لغتك', 'onboarding_slide4_desc': 'اختر لغة التطبيق.', 'home_title': 'مساحتي', 'home_subscription_active': 'اشتراك نشط', 'home_subscription_inactive': 'لا يوجد اشتراك نشط', 'home_next_appointment': 'الموعد القادم', 'home_all_appointments': 'جميع مواعيدك', 'home_your_psychologist': 'أخصائيك النفسي', 'home_your_profile': 'ملفك الشخصي', 'home_actions': 'الإجراءات', 'home_field_seniority': 'الأقدمية', 'home_field_substance': 'المادة', 'home_field_frequency': 'التكرار', 'home_field_quantity': 'الكمية', 'home_empty_appointment': 'لا يوجد موعد مقرر. احجز جلسة مع أخصائي نفسي.', 'home_join_call': 'الانضمام إلى المكالمة', 'home_upcoming_session': 'جلسة قادمة', 'home_action_talk_title': 'التحدث إلى أخصائي نفسي', 'home_action_talk_subtitle': 'تصفح الملفات واحجز جلسة', 'home_action_contact_psy_title': 'التواصل مع أخصائيك النفسي', 'home_action_contact_psy_subtitle': 'الدردشة أو بدء مكالمة فيديو', 'home_action_contact_sessions_title': 'التواصل والجلسات', 'home_action_contact_sessions_subtitle': 'تواصل واحجز جلسة', 'ai_hello_bubble': '🤖 مساعد الذكاء الاصطناعي 👋', 'psy_dashboard_title': 'لوحة التحكم', 'psy_no_patients': 'لا يوجد مرضى مسجلون حالياً.', 'psy_stat_followed': 'المرضى المتابَعون', 'psy_stat_new_requests': 'طلبات جديدة', 'psy_new_requests_title': 'طلبات جديدة', 'psy_new_requests_desc': 'ينتظر هؤلاء المرضى موافقتك.', 'psy_followed_title': 'المرضى المتابَعون', 'psy_no_followed': 'لا يوجد مريض مقبول حالياً.', 'psy_new_request_badge': 'طلب جديد', 'psy_accept_button': 'قبول المريض', 'psy_discuss_button': 'محادثة', 'psy_call_button': 'اتصال', 'psy_set_appointment': 'تحديد موعد', 'psy_edit_appointment': 'تعديل الموعد', 'chat_empty': 'لا توجد رسائل بعد.\nاكتب أول رسالة أدناه.', 'chat_hint': 'اكتب رسالة...', 'bot_title': 'مساعد Força الذكي', 'bot_disclaimer': 'مساعد آلي بالذكاء الاصطناعي — لا يغني عن أخصائي نفسي.', 'bot_hint': 'اكتب رسالتك...', 'bot_welcome': 'مرحباً 👋 أنا مساعد Força. كيف تشعر اليوم؟', 'role_title': 'من أنت؟', 'role_subtitle': 'اختر مساحتك للمتابعة', 'role_patient_title': 'أنا مريض', 'role_patient_subtitle': 'أرغب في الحصول على مرافقة', 'role_psy_title': 'أنا أخصائي نفسي', 'role_psy_subtitle': 'أرافق المرضى', 'login_title': 'تسجيل الدخول', 'login_patient_subtitle': 'سجل الدخول لمتابعة مرافقتك', 'login_psy_subtitle': 'سجل الدخول إلى لوحة التحكم', 'login_patient_appbar': 'مساحة المريض', 'login_psy_appbar': 'مساحة الأخصائي النفسي', 'login_email_label': 'البريد الإلكتروني', 'login_email_invalid': 'بريد إلكتروني غير صالح', 'login_password_label': 'كلمة المرور', 'login_password_invalid': '6 أحرف على الأقل', 'login_test_access': 'حساب تجريبي', 'login_error': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.', 'login_submit': 'تسجيل الدخول', 'login_no_account': 'ليس لديك حساب؟ إنشاء حساب', 'signup_appbar': 'إنشاء حساب', 'signup_title': 'التسجيل', 'signup_subtitle': 'أنشئ حساب المريض بسرية تامة', 'signup_name_label': 'الاسم الكامل', 'signup_field_required': 'هذا الحقل مطلوب', 'signup_submit': 'إنشاء حساب', 'qcm_title': 'ملفك الشخصي', 'qcm_next': 'التالي', 'qcm_finish': 'إنهاء', 'qcm_step1_title': 'منذ متى؟', 'qcm_step1_subtitle': 'منذ كم سنة تعاني من هذا الإدمان؟', 'qcm_step2_title': 'نوع المادة', 'qcm_step2_subtitle': 'ما هي المادة الرئيسية؟', 'qcm_step3_title': 'التكرار', 'qcm_step3_subtitle': 'بأي وتيرة تتعاطى؟', 'qcm_step4_title': 'الكمية', 'qcm_step4_subtitle': 'كيف تقيّم الكمية؟', 'qcm_years_less_than_one': 'أقل من سنة', 'qcm_years_suffix': 'سنوات', 'qcm_sub_alcohol': 'الكحول', 'qcm_sub_tobacco': 'التبغ', 'qcm_sub_cannabis': 'القنب', 'qcm_sub_cocaine': 'الكوكايين', 'qcm_sub_meds': 'أدوية', 'qcm_sub_other': 'أخرى', 'qcm_freq_occasional': 'أحياناً', 'qcm_freq_weekly': 'أسبوعياً', 'qcm_freq_daily': 'يومياً', 'qcm_freq_multiple': 'عدة مرات في اليوم', 'qcm_qty_low': 'منخفضة', 'qcm_qty_moderate': 'متوسطة', 'qcm_qty_high': 'مرتفعة', 'qcm_qty_very_high': 'مرتفعة جداً', 'contact_appbar': 'التواصل', 'contact_intro': 'هل تحتاج إلى مساعدة؟ اكتب لنا.', 'contact_your_message': 'رسالتك', 'contact_hint': 'اكتب رسالتك هنا...', 'contact_send': 'إرسال', 'contact_sent': 'تم إرسال الرسالة.', 'contact_propose_session_title': 'اقتراح جلسة عبر الإنترنت', 'contact_propose_session_desc': 'أنشئ رابط Google Meet وشاركه.', 'contact_meet_link_hint': 'https://meet.google.com/xxx-xxxx-xxx', 'contact_create_meet': 'إنشاء على Meet', 'contact_propose': 'اقتراح', 'contact_session_proposed': 'تم اقتراح الجلسة.', 'contact_not_authorized': 'الحساب المعتمد فقط يمكنه اقتراح جلسات.', 'psylist_appbar': 'أخصائيونا النفسيون', 'psylist_title': 'اختر أخصائياً نفسياً', 'psylist_subtitle': 'اطّلع على الملف والتقييمات ثم احجز موعداً.', 'psylist_new': 'جديد', 'psylist_reviews_suffix': 'تقييم', 'psylist_years_exp_suffix': 'سنوات خبرة',
    },
    'en': {
      'onboarding_slide4_title': 'Choose your language', 'onboarding_slide4_desc': 'Choose the app language.', 'home_title': 'My space', 'home_subscription_active': 'Active subscription', 'home_subscription_inactive': 'No active subscription', 'home_next_appointment': 'Next appointment', 'home_all_appointments': 'All your appointments', 'home_your_psychologist': 'Your psychologist', 'home_your_profile': 'Your profile', 'home_actions': 'Actions', 'home_field_seniority': 'Seniority', 'home_field_substance': 'Substance', 'home_field_frequency': 'Frequency', 'home_field_quantity': 'Quantity', 'home_empty_appointment': 'No appointment planned. Book a session with a psychologist.', 'home_join_call': 'Join the call', 'home_upcoming_session': 'Upcoming session', 'home_action_talk_title': 'Talk to a psychologist', 'home_action_talk_subtitle': 'View profiles and book a session', 'home_action_contact_psy_title': 'Contact my psychologist', 'home_action_contact_psy_subtitle': 'Chat or start a video call', 'home_action_contact_sessions_title': 'Contact & sessions', 'home_action_contact_sessions_subtitle': 'Contact your psychologist and book a session', 'ai_hello_bubble': '🤖 AI Assistant — Hello 👋', 'psy_dashboard_title': 'Dashboard', 'psy_no_patients': 'No patients registered yet.', 'psy_stat_followed': 'Patients followed', 'psy_stat_new_requests': 'New requests', 'psy_new_requests_title': 'New requests', 'psy_new_requests_desc': 'These patients are waiting for your approval.', 'psy_followed_title': 'Patients followed', 'psy_no_followed': 'No accepted patient yet.', 'psy_new_request_badge': 'New request', 'psy_accept_button': 'Accept patient', 'psy_discuss_button': 'Discuss', 'psy_call_button': 'Call', 'psy_set_appointment': 'Set appointment', 'psy_edit_appointment': 'Edit appointment', 'chat_empty': 'No messages yet.\nWrite the first message below.', 'chat_hint': 'Write a message...', 'bot_title': 'Força AI Assistant', 'bot_disclaimer': 'Automated AI assistant — it does not replace a real psychologist.', 'bot_hint': 'Write your message...', 'bot_welcome': 'Hello 👋 I am the Força assistant. How are you feeling today?', 'role_title': 'Who are you?', 'role_subtitle': 'Choose your space to continue', 'role_patient_title': 'I am a Patient', 'role_patient_subtitle': 'I want support', 'role_psy_title': 'I am a Psychologist', 'role_psy_subtitle': 'I support patients', 'login_title': 'Login', 'login_patient_subtitle': 'Log in to continue your follow-up', 'login_psy_subtitle': 'Log in to your dashboard', 'login_patient_appbar': 'Patient Area', 'login_psy_appbar': 'Psychologist Area', 'login_email_label': 'Email', 'login_email_invalid': 'Invalid email', 'login_password_label': 'Password', 'login_password_invalid': 'Minimum 6 characters', 'login_test_access': 'Test account', 'login_error': 'Incorrect email or password.', 'login_submit': 'Log in', 'login_no_account': 'No account yet? Sign up', 'signup_appbar': 'Create an account', 'signup_title': 'Sign up', 'signup_subtitle': 'Create your patient account confidentially', 'signup_name_label': 'Full name', 'signup_field_required': 'Required field', 'signup_submit': 'Sign up', 'qcm_title': 'Your profile', 'qcm_next': 'Next', 'qcm_finish': 'Finish', 'qcm_step1_title': 'How long?', 'qcm_step1_subtitle': 'How many years have you faced this addiction?', 'qcm_step2_title': 'Substance type', 'qcm_step2_subtitle': 'Which substance is mainly involved?', 'qcm_step3_title': 'Frequency', 'qcm_step3_subtitle': 'How often do you consume?', 'qcm_step4_title': 'Quantity', 'qcm_step4_subtitle': 'How would you rate the quantity?', 'qcm_years_less_than_one': 'Less than a year', 'qcm_years_suffix': 'years', 'qcm_sub_alcohol': 'Alcohol', 'qcm_sub_tobacco': 'Tobacco', 'qcm_sub_cannabis': 'Cannabis', 'qcm_sub_cocaine': 'Cocaine', 'qcm_sub_meds': 'Misused medication', 'qcm_sub_other': 'Other', 'qcm_freq_occasional': 'Occasional', 'qcm_freq_weekly': 'Weekly', 'qcm_freq_daily': 'Daily', 'qcm_freq_multiple': 'Several times a day', 'qcm_qty_low': 'Low', 'qcm_qty_moderate': 'Moderate', 'qcm_qty_high': 'High', 'qcm_qty_very_high': 'Very high', 'contact_appbar': 'Contact', 'contact_intro': 'Need help or support? Write to us.', 'contact_your_message': 'Your message', 'contact_hint': 'Write your message here...', 'contact_send': 'Send', 'contact_sent': 'Message sent.', 'contact_propose_session_title': 'Propose an online session', 'contact_propose_session_desc': 'Generate a Google Meet link and share it.', 'contact_meet_link_hint': 'https://meet.google.com/xxx-xxxx-xxx', 'contact_create_meet': 'Create on Meet', 'contact_propose': 'Propose', 'contact_session_proposed': 'Session proposed.', 'contact_not_authorized': 'Only the authorized psychologist account can propose sessions.', 'psylist_appbar': 'Our psychologists', 'psylist_title': 'Choose a psychologist', 'psylist_subtitle': 'View profiles and reviews, then book a video appointment.', 'psylist_new': 'New', 'psylist_reviews_suffix': 'reviews', 'psylist_years_exp_suffix': 'yrs exp.',
    },
  };

  String subscriptionConfirmDesc(String paymentMethod) {
    return '${t('subscription_confirm_desc_prefix')}$paymentMethod'
        '${t('subscription_confirm_desc_suffix')}';
  }

  // ============================================================
  // DONNÉES DE L'APPLICATION
  // ============================================================

  PatientModel? currentPatient;
  PsychologueModel? currentPsychologue;

  final List<PatientModel> patients = [];
  final List<PsychologueModel> psychologues = [testPsychologue];
  final List<RendezVousModel> rendezVous = [];
  final List<ChatMessageModel> messages = [];

  // ------------------------------------------------------------
  // PERSISTANCE LOCALE (shared_preferences)
  // ------------------------------------------------------------

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final patientsRaw = prefs.getString(_prefsKeyPatients);
      if (patientsRaw != null) {
        final List decoded = jsonDecode(patientsRaw) as List;
        patients
          ..clear()
          ..addAll(decoded
              .map((e) => PatientModel.fromJson(e as Map<String, dynamic>)));
      }

      final rdvRaw = prefs.getString(_prefsKeyRendezVous);
      if (rdvRaw != null) {
        final List decoded = jsonDecode(rdvRaw) as List;
        rendezVous
          ..clear()
          ..addAll(decoded.map(
              (e) => RendezVousModel.fromJson(e as Map<String, dynamic>)));
      }

      final messagesRaw = prefs.getString(_prefsKeyMessages);
      if (messagesRaw != null) {
        final List decoded = jsonDecode(messagesRaw) as List;
        messages
          ..clear()
          ..addAll(decoded.map(
              (e) => ChatMessageModel.fromJson(e as Map<String, dynamic>)));
      }
    } catch (_) {
      // Stockage corrompu ou indisponible : on démarre avec des listes
      // vides plutôt que de planter l'app.
    } finally {
      isReady = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKeyPatients,
        jsonEncode(patients.map((p) {
          final data = p.toJson();
          data['password'] = '';
          return data;
        }).toList()),
      );
      await prefs.setString(
        _prefsKeyRendezVous,
        jsonEncode(rendezVous.map((r) => r.toJson()).toList()),
      );
      await prefs.setString(
        _prefsKeyMessages,
        jsonEncode(messages.map((m) => m.toJson()).toList()),
      );
    } catch (_) {
      // Si la sauvegarde échoue, on ne bloque pas l'utilisateur : les
      // données restent au moins disponibles en mémoire pour la session.
    }
  }

  void _notifyAndPersist() {
    notifyListeners();
    _persist();
  }

  // ------------------------------------------------------------
  // AUTHENTIFICATION
  // ------------------------------------------------------------

  Future<PatientModel> registerPatient({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _authRepository.register(
      fullName: fullName,
      email: email,
      password: password,
      passwordConfirmation: password,
      role: 'patient',
    );

    final user = response['user'];
    final token = response['token'];
    if (user is! Map<String, dynamic> || token is! String || token.isEmpty) {
      throw const FormatException('Réponse d\'inscription invalide.');
    }

    final patient = PatientModel(
      id: user['id'].toString(),
      fullName: user['name']?.toString() ?? fullName,
      email: user['email']?.toString() ?? email,
      password: '',
    );
    await _secureStorageService.saveAccessToken(token);
    await _syncPatientQuestionnaireStatus(token, patient);
    patients.add(patient);
    currentPatient = patient;
    _notifyAndPersist();
    return patient;
  }

  Future<bool> loginPatient(String email, String password) async {
    final response = await _authRepository.login(
      email: email,
      password: password,
      role: 'patient',
    );

    final user = response['user'];
    final token = response['token'];
    if (user is! Map<String, dynamic> || token is! String || token.isEmpty) {
      throw const FormatException('Réponse de connexion invalide.');
    }

    final patient = PatientModel(
      id: user['id'].toString(),
      fullName: user['name']?.toString() ?? '',
      email: user['email']?.toString() ?? email,
      password: '',
    );
    await _secureStorageService.saveAccessToken(token);
    await _syncPatientQuestionnaireStatus(token, patient);
    currentPatient = patient;
    notifyListeners();
    return true;
  }

  bool loginPsychologue(String email, String password) {
    if (email == testPsychologue.email &&
        password == testPsychologue.password) {
      currentPsychologue = testPsychologue;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    currentPatient = null;
    currentPsychologue = null;
    notifyListeners();
  }

  // ------------------------------------------------------------
  // PATIENTS
  // ------------------------------------------------------------

  void saveQcm({
    required int anneesDependance,
    required String typeDrogue,
    required String frequence,
    required String quantite,
  }) {
    if (currentPatient == null) return;
    currentPatient!
      ..anneesDependance = anneesDependance
      ..typeDrogue = typeDrogue
      ..frequence = frequence
      ..quantite = quantite
      ..qcmComplete = true;
    _notifyAndPersist();
  }

  Future<Map<String, dynamic>> getInitialQuestionnaire() async {
    final token = await _secureStorageService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const FormatException('Session API introuvable.');
    }
    return _questionnaireRepository.getInitialQuestionnaire(token: token);
  }

  Future<bool> submitInitialQuestionnaire(
    List<Map<String, dynamic>> answers,
  ) async {
    final token = await _secureStorageService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const FormatException('Session API introuvable.');
    }

    final response = await _questionnaireRepository.submitInitialAnswers(
      token: token,
      answers: answers,
    );
    final completed = response['qcm_complete'] == true;
    if (currentPatient != null) {
      currentPatient!.qcmComplete = completed;
      _notifyAndPersist();
    }
    return completed;
  }

  Future<void> _syncPatientQuestionnaireStatus(
    String token,
    PatientModel patient,
  ) async {
    try {
      final response = await _questionnaireRepository.getInitialQuestionnaire(
        token: token,
      );
      patient.qcmComplete = response['qcm_complete'] == true;
    } catch (_) {
      patient.qcmComplete = false;
    }
  }

  // ------------------------------------------------------------
  // QUESTIONNAIRES
  // ------------------------------------------------------------

  void _activerAbonnementPourPatient(PatientModel patient) {
    patient
      ..abonnementActif = true
      ..invitationPsy = true;
  }

  // ------------------------------------------------------------
  // ABONNEMENTS
  // ------------------------------------------------------------

  /// Appelée à la confirmation du paiement (démo). Active l'abonnement
  /// ET envoie automatiquement une "invitation" au psychologue.
  void activerAbonnement() {
    if (currentPatient == null) return;
    _activerAbonnementPourPatient(currentPatient!);
    _notifyAndPersist();
  }

  /// Le psychologue accepte la demande d'un patient.
  void accepterPatient(String patientId) {
    final patient = patients.firstWhere((p) => p.id == patientId);
    patient.priseEnChargeParPsy = true;
    _notifyAndPersist();
  }

  List<PatientModel> get demandesEnAttente =>
      patients.where((p) => p.invitationPsy && !p.priseEnChargeParPsy).toList();

  List<PatientModel> get patientsSuivis =>
      patients.where((p) => p.priseEnChargeParPsy).toList();

  // ------------------------------------------------------------
  // RENDEZ-VOUS
  // ------------------------------------------------------------

  PsychologueModel psyById(String id) {
    return psychologues.firstWhere(
      (p) => p.id == id,
      orElse: () => testPsychologue,
    );
  }

  List<RendezVousModel> get rendezVousPatient {
    if (currentPatient == null) return [];
    return rendezVousForPatient(currentPatient!.id);
  }

  RendezVousModel? get prochainRendezVous {
    final upcoming = rendezVousPatient.where(
      (r) =>
          r.statut == RendezVousStatut.planifie &&
          r.dateHeure.isAfter(DateTime.now().subtract(const Duration(hours: 1))),
    );
    return upcoming.isEmpty ? null : upcoming.first;
  }

  /// Tous les rendez-vous d'un patient donné (utilisé côté psy pour
  /// afficher/gérer le planning de chaque patient suivi).
  List<RendezVousModel> rendezVousForPatient(String patientId) {
    final list = rendezVous.where((r) => r.patientId == patientId).toList();
    list.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    return list;
  }

  /// Le prochain rendez-vous planifié d'un patient donné (null si aucun).
  RendezVousModel? prochainRendezVousDe(String patientId) {
    final upcoming = rendezVousForPatient(patientId).where(
      (r) =>
          r.statut == RendezVousStatut.planifie &&
          r.dateHeure.isAfter(DateTime.now().subtract(const Duration(hours: 1))),
    );
    return upcoming.isEmpty ? null : upcoming.first;
  }

  RendezVousModel bookAppointment({
    required PsychologueModel psy,
    required DateTime dateHeure,
  }) {
    final rdv = RendezVousModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: currentPatient!.id,
      psyId: psy.id,
      dateHeure: dateHeure,
      lienMeet: 'https://meet.google.com/new',
    );
    rendezVous.add(rdv);
    _activerAbonnementPourPatient(currentPatient!);
    _notifyAndPersist();
    return rdv;
  }

  /// Le PSYCHOLOGUE fixe ou modifie le rendez-vous d'un patient déjà
  /// accepté. Si un rendez-vous "planifié" existe déjà pour ce patient,
  /// il est annulé et remplacé par le nouveau (un seul RDV actif à la
  /// fois par patient, pour rester simple).
  RendezVousModel planifierRendezVous({
    required String patientId,
    required DateTime dateHeure,
  }) {
    for (final r in rendezVous) {
      if (r.patientId == patientId && r.statut == RendezVousStatut.planifie) {
        r.statut = RendezVousStatut.annule;
      }
    }
    final rdv = RendezVousModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      psyId: testPsychologue.id,
      dateHeure: dateHeure,
      lienMeet: 'https://meet.google.com/new',
    );
    rendezVous.add(rdv);
    _notifyAndPersist();
    return rdv;
  }

  void annulerRendezVous(String rendezVousId) {
    final rdv = rendezVous.firstWhere((r) => r.id == rendezVousId);
    rdv.statut = RendezVousStatut.annule;
    _notifyAndPersist();
  }

  // ------------------------------------------------------------
  // MESSAGES (patient <-> psychologue)
  // ------------------------------------------------------------

  /// Messages d'une conversation donnée, triés du plus ancien au plus
  /// récent (ordre d'affichage classique d'un chat).
  List<ChatMessageModel> messagesForPatient(String patientId) {
    final list = messages.where((m) => m.patientId == patientId).toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  void envoyerMessage({
    required String patientId,
    required String text,
    required bool fromPsy,
  }) {
    if (text.trim().isEmpty) return;
    messages.add(ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      text: text.trim(),
      fromPsy: fromPsy,
      timestamp: DateTime.now(),
    ));
    _notifyAndPersist();
  }
}
