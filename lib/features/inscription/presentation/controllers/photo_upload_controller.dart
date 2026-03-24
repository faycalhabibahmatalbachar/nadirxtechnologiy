import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

enum PhotoStatus { initial, picking, cropping, ready, error }

class PhotoUploadState {
  final PhotoStatus status;
  final String? photoPath;
  final Uint8List? photoBytes;
  final String? errorMessage;

  const PhotoUploadState({
    this.status = PhotoStatus.initial,
    this.photoPath,
    this.photoBytes,
    this.errorMessage,
  });

  PhotoUploadState copyWith({
    PhotoStatus? status,
    String? photoPath,
    Uint8List? photoBytes,
    String? errorMessage,
  }) {
    return PhotoUploadState(
      status: status ?? this.status,
      photoPath: photoPath ?? this.photoPath,
      photoBytes: photoBytes ?? this.photoBytes,
      errorMessage: errorMessage,
    );
  }
}

class PhotoUploadNotifier extends StateNotifier<PhotoUploadState> {
  final ImagePicker _picker = ImagePicker();

  PhotoUploadNotifier() : super(const PhotoUploadState());

  Future<void> pickFromCamera() async {
    state = state.copyWith(status: PhotoStatus.picking);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          state = state.copyWith(
            status: PhotoStatus.ready,
            photoPath: image.path,
            photoBytes: bytes,
          );
        } else {
          await _cropImage(image.path);
        }
      } else {
        state = state.copyWith(status: PhotoStatus.initial);
      }
    } catch (e) {
      state = state.copyWith(
        status: PhotoStatus.error,
        errorMessage: 'Erreur lors de la prise de photo',
      );
    }
  }

  Future<void> pickFromGallery() async {
    state = state.copyWith(status: PhotoStatus.picking);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          state = state.copyWith(
            status: PhotoStatus.ready,
            photoPath: image.path,
            photoBytes: bytes,
          );
        } else {
          await _cropImage(image.path);
        }
      } else {
        state = state.copyWith(status: PhotoStatus.initial);
      }
    } catch (e) {
      state = state.copyWith(
        status: PhotoStatus.error,
        errorMessage: 'Erreur lors de la sélection',
      );
    }
  }

  Future<void> _cropImage(String path) async {
    // Le cropper n'est pas fiable/constant sur Web: on accepte la photo telle quelle.
    if (kIsWeb) {
      state = state.copyWith(status: PhotoStatus.ready, photoPath: path);
      return;
    }

    state = state.copyWith(status: PhotoStatus.cropping);
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer',
            toolbarColor: const Color(0xFF050508),
            toolbarWidgetColor: const Color(0xFF00FF88),
            backgroundColor: const Color(0xFF050508),
            activeControlsWidgetColor: const Color(0xFF00FF88),
            dimmedLayerColor: const Color(0xFF050508).withOpacity(0.8),
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Recadrer',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        state = state.copyWith(
          status: PhotoStatus.ready,
          photoPath: croppedFile.path,
        );
      } else {
        state = state.copyWith(status: PhotoStatus.initial);
      }
    } catch (e) {
      state = state.copyWith(
        status: PhotoStatus.error,
        errorMessage: 'Erreur lors du recadrage',
      );
    }
  }

  void clear() {
    state = const PhotoUploadState();
  }
}

final photoUploadControllerProvider =
    StateNotifierProvider<PhotoUploadNotifier, PhotoUploadState>((ref) {
  return PhotoUploadNotifier();
});
