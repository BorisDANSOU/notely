// Entité métier représentant l'utilisateur connecté
// Appelé AppUser et pas User pour éviter tout conflit avec
// la classe User de supabase_flutter.

class AppUser {
  final String id;
  final String email;
  final String? fullName;

  const AppUser({required this.id, required this.email, this.fullName});
}
