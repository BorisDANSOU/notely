import 'package:flutter/foundation.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

/// Gère l'état d'authentification de l'app avec Provider.
/// La presentation (Splash, Login, Register, Profil) observe cet objet
/// pour savoir si l'utilisateur est connecté et afficher les erreurs.
class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  AuthProvider({required this.repository}) {
    // Récupère l'utilisateur déjà connecté au démarrage (session persistée)
    _currentUser = repository.getCurrentUser();
    // Écoute les changements (login/logout) pour mettre à jour l'UI automatiquement
    repository.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    try {
      _currentUser = await repository.signIn(email: email, password: password);
      _errorMessage = null;
      _setLoading(false);
      return true;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      _errorMessage = null;
      _setLoading(false);
      return true;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await repository.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
