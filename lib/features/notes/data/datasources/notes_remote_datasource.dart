import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/note_model.dart';

/// Datasource distant : parle directement à l'API Supabase.
/// C'est la seule classe de tout le projet qui connaît les requêtes
/// Supabase spécifiques aux notes.
abstract class NotesRemoteDataSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> getNoteById(String id);
  Future<NoteModel> createNote({
    required String title,
    required String content,
  });
  Future<NoteModel> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final SupabaseClient supabaseClient;

  NotesRemoteDataSourceImpl({required this.supabaseClient});

  /// Raccourci vers la table 'notes'
  SupabaseQueryBuilder get _notesTable => supabaseClient.from('notes');

  /// Id de l'utilisateur actuellement connecté — nécessaire pour
  /// créer une note (RLS exige que user_id corresponde à auth.uid())
  String get _currentUserId {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw const ServerException('Utilisateur non connecté.');
    }
    return user.id;
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      // Grâce à la RLS, cette requête ne renvoie QUE les notes
      // de l'utilisateur connecté, même sans filtre explicite ici.
      final response = await _notesTable.select().order(
        'updated_at',
        ascending: false,
      );

      return (response as List)
          .map((json) => NoteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Erreur lors de la récupération des notes : $e');
    }
  }

  @override
  Future<NoteModel> getNoteById(String id) async {
    try {
      final response = await _notesTable.select().eq('id', id).single();
      return NoteModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Erreur lors de la récupération de la note : $e');
    }
  }

  @override
  Future<NoteModel> createNote({
    required String title,
    required String content,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _notesTable
          .insert({
            'user_id': _currentUserId,
            'title': title,
            'content': content,
            'created_at': now,
            'updated_at': now,
          })
          .select()
          .single();

      return NoteModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Erreur lors de la création de la note : $e');
    }
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    try {
      final response = await _notesTable
          .update({
            'title': note.title,
            'content': note.content,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', note.id)
          .select()
          .single();

      return NoteModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Erreur lors de la modification de la note : $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await _notesTable.delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Erreur lors de la suppression de la note : $e');
    }
  }
}
