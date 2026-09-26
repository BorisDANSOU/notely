import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/note_model.dart';

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

/// Implémentation utilisant l'API REST (PostgREST) de Supabase via Dio,
/// avec injection explicite du JWT et gestion du refresh token
/// (voir AuthInterceptor) — plutôt que le client haut-niveau
/// supabase_flutter, qui gère ça en interne de façon invisible.
class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final Dio dio;

  NotesRemoteDataSourceImpl({required this.dio});

  String get _currentUserId {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw const ServerException('Utilisateur non connecté.');
    }
    return user.id;
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final response = await dio.get(
        '/notes',
        queryParameters: {'order': 'updated_at.desc'},
      );
      return (response.data as List)
          .map((json) => NoteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  @override
  Future<NoteModel> getNoteById(String id) async {
    try {
      final response = await dio.get(
        '/notes',
        queryParameters: {'id': 'eq.$id'},
      );
      final results = response.data as List;
      if (results.isEmpty) {
        throw const ServerException('Note introuvable.');
      }
      return NoteModel.fromJson(results.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  @override
  Future<NoteModel> createNote({
    required String title,
    required String content,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await dio.post(
        '/notes',
        // Demande à PostgREST de renvoyer la ligne créée dans la réponse.
        options: Options(headers: {'Prefer': 'return=representation'}),
        data: {
          'user_id': _currentUserId,
          'title': title,
          'content': content,
          'created_at': now,
          'updated_at': now,
        },
      );
      final created = (response.data as List).first as Map<String, dynamic>;
      return NoteModel.fromJson(created);
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    try {
      final response = await dio.patch(
        '/notes',
        queryParameters: {'id': 'eq.${note.id}'},
        options: Options(headers: {'Prefer': 'return=representation'}),
        data: {
          'title': note.title,
          'content': note.content,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
      final updated = (response.data as List).first as Map<String, dynamic>;
      return NoteModel.fromJson(updated);
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await dio.delete('/notes', queryParameters: {'id': 'eq.$id'});
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  /// Extrait un message d'erreur lisible depuis une réponse PostgREST.
  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'] as String;
    }
    return e.message ?? 'Erreur réseau inconnue.';
  }
}
