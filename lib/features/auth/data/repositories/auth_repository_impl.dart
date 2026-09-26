import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  AppUser? getCurrentUser() => remoteDataSource.getCurrentUser();

  @override
  Stream<AppUser?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await remoteDataSource.signIn(email: email, password: password);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure();
    }
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      return await remoteDataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
