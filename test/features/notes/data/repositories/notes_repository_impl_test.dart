import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:notely/core/errors/exceptions.dart';
import 'package:notely/core/errors/failures.dart';
import 'package:notely/core/network/network_info.dart';
import 'package:notely/features/notes/data/datasources/notes_local_datasource.dart';
import 'package:notely/features/notes/data/datasources/notes_remote_datasource.dart';
import 'package:notely/features/notes/data/models/note_model.dart';
import 'package:notely/features/notes/data/repositories/notes_repository_impl.dart';

import 'notes_repository_impl_test.mocks.dart';

// Génère automatiquement des classes Mock pour ces 3 dépendances.
// La commande build_runner (étape suivante) crée le fichier .mocks.dart
// à partir de cette annotation.
@GenerateMocks([NotesRemoteDataSource, NotesLocalDataSource, NetworkInfo])
void main() {
  late NotesRepositoryImpl repository;
  late MockNotesRemoteDataSource mockRemoteDataSource;
  late MockNotesLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  // Recrée des mocks propres avant chaque test, pour éviter
  // qu'un test n'influence le suivant.
  setUp(() {
    mockRemoteDataSource = MockNotesRemoteDataSource();
    mockLocalDataSource = MockNotesLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NotesRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  final tNoteModel = NoteModel(
    id: '1',
    userId: 'user-1',
    title: 'Titre test',
    content: 'Contenu test',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  group('getNotes', () {
    test('doit retourner les notes distantes ET mettre à jour le cache quand connecté', () async {
      // Arrange : simule une connexion active et une réponse Supabase réussie
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getNotes())
          .thenAnswer((_) async => [tNoteModel]);
      when(mockLocalDataSource.cacheNotes(any)).thenAnswer((_) async {});

      // Act
      final result = await repository.getNotes();

      // Assert : on reçoit bien les notes distantes...
      expect(result, [tNoteModel]);
      // ...ET le cache a bien été appelé pour les sauvegarder
      verify(mockLocalDataSource.cacheNotes([tNoteModel])).called(1);
      // ...et jamais le cache en lecture (on est en ligne)
      verifyNever(mockLocalDataSource.getCachedNotes());
    });

    test(
      'doit retourner les notes en cache quand hors-ligne, sans appeler l\'API',
      () async {
        // Arrange : simule une absence de connexion
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(mockLocalDataSource.getCachedNotes()).thenReturn([tNoteModel]);

        // Act
        final result = await repository.getNotes();

        // Assert : on reçoit les notes du cache...
        expect(result, [tNoteModel]);
        // ...et l'API distante n'a jamais été appelée
        verifyNever(mockRemoteDataSource.getNotes());
      },
    );

    test('doit lever ServerFailure quand le serveur répond une erreur malgré la connexion', () async {
      // Arrange : connecté, mais l'API renvoie une exception
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getNotes())
          .thenThrow(const ServerException('Erreur RLS'));

      // Act + Assert : le repository doit transformer l'exception technique
      // en Failure métier, avec le bon message.
      expect(() => repository.getNotes(), throwsA(isA<ServerFailure>()));
    });
  });

  group('createNote', () {
    test(
      'doit lever NetworkFailure quand hors-ligne, sans jamais appeler l\'API',
      () async {
        // Arrange : hors-ligne
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act + Assert
        expect(
          () => repository.createNote(title: 'Titre', content: 'Contenu'),
          throwsA(isA<NetworkFailure>()),
        );
        verifyNever(
          mockRemoteDataSource.createNote(
            title: anyNamed('title'),
            content: anyNamed('content'),
          ),
        );
      },
    );

    test(
      'doit créer la note via l\'API et la mettre en cache quand connecté',
      () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.createNote(title: 'Titre', content: 'Contenu'),
        ).thenAnswer((_) async => tNoteModel);
        when(mockLocalDataSource.cacheNote(any)).thenAnswer((_) async {});

        // Act
        final result = await repository.createNote(
          title: 'Titre',
          content: 'Contenu',
        );

        // Assert
        expect(result, tNoteModel);
        verify(mockLocalDataSource.cacheNote(tNoteModel)).called(1);
      },
    );
  });
}
