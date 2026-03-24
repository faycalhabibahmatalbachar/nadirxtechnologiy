import '../../domain/entities/inscription_entity.dart';

class InscriptionModel extends InscriptionEntity {
  const InscriptionModel({
    required super.id,
    required super.nom,
    required super.prenom,
    required super.dateNaissance,
    super.genre,
    super.nationalite,
    required super.email,
    required super.telephone,
    required super.ville,
    super.quartier,
    required super.situationActuelle,
    super.domaineActivite,
    required super.niveauInformatique,
    required super.objectifFormation,
    required super.photoParticipantUrl,
    super.cvUrl,
    super.statut,
    super.fcmToken,
    super.consentementRgpd,
    super.commentConnu,
    required super.createdAt,
    required super.updatedAt,
    super.noteAdmin,
    super.tagAdmin,
    super.adminViewed,
  });

  factory InscriptionModel.fromJson(Map<String, dynamic> json) {
    return InscriptionModel(
      id: json['id'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      dateNaissance: DateTime.parse(json['date_naissance'] as String),
      genre: json['genre'] as String?,
      nationalite: json['nationalite'] as String? ?? 'Tchadienne',
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      ville: json['ville'] as String,
      quartier: json['quartier'] as String?,
      situationActuelle: json['situation_actuelle'] as String,
      domaineActivite: json['domaine_activite'] as String?,
      niveauInformatique: json['niveau_informatique'] as String,
      objectifFormation: json['objectif_formation'] as String,
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

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'date_naissance': dateNaissance.toIso8601String().split('T')[0],
      'genre': genre,
      'nationalite': nationalite,
      'email': email,
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

  static List<InscriptionModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => InscriptionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
