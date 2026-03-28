class InscriptionEntity {
  final String id;
  final String nom;
  final String prenom;
  final DateTime dateNaissance;
  final String? genre;
  final String nationalite;
  final String telephone;
  final String ville;
  final String? quartier;
  final String situationActuelle;
  final String? domaineActivite;
  final String niveauInformatique;
  final String objectifFormation;
  final String photoParticipantUrl;
  final String? cvUrl;
  final String statut;
  final String? fcmToken;
  final bool consentementRgpd;
  final String? commentConnu;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? noteAdmin;
  final String? tagAdmin;
  final bool adminViewed;

  const InscriptionEntity({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    this.genre,
    this.nationalite = 'Tchadienne',
    required this.telephone,
    required this.ville,
    this.quartier,
    required this.situationActuelle,
    this.domaineActivite,
    required this.niveauInformatique,
    required this.objectifFormation,
    required this.photoParticipantUrl,
    this.cvUrl,
    this.statut = 'confirme',
    this.fcmToken,
    this.consentementRgpd = true,
    this.commentConnu,
    required this.createdAt,
    required this.updatedAt,
    this.noteAdmin,
    this.tagAdmin,
    this.adminViewed = false,
  });

  String get nomComplet => '$prenom $nom';
  
  String get shortId => id.substring(0, 8).toUpperCase();

  factory InscriptionEntity.fromJson(Map<String, dynamic> json) {
    return InscriptionEntity(
      id: json['id'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      dateNaissance: DateTime.parse(json['date_naissance'] as String),
      genre: json['genre'] as String?,
      nationalite: json['nationalite'] as String? ?? 'Tchadienne',
      telephone: json['telephone'] as String,
      ville: json['ville'] as String,
      quartier: json['quartier'] as String?,
      situationActuelle:
          (json['situation_actuelle'] as String?) ?? 'etudiant',
      domaineActivite: json['domaine_activite'] as String?,
      niveauInformatique:
          (json['niveau_informatique'] as String?) ?? 'debutant',
      objectifFormation:
          (json['objectif_formation'] as String?) ?? '',
      photoParticipantUrl: json['photo_participant_url'] as String,
      cvUrl: json['cv_url'] as String?,
      statut: json['statut'] as String? ?? 'confirme',
      fcmToken: json['fcm_token'] as String?,
      consentementRgpd: json['consentement_rgpd'] as bool? ?? true,
      commentConnu: json['comment_connu'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      noteAdmin: json['note_admin'] as String?,
      tagAdmin: json['tag_admin'] as String?,
      adminViewed: json['admin_viewed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'date_naissance': dateNaissance.toIso8601String(),
      'genre': genre,
      'nationalite': nationalite,
      'telephone': telephone,
      'ville': ville,
      'quartier': quartier,
      'situation_actuelle': situationActuelle,
      'domaine_activite': domaineActivite,
      'niveau_informatique': niveauInformatique,
      'objectif_formation': objectifFormation,
      'photo_participant_url': photoParticipantUrl,
      'cv_url': cvUrl,
      'statut': statut,
      'fcm_token': fcmToken,
      'consentement_rgpd': consentementRgpd,
      'comment_connu': commentConnu,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'note_admin': noteAdmin,
      'tag_admin': tagAdmin,
      'admin_viewed': adminViewed,
    };
  }
}
