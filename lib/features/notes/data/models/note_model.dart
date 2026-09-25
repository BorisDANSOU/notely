import '../../domain/entities/note.dart';

///Modèle de données représentant une note dans l'application.
///  Ce modèle est utilisé pour la sérialisation et la désérialisation des données

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crée une instance de NoteModel à partir du JSON (par exemple, à partir d'une réponse JSON).
  factory NoteModel.fromMap(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convertit l'instance de NoteModel en Map (par exemple, pour l'envoi en JSON).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ///Convertit une entité Note en NoteModel (utile pour la persistance des données).
  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      userId: note.userId,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }
}
