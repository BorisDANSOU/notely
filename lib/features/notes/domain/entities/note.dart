///Entité métier représentant une note dans l'application.
///  Ne dépend d'aucune technologie spécifique (comme Supabase ou Hive) et ne contient aucune logique de persistance.
class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée une copie de la note avec des champs modifiés.
  Note copyWith({String? title, String? content, DateTime? updatedAt}) {
    return Note(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
