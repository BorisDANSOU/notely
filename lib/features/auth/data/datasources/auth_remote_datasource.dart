import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';

import '../models/app_user_model.dart';

//Datasource distant
abstract class AuthRemoteDataSource {
  AppUserModel? getCurrentUser();
  Stream<AppUserModel?> get authStateChanges;
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  });
  Future<AppUserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  });
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  //Convertit un User Supabase en AppUserModel
  //fullName est lu depuis les user_metadata
  AppUserModel _fromSupabaseUser(User user) {
    return AppUserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
    );
  }

  @override
  AppUserModel? getCurrentUser() {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return null;
    return _fromSupabaseUser(user);
  }

  @override
  Stream<AppUserModel?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;
      return _fromSupabaseUser(user);
    });
  }

  @override
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const ServerException('Connexion impossible.');
      }
      return _fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Erreur lors de la connexion : $e');
    }
  }

  @override
  Future<AppUserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        // Stocké dans user_metadat, récupérable ensuite via currentUser
        data: {'full_name': fullName},
      );
      if (response.user == null) {
        throw const ServerException('Inscription impossible.');
      }
      return AppUserModel(
        id: response.user!.id,
        email: email,
        fullName: fullName,
      );
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Erreur lors de l\'inscription : $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(e.message);
    }
  }
}
