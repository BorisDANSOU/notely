import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction permettant de savoir si l'appareil a une connexion réseau.
/// Séparé dans son propre fichier pour rester testable et remplaçable.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    // checkConnectivity retourne une liste (peut détecter plusieurs interfaces).
    // On considère connecté si au moins une interface n'est pas "none".
    return !result.contains(ConnectivityResult.none);
  }
}
