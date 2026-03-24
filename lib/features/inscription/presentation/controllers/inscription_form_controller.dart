import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/utils/local_storage.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../domain/entities/inscription_entity.dart';
import '../../domain/entities/session_formation_entity.dart';

enum InscriptionStatus { initial, loading, success, error }

class InscriptionFormData {
  String prenom = '';
  String nom = '';
  DateTime? dateNaissance;
  String? genre;
  String nationalite = 'Tchadienne';
  String email = '';
  String telephone = '';
  String ville = '';
  String? quartier;
  String situationActuelle = 'etudiant';
  String? domaineActivite;
  String niveauInformatique = 'debutant';
  String objectifFormation = '';
  String? photoPath;
  Uint8List? photoBytes;
  String? cvPath;
  Uint8List? cvBytes;
  String? commentConnu;
  bool consentementRgpd = false;

  Map<String, dynamic> toJson({
    required String photoUrl,
    String? cvUrl,
    String? fcmToken,
  }) {
    return {
      'prenom': prenom,
      'nom': nom,
      'date_naissance': dateNaissance?.toIso8601String().split('T')[0],
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
      'photo_participant_url': photoUrl,
      'cv_url': cvUrl,
      'fcm_token': fcmToken,
      'comment_connu': commentConnu,
      'consentement_rgpd': consentementRgpd,
    };
  }
}

class InscriptionFormState {
  final InscriptionStatus status;
  final String? errorMessage;
  final String? progressMessage;
  final InscriptionEntity? inscription;
  final SessionFormationEntity? session;

  const InscriptionFormState({
    this.status = InscriptionStatus.initial,
    this.errorMessage,
    this.progressMessage,
    this.inscription,
    this.session,
  });

  InscriptionFormState copyWith({
    InscriptionStatus? status,
    String? errorMessage,
    String? progressMessage,
    InscriptionEntity? inscription,
    SessionFormationEntity? session,
  }) {
    return InscriptionFormState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      progressMessage: progressMessage,
      inscription: inscription ?? this.inscription,
      session: session ?? this.session,
    );
  }
}

class InscriptionFormNotifier extends StateNotifier<InscriptionFormState> {
  final Ref _ref;
  InscriptionFormData formData = InscriptionFormData();

  InscriptionFormNotifier(this._ref) : super(const InscriptionFormState());

  void updateFormData(InscriptionFormData data) {
    formData = data;
  }

  Future<void> submit() async {
    state = state.copyWith(
      status: InscriptionStatus.loading,
      progressMessage: 'Sécurisation des données...',
    );

    try {
      // ⚡ Paralléliser les uploads: photo obligatoire + CV optionnel en même temps
      state = state.copyWith(progressMessage: 'Upload de la photo...');
      
      final photoUploadFuture = _uploadPhoto();
      final cvUploadFuture = formData.cvPath != null 
        ? _uploadCV() 
        : Future<String?>.value(null);
      
      // Exécuter les deux en parallèle, puis attendre les résultats
      final photoUrl = await photoUploadFuture;
      final cvUrl = await cvUploadFuture;

      // Get FCM token
      state = state.copyWith(progressMessage: 'Enregistrement du dossier...');
      final fcmToken = kIsWeb ? null : await FirebaseMessaging.instance.getToken();

      // Submit to Edge Function
      final response = await _ref.read(supabaseClientProvider).functions.invoke(
        'submit-inscription',
        body: formData.toJson(
          photoUrl: photoUrl,
          cvUrl: cvUrl,
          fcmToken: fcmToken,
        ),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Erreur serveur');
      }

      // Get session data
      final sessionData = await _ref.read(supabaseClientProvider)
          .from('sessions_formation')
          .select()
          .eq('active', true)
          .single();

      // Save inscription ID locally
      final inscriptionId = response.data['inscription_id'] as String;
      await LocalStorage.saveInscriptionId(inscriptionId);

      state = state.copyWith(
        status: InscriptionStatus.success,
        progressMessage: 'Confirmation envoyée !',
        inscription: InscriptionEntity.fromJson(response.data['data']),
        session: SessionFormationEntity.fromJson(sessionData),
      );
    } catch (e) {
      state = state.copyWith(
        status: InscriptionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<String> _uploadPhoto() async {
    if (formData.photoPath == null && formData.photoBytes == null) {
      throw Exception('Photo obligatoire');
    }

    final ext = _inferImageExt(formData.photoPath);
    final contentType = _inferImageContentType(ext);
    final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final path = 'photos/$fileName';

    final storage = _ref.read(supabaseClientProvider).storage.from('participants');
    if (formData.photoBytes != null) {
      await storage.uploadBinary(
        path,
        formData.photoBytes!,
        fileOptions: FileOptions(contentType: contentType, upsert: false),
      );
    } else {
      final file = File(formData.photoPath!);
      await storage.upload(path, file);
    }

    return _ref.read(supabaseClientProvider).storage
        .from('participants')
        .getPublicUrl(path);
  }

  String _inferImageExt(String? path) {
    final p = path ?? '';
    final dot = p.lastIndexOf('.');
    if (dot == -1) return 'jpg';
    final ext = p.substring(dot + 1).toLowerCase();
    if (ext == 'jpeg' || ext == 'jpg' || ext == 'png' || ext == 'webp') return ext;
    return 'jpg';
  }

  String _inferImageContentType(String ext) {
    final e = ext.toLowerCase();
    if (e == 'jpg' || e == 'jpeg') return 'image/jpeg';
    if (e == 'png') return 'image/png';
    if (e == 'webp') return 'image/webp';
    return 'application/octet-stream';
  }

  Future<String> _uploadCV() async {
    if (formData.cvPath == null) return '';

    final file = File(formData.cvPath!);
    final ext = file.path.split('.').last.toLowerCase();
    final fileName = 'cv_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final path = 'documents/$fileName';

    await _ref.read(supabaseClientProvider).storage
        .from('participants')
        .upload(path, file);

    return _ref.read(supabaseClientProvider).storage
        .from('participants')
        .getPublicUrl(path);
  }

  void reset() {
    formData = InscriptionFormData();
    state = const InscriptionFormState();
  }
}

final inscriptionFormControllerProvider =
    StateNotifierProvider<InscriptionFormNotifier, InscriptionFormState>((ref) {
  return InscriptionFormNotifier(ref);
});
