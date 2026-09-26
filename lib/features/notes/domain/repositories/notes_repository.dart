import '../entities/note.dart';

/// Contrat abstrait du repository des notes.
/// Le domain définit ce qui doit être possible, sans jamais dire coment
/// (Supabase, Hive, autre chose) — ça, c'est le rôle de la couche data.
abstract class NotesRepository {
  /// Récupère toutes les notes de l'utilisateur connecté
  Future<List<Note>> getNotes();

  /// Récupère une note précise par son id
  Future<Note> getNoteById(String id);

  /// Crée une nouvelle note et retourne la note créée (avec son id généré)
  Future<Note> createNote({required String title, required String content});

  /// Met à jour une note existante
  Future<Note> updateNote(Note note);

  /// Supprime une note par son id
  Future<void> deleteNote(String id);
}
