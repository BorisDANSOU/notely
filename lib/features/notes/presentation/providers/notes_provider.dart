import 'package:flutter/foundation.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/errors/failures.dart';

enum NotesStatus { initial, loading, loaded, error }

class NotesProvider extends ChangeNotifier {
  final NotesRepository repository;
  final NetworkInfo networkInfo;

  NotesProvider({required this.repository, required this.networkInfo});

  NotesStatus _status = NotesStatus.initial;
  NotesStatus get status => _status;

  List<Note> _notes = [];
  List<Note> get notes => _notes;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  Future<void> loadNotes() async {
    _status = NotesStatus.loading;
    notifyListeners();

    // Vérifié en amont uniquement pour piloter l'affichage de la bannière —
    // le repository gère lui-même la bascule cache/réseau en interne.
    _isOffline = !(await networkInfo.isConnected);

    try {
      _notes = await repository.getNotes();
      _status = NotesStatus.loaded;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = NotesStatus.error;
    }
    notifyListeners();
  }

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

  Future<void> createNote({
    required String title,
    required String content,
  }) async {
    final newNote = await repository.createNote(title: title, content: content);
    _notes = [newNote, ..._notes];
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    final updated = await repository.updateNote(note);
    _notes = _notes.map((n) => n.id == updated.id ? updated : n).toList();
    notifyListeners();
  }
}
