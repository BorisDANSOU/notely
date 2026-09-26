import 'package:hive_flutter/hive_flutter.dart';

/// Initialise Hive et ouvre les boxes utilisées par l'app.
/// Une "box" Hive est l'équivalent d'une table clé-valeur locale.
class HiveConfig {
  HiveConfig._();

  static const String notesBoxName = 'notes_cache';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    // On stocke chaque note sous forme de Map<String, dynamic> (JSON),
    // pas besoin de TypeAdapter généré : on réutilise NoteModel.toJson/fromJson.
    await Hive.openBox<Map>(notesBoxName);
  }

  static Box<Map> get notesBox => Hive.box<Map>(notesBoxName);
}
