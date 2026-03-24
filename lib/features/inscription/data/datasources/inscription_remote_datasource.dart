import 'package:universal_io/io.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/config/app_config.dart';
import '../models/inscription_model.dart';

abstract class InscriptionRemoteDataSource {
  Future<InscriptionModel> submitInscription(Map<String, dynamic> data);
  Future<String> uploadPhoto(File file);
  Future<String?> uploadDocument(File file);
  Future<InscriptionModel?> getInscriptionById(String id);
  Future<Map<String, dynamic>?> getActiveSession();
  Future<List<InscriptionModel>> getAllInscriptions();
  Future<void> updateInscription(String id, Map<String, dynamic> data);
}

class InscriptionRemoteDataSourceImpl implements InscriptionRemoteDataSource {
  final SupabaseClient _client;
  final _uuid = const Uuid();

  InscriptionRemoteDataSourceImpl(this._client);

  @override
  Future<InscriptionModel> submitInscription(Map<String, dynamic> data) async {
    try {
      final response = await _client.functions.invoke(
        AppConfig.submitFunction,
        body: data,
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Erreur lors de l\'inscription');
      }

      return InscriptionModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> uploadPhoto(File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    final fileName = 'photo_${_uuid.v4()}.$ext';
    final path = 'photos/$fileName';

    await _client.storage
        .from(AppConfig.participantsBucket)
        .upload(path, file);

    return _client.storage
        .from(AppConfig.participantsBucket)
        .getPublicUrl(path);
  }

  @override
  Future<String?> uploadDocument(File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    final fileName = 'doc_${_uuid.v4()}.$ext';
    final path = 'documents/$fileName';

    await _client.storage
        .from(AppConfig.participantsBucket)
        .upload(path, file);

    return _client.storage
        .from(AppConfig.participantsBucket)
        .getPublicUrl(path);
  }

  @override
  Future<InscriptionModel?> getInscriptionById(String id) async {
    try {
      final response = await _client
          .from('inscriptions')
          .select()
          .eq('id', id)
          .single();

      return InscriptionModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getActiveSession() async {
    try {
      final response = await _client
          .from('sessions_formation')
          .select()
          .eq('active', true)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<InscriptionModel>> getAllInscriptions() async {
    try {
      final response = await _client
          .from('inscriptions')
          .select()
          .order('created_at', ascending: false);

      return InscriptionModel.fromJsonList(response);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> updateInscription(String id, Map<String, dynamic> data) async {
    await _client
        .from('inscriptions')
        .update(data)
        .eq('id', id);
  }
}
