import '../entities/app_user.dart';

// Contrat abstrait du repositoy d'authentification
abstract class AuthRepository {
  //Retourne l'utilisateur actuellement connecté, ou null si
  //personne n'est connecté

  AppUser? getCurrentUser();

  //Flux réactif de l'état de connexion
  Stream<AppUser?> get authStateChanges;

  //Connexion avec mail/mot de passe
  Future<AppUser> signIn({required String email, required String password});

  // Inscription avec mail/ mot de passe + nom complet
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  // Déconnexion
  Future<void> signOut();
}
