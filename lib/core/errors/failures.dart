/// Failures : erreurs "métier", exposées par les repositories (domain layer)
/// vers la presentation. Contrairement aux exceptions techniques,
/// elles portent un message déjà adapté à l'affichage utilisateur.

abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Une erreur est survenue côté serveur.',
  ]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Pas de connexion internet. Vérifie ton réseau',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Impossible de lire les données locales.',
  ]);
}
