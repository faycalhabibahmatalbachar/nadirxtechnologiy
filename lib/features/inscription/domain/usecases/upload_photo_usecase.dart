import '../repositories/inscription_repository.dart';

class UploadPhotoUseCase {
  final InscriptionRepository _repository;

  UploadPhotoUseCase(this._repository);

  Future<String> call(String path, String fileName) async {
    return await _repository.uploadPhoto(path, fileName);
  }
}
