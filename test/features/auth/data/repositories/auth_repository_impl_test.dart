import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:notely/core/errors/exceptions.dart';
import 'package:notely/core/errors/failures.dart';
import 'package:notely/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:notely/features/auth/data/models/app_user_model.dart';
import 'package:notely/features/auth/data/repositories/auth_repository_impl.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSource])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  const tUser = AppUserModel(
    id: 'user-1',
    email: 'test@notely.com',
    fullName: 'Test User',
  );

  group('signIn', () {
    test(
      'doit retourner un AppUser quand les identifiants sont valides',
      () async {
        when(
          mockRemoteDataSource.signIn(
            email: 'test@notely.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => tUser);

        final result = await repository.signIn(
          email: 'test@notely.com',
          password: 'password123',
        );

        expect(result, tUser);
      },
    );

    test(
      'doit lever ServerFailure quand les identifiants sont invalides',
      () async {
        when(
          mockRemoteDataSource.signIn(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(const ServerException('Identifiants invalides.'));

        expect(
          () => repository.signIn(email: 'test@notely.com', password: 'wrong'),
          throwsA(isA<ServerFailure>()),
        );
      },
    );
  });

  group('signUp', () {
    test(
      'doit créer un compte et retourner l\'AppUser correspondant',
      () async {
        when(
          mockRemoteDataSource.signUp(
            email: anyNamed('email'),
            password: anyNamed('password'),
            fullName: anyNamed('fullName'),
          ),
        ).thenAnswer((_) async => tUser);

        final result = await repository.signUp(
          email: 'test@notely.com',
          password: 'password123',
          fullName: 'Test User',
        );

        expect(result, tUser);
      },
    );

    test('doit lever ServerFailure quand l\'email est déjà utilisé', () async {
      when(
        mockRemoteDataSource.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          fullName: anyNamed('fullName'),
        ),
      ).thenThrow(const ServerException('Email déjà utilisé.'));

      expect(
        () => repository.signUp(
          email: 'test@notely.com',
          password: 'x',
          fullName: 'Test',
        ),
        throwsA(isA<ServerFailure>()),
      );
    });
  });

  group('signOut', () {
    test('doit appeler signOut du datasource distant', () async {
      when(mockRemoteDataSource.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verify(mockRemoteDataSource.signOut()).called(1);
    });
  });

  group('getCurrentUser', () {
    test('doit retourner null si aucun utilisateur n\'est connecté', () {
      when(mockRemoteDataSource.getCurrentUser()).thenReturn(null);

      final result = repository.getCurrentUser();

      expect(result, isNull);
    });
  });
}
