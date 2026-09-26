import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../network/supabase_client.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/notes/data/datasources/notes_local_datasource.dart';
import '../../features/notes/data/datasources/notes_remote_datasource.dart';
import '../../features/notes/data/repositories/notes_repository_impl.dart';
import '../../features/notes/domain/repositories/notes_repository.dart';

/// Conteneur d'injection de dépendances (service locator), basé sur get_it.

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );

  // Client Dio dédié aux appels REST vers Supabase, avec intercepteur JWT.
  sl.registerLazySingleton<Dio>(() => DioClient.create());

  //  Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () =>
        AuthRemoteDataSourceImpl(supabaseClient: SupabaseClientProvider.client),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Notes
  sl.registerLazySingleton<NotesRemoteDataSource>(
    () => NotesRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<NotesLocalDataSource>(
    () => NotesLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
}
