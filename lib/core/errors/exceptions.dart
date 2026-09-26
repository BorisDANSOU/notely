/// Exceptions techniques levées par les data sources.
/// Chacune correspond à une source d'erreur précise.
/// Levée quand un appel à l'API Supabase échoue (erreur serveur, requête invalide...)

class ServerException implements Exception {
  final String message;

  const ServerException(this.message);
}

/// levée quand il n'y a pas de connexion internet
class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);
}

/// Lvée quand uen opération sur le cache local (Hive) échoue
class CacheException implements Exception {
  final String message;

  const CacheException(this.message);
}
