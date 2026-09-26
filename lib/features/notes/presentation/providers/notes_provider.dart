import 'package:flutter/foundation.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../../../core/errors/failures.dart';

/// États possibles de l'écran liste des notes.
enum NotesStatus { initial, loading, loaded, error }

/// Gère l'état de la liste des notes : chargement, données, erreurs.
class NotesProvider extends ChangeNotifier {
  final NotesRepository repository;

  NotesProvider({required this.repository});

  NotesStatus _status = NotesStatus.initial;
  NotesStatus get status => _status;

  List<Note> _notes = [];
  List<Note> get notes => _notes;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Charge la liste des notes depuis le repository.
  Future<void> loadNotes() async {
    _status = NotesStatus.loading;
    notifyListeners();

    try {
      _notes = await repository.getNotes();
      _status = NotesStatus.loaded;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = NotesStatus.error;
    }
    notifyListeners();
  }

  /// Supprime une note et met à jour la liste locale immédiatement
  /// (pas besoin de recharger toute la liste depuis l'API).
  Future<void> deleteNote(String id) async {
    try {
      await repository.deleteNote(id);
      _notes = _notes.where((note) => note.id != id).toList();
      notifyListeners();
    } on Failure catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }
}
