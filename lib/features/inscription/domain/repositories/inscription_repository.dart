import '../entities/inscription_entity.dart';
import '../entities/session_formation_entity.dart';

abstract class InscriptionRepository {
  Future<InscriptionEntity> submitInscription(Map<String, dynamic> data);
  Future<String> uploadPhoto(String path, String fileName);
  Future<String?> uploadDocument(String path, String fileName);
  Future<InscriptionEntity?> getInscriptionById(String id);
  Future<SessionFormationEntity?> getActiveSession();
  Future<List<InscriptionEntity>> getAllInscriptions();
  Future<void> updateInscription(String id, Map<String, dynamic> data);
}
