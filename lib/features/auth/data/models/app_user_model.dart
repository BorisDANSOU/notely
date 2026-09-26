import '../../domain/entities/app_user.dart';

//Modèle de données pour l'utilisateur

class AppUserModel extends AppUser {
  const AppUserModel({required super.id, required super.email, super.fullName});
}
