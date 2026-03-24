import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/inscription/data/datasources/inscription_remote_datasource.dart';
import '../../features/inscription/data/repositories/inscription_repository_impl.dart';
import '../../features/inscription/domain/repositories/inscription_repository.dart';
import '../../features/inscription/domain/usecases/submit_inscription_usecase.dart';
import '../../features/inscription/domain/usecases/upload_photo_usecase.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final inscriptionRemoteDataSourceProvider =
    Provider<InscriptionRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return InscriptionRemoteDataSourceImpl(client);
});

final inscriptionRepositoryProvider = Provider<InscriptionRepository>((ref) {
  final dataSource = ref.watch(inscriptionRemoteDataSourceProvider);
  return InscriptionRepositoryImpl(dataSource);
});

final submitInscriptionUseCaseProvider =
    Provider<SubmitInscriptionUseCase>((ref) {
  final repository = ref.watch(inscriptionRepositoryProvider);
  return SubmitInscriptionUseCase(repository);
});

final uploadPhotoUseCaseProvider = Provider<UploadPhotoUseCase>((ref) {
  final repository = ref.watch(inscriptionRepositoryProvider);
  return UploadPhotoUseCase(repository);
});

final activeSessionProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final response = await client
        .from('sessions_formation')
        .select()
        .eq('active', true)
        .single();
    return response;
  } catch (e) {
    return null;
  }
});

final inscriptionByIdProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final response = await client
        .from('inscriptions')
        .select()
        .eq('id', id)
        .single();
    return response;
  } catch (e) {
    return null;
  }
});

final allInscriptionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final response = await client
        .from('inscriptions')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    return [];
  }
});
