/// Modèle simple pour un patient (démo, stocké localement via
/// shared_preferences). À remplacer plus tard par une vraie base de
/// données (Firebase, API REST...) si l'app doit fonctionner sur
/// plusieurs appareils différents.
class PatientModel {
  final String id;
  String fullName;
  String email;
  String password;
  int? anneesDependance;
  String? typeDrogue;
  String? frequence;
  String? quantite;
  bool qcmComplete;
  bool abonnementActif;

  /// True dès que le patient a payé son abonnement : une "invitation"
  /// est alors envoyée au psychologue (visible dans son dashboard).
  bool invitationPsy;

  /// True une fois que le psychologue a cliqué "Accepter" sur la
  /// demande du patient. Permet de distinguer "nouvelle demande" et
  /// "patient suivi" dans le dashboard psy.
  bool priseEnChargeParPsy;

  PatientModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.anneesDependance,
    this.typeDrogue,
    this.frequence,
    this.quantite,
    this.qcmComplete = false,
    this.abonnementActif = false,
    this.invitationPsy = false,
    this.priseEnChargeParPsy = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'password': password,
        'anneesDependance': anneesDependance,
        'typeDrogue': typeDrogue,
        'frequence': frequence,
        'quantite': quantite,
        'qcmComplete': qcmComplete,
        'abonnementActif': abonnementActif,
        'invitationPsy': invitationPsy,
        'priseEnChargeParPsy': priseEnChargeParPsy,
      };

  factory PatientModel.fromJson(Map<String, dynamic> json) => PatientModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
        anneesDependance: json['anneesDependance'] as int?,
        typeDrogue: json['typeDrogue'] as String?,
        frequence: json['frequence'] as String?,
        quantite: json['quantite'] as String?,
        qcmComplete: json['qcmComplete'] as bool? ?? false,
        abonnementActif: json['abonnementActif'] as bool? ?? false,
        invitationPsy: json['invitationPsy'] as bool? ?? false,
        priseEnChargeParPsy: json['priseEnChargeParPsy'] as bool? ?? false,
      );
}

/// Un avis laissé par un patient sur un psychologue.
class AvisModel {
  final String id;
  final String auteur; // prénom / nom affiché (ou "Patient anonyme")
  final double note; // note sur 5
  final String commentaire;
  final DateTime date;

  const AvisModel({
    required this.id,
    required this.auteur,
    required this.note,
    required this.commentaire,
    required this.date,
  });
}

/// Modèle pour un psychologue, enrichi pour l'affichage patient
/// (profil, note moyenne, avis clients précédents).
class PsychologueModel {
  final String id;
  final String fullName;
  final String email;
  final String password;

  /// Spécialité affichée (ex: "Addictologie", "Thérapie comportementale").
  final String specialite;

  /// Courte biographie / présentation.
  final String bio;

  /// URL ou asset de la photo de profil (peut être vide -> avatar par défaut).
  final String photoUrl;

  /// Nombre d'années d'expérience, affiché sur le profil.
  final int anneesExperience;

  /// Avis laissés par d'anciens patients.
  final List<AvisModel> avis;

  const PsychologueModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.specialite = 'Addictologie',
    this.bio = '',
    this.photoUrl = '',
    this.anneesExperience = 0,
    this.avis = const [],
  });

  /// Note moyenne calculée à partir des avis (0 si aucun avis).
  double get noteMoyenne {
    if (avis.isEmpty) return 0;
    final total = avis.fold<double>(0, (sum, a) => sum + a.note);
    return total / avis.length;
  }

  int get nombreAvis => avis.length;
}

enum RendezVousStatut { planifie, termine, annule }

/// Un rendez-vous réservé par un patient avec un psychologue, ou fixé
/// directement par le psychologue depuis son dashboard.
class RendezVousModel {
  final String id;
  final String patientId;
  final String psyId;
  final DateTime dateHeure;
  RendezVousStatut statut;

  /// Lien de l'appel vidéo (Google Meet), généré à la confirmation.
  String? lienMeet;

  RendezVousModel({
    required this.id,
    required this.patientId,
    required this.psyId,
    required this.dateHeure,
    this.statut = RendezVousStatut.planifie,
    this.lienMeet,
  });

  /// Le bouton "Rejoindre l'appel" ne s'active que dans une fenêtre
  /// de +/- 10 min autour de l'heure du rendez-vous.
  bool get peutRejoindre {
    final maintenant = DateTime.now();
    final diff = dateHeure.difference(maintenant).inMinutes;
    return statut == RendezVousStatut.planifie && diff <= 10 && diff >= -60;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'psyId': psyId,
        'dateHeure': dateHeure.toIso8601String(),
        'statut': statut.index,
        'lienMeet': lienMeet,
      };

  factory RendezVousModel.fromJson(Map<String, dynamic> json) =>
      RendezVousModel(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        psyId: json['psyId'] as String,
        dateHeure: DateTime.parse(json['dateHeure'] as String),
        statut: RendezVousStatut.values[json['statut'] as int],
        lienMeet: json['lienMeet'] as String?,
      );
}

/// Un message texte échangé entre un patient et le psychologue.
/// La conversation est identifiée par [patientId] (l'app ne gère qu'un
/// seul psychologue, donc pas besoin de psyId pour distinguer les fils).
class ChatMessageModel {
  final String id;
  final String patientId;
  final String text;

  /// True si envoyé par le psychologue, false si envoyé par le patient.
  final bool fromPsy;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.patientId,
    required this.text,
    required this.fromPsy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'text': text,
        'fromPsy': fromPsy,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        text: json['text'] as String,
        fromPsy: json['fromPsy'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
