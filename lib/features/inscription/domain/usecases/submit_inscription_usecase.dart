import '../entities/inscription_entity.dart';
import '../repositories/inscription_repository.dart';

class SubmitInscriptionUseCase {
  final InscriptionRepository _repository;

  SubmitInscriptionUseCase(this._repository);

  Future<InscriptionEntity> call(Map<String, dynamic> data) async {
    return await _repository.submitInscription(data);
  }
}
