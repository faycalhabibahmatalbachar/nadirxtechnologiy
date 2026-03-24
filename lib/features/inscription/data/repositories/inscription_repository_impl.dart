import 'package:universal_io/io.dart';
import '../../domain/entities/inscription_entity.dart';
import '../../domain/entities/session_formation_entity.dart';
import '../../domain/repositories/inscription_repository.dart';
import '../datasources/inscription_remote_datasource.dart';

class InscriptionRepositoryImpl implements InscriptionRepository {
  final InscriptionRemoteDataSource _remoteDataSource;

  InscriptionRepositoryImpl(this._remoteDataSource);

  @override
  Future<InscriptionEntity> submitInscription(Map<String, dynamic> data) async {
    return await _remoteDataSource.submitInscription(data);
  }

  @override
  Future<String> uploadPhoto(String path, String fileName) async {
    return await _remoteDataSource.uploadPhoto(File(path));
  }

  @override
  Future<String?> uploadDocument(String path, String fileName) async {
    return await _remoteDataSource.uploadDocument(File(path));
  }

  @override
  Future<InscriptionEntity?> getInscriptionById(String id) async {
    return await _remoteDataSource.getInscriptionById(id);
  }

  @override
  Future<SessionFormationEntity?> getActiveSession() async {
    final data = await _remoteDataSource.getActiveSession();
    if (data == null) return null;
    return SessionFormationEntity.fromJson(data);
  }

  @override
  Future<List<InscriptionEntity>> getAllInscriptions() async {
    return await _remoteDataSource.getAllInscriptions();
  }

  @override
  Future<void> updateInscription(String id, Map<String, dynamic> data) async {
    await _remoteDataSource.updateInscription(id, data);
  }
}
