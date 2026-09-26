import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../datasources/notes_remote_datasource.dart';
import '../models/note_model.dart';

/// Implémentation du repository avec stratégie "réseau d'abord,
/// cache en secours" :
/// - Si connecté : va chercher les données fraîches sur Supabase,
///   puis met à jour le cache local.
/// - Si hors-ligne : sert directement les données du cache Hive.
class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource remoteDataSource;
  final NotesLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NotesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Note>> getNotes() async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final remoteNotes = await remoteDataSource.getNotes();
        // Met à jour le cache avec les données fraîches
        await localDataSource.cacheNotes(remoteNotes);
        return remoteNotes;
      } on ServerException catch (e) {
        // Erreur serveur malgré la connexion (ex: RLS, table absente...)
        throw ServerFailure(e.message);
      }
    }

    // Hors-ligne : on sert le cache tel quel, sans erreur si des notes
    // existent déjà localement.
    return localDataSource.getCachedNotes();
  }

  @override
  Future<Note> getNoteById(String id) async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        return await remoteDataSource.getNoteById(id);
      } on ServerException catch (e) {
        throw ServerFailure(e.message);
      }
    }

    // Hors-ligne : cherche la note dans le cache local
    final cached = localDataSource.getCachedNotes();
    final note = cached.where((n) => n.id == id).toList();
    if (note.isEmpty) {
      throw const CacheFailure('Cette note n\'est pas disponible hors-ligne.');
    }
    return note.first;
  }

  @override
  Future<Note> createNote({
    required String title,
    required String content,
  }) async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      // Création volontairement bloquée hors-ligne : le cahier des charges
      // demande d'AFFICHER les données en cache hors-ligne, pas de créer
      // du contenu qui devrait être synchronisé plus tard.
      throw const NetworkFailure(
        'Tu es hors-ligne. Connecte-toi pour créer une nouvelle note.',
      );
    }

    try {
      final created = await remoteDataSource.createNote(
        title: title,
        content: content,
      );
      await localDataSource.cacheNote(created);
      return created;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<Note> updateNote(Note note) async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      throw const NetworkFailure(
        'Tu es hors-ligne. Connecte-toi pour modifier cette note.',
      );
    }

    try {
      final model = NoteModel.fromEntity(note);
      final updated = await remoteDataSource.updateNote(model);
      await localDataSource.cacheNote(updated);
      return updated;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      throw const NetworkFailure(
        'Tu es hors-ligne. Connecte-toi pour supprimer cette note.',
      );
    }

    try {
      await remoteDataSource.deleteNote(id);
      await localDataSource.deleteCachedNote(id);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
