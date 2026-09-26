import '../../../../core/cache/hive_config.dart';
import '../models/note_model.dart';

/// Datasource local : lit/écrit les notes dans le cache Hive.
/// Utilisé en secours quand l'API distante est injoignable.
abstract class NotesLocalDataSource {
  List<NoteModel> getCachedNotes();
  Future<void> cacheNotes(List<NoteModel> notes);
  Future<void> cacheNote(NoteModel note);
  Future<void> deleteCachedNote(String id);
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  @override
  List<NoteModel> getCachedNotes() {
    final box = HiveConfig.notesBox;
    return box.values
        .map((json) => NoteModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<void> cacheNotes(List<NoteModel> notes) async {
    final box = HiveConfig.notesBox;
    // On vide et on réécrit tout le cache avec la version fraîche
    // récupérée depuis l'API — garantit qu'il ne reste pas de notes
    // supprimées côté serveur mais encore présentes localement.
    await box.clear();
    for (final note in notes) {
      await box.put(note.id, note.toJson());
    }
  }

  @override
  Future<void> cacheNote(NoteModel note) async {
    await HiveConfig.notesBox.put(note.id, note.toJson());
  }

  @override
  Future<void> deleteCachedNote(String id) async {
    await HiveConfig.notesBox.delete(id);
  }
}
