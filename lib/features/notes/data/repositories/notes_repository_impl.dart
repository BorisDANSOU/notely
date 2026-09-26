import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_remote_datasource.dart';
import '../models/note_model.dart';

/// Implémentation concrète du repository.
/// Fait le lien entre le datasource (qui parle JSON/Supabase) et
/// le domain (qui ne connaît que l'entité Note et les Failures).
///
/// Pour l'instant, utilise uniquement le datasource distant —
/// le cache Hive sera branché ici à l'étape suivante (mode hors-ligne).
class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource remoteDataSource;

  NotesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Note>> getNotes() async {
    try {
      return await remoteDataSource.getNotes();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure();
    }
  }

  @override
  Future<Note> getNoteById(String id) async {
    try {
      return await remoteDataSource.getNoteById(id);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure();
    }
  }

  @override
  Future<Note> createNote({
    required String title,
    required String content,
  }) async {
    try {
      return await remoteDataSource.createNote(title: title, content: content);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure();
    }
  }

  @override
  Future<Note> updateNote(Note note) async {
    try {
      final model = NoteModel.fromEntity(note);
      return await remoteDataSource.updateNote(model);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure();
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await remoteDataSource.deleteNote(id);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure();
    }
  }
}
