import 'package:flutter/foundation.dart';

class SessionFormationEntity {
  final String id;
  final String titre;
  final String? sousTitre;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String horaire;
  final String lieu;
  final String? adresseComplete;
  final List<ProgrammeJour> programme;
  final List<Instructeur> instructeurs;
  final Contacts contacts;
  final int placesMax;
  final bool active;
  final DateTime createdAt;

  const SessionFormationEntity({
    required this.id,
    required this.titre,
    this.sousTitre,
    required this.dateDebut,
    required this.dateFin,
    this.horaire = '08h00 – 17h30',
    required this.lieu,
    this.adresseComplete,
    this.programme = const [],
    this.instructeurs = const [],
    required this.contacts,
    this.placesMax = 25,
    this.active = true,
    required this.createdAt,
  });

  int get joursRestants {
    final now = DateTime.now();
    if (now.isAfter(dateDebut)) return 0;
    return dateDebut.difference(now).inDays;
  }

  String get datesFormatted {
    final debut = '${dateDebut.day}';
    final fin = '${dateFin.day}';
    final mois = _getMonthName(dateFin.month);
    final annee = dateFin.year;
    return '$debut – $fin $mois $annee';
  }

  String _getMonthName(int month) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return months[month - 1];
  }

  factory SessionFormationEntity.fromJson(Map<String, dynamic> json) {
    return SessionFormationEntity(
      id: json['id'] as String,
      titre: json['titre'] as String,
      sousTitre: json['sous_titre'] as String?,
      dateDebut: DateTime.parse(json['date_debut'] as String),
      dateFin: DateTime.parse(json['date_fin'] as String),
      horaire: json['horaire'] as String? ?? '08h00 – 17h30',
      lieu: json['lieu'] as String,
      adresseComplete: json['adresse_complete'] as String?,
      programme: (json['programme'] as List<dynamic>?)
          ?.map((e) => ProgrammeJour.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      instructeurs: (json['instructeurs'] as List<dynamic>?)
          ?.map((e) => Instructeur.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      contacts: Contacts.fromJson(json['contacts'] as Map<String, dynamic>),
      placesMax: json['places_max'] as int? ?? 25,
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'sous_titre': sousTitre,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'horaire': horaire,
      'lieu': lieu,
      'adresse_complete': adresseComplete,
      'programme': programme.map((e) => e.toJson()).toList(),
      'instructeurs': instructeurs.map((e) => e.toJson()).toList(),
      'contacts': contacts.toJson(),
      'places_max': placesMax,
      'active': active,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ProgrammeJour {
  final int jour;
  final String titre;
  final List<String> modules;

  const ProgrammeJour({
    required this.jour,
    required this.titre,
    this.modules = const [],
  });

  String get modulesFormatted => modules.join(' • ');

  factory ProgrammeJour.fromJson(Map<String, dynamic> json) {
    final modulesRaw = json['modules'];
    if (kDebugMode && modulesRaw is List && modulesRaw.isNotEmpty) {
      final first = modulesRaw.first;
      debugPrint(
        'ProgrammeJour.fromJson modulesRaw[0] runtimeType=${first.runtimeType}',
      );
      if (first is Map) {
        debugPrint(
          'ProgrammeJour.fromJson modulesRaw[0] keys=${first.keys.take(10).toList()}',
        );
      }
    }
    return ProgrammeJour(
      jour: json['jour'] as int,
      titre: json['titre'] as String,
      modules: (modulesRaw as List<dynamic>?)
              ?.map((e) {
                if (e is String) return e;
                if (e is Map<String, dynamic>) {
                  // Supabase peut renvoyer des objets au lieu de strings.
                  // On tente quelques clés courantes, sinon fallback sur `toString()`.
                  final candidate = e['titre'] ??
                      e['module'] ??
                      e['nom'] ??
                      e['name'] ??
                      e['label'];
                  return candidate?.toString() ?? e.toString();
                }
                return e.toString();
              })
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jour': jour,
      'titre': titre,
      'modules': modules,
    };
  }
}

class Instructeur {
  final String nom;
  final String specialite;

  const Instructeur({
    required this.nom,
    required this.specialite,
  });

  factory Instructeur.fromJson(Map<String, dynamic> json) {
    return Instructeur(
      nom: json['nom'] as String,
      specialite: json['specialite'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'specialite': specialite,
    };
  }
}

class Contacts {
  final String? whatsapp;
  final String? telephone;

  const Contacts({
    this.whatsapp,
    this.telephone,
  });

  factory Contacts.fromJson(Map<String, dynamic> json) {
    return Contacts(
      whatsapp: json['whatsapp'] as String?,
      telephone: json['telephone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'whatsapp': whatsapp,
      'telephone': telephone,
    };
  }
}
