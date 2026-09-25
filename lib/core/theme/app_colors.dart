import 'package:flutter/material.dart';

///Palette of colors used in the app
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary color used throughout the app
  static const background = Color(0xFFFDF1EA);

  //Surface colors (cartes, champs de texte, etc.)
  static const surface = Color(0xFFFFFFFF);

  //Couleur d'accentuation (boutons, liens, etc.)
  static const primary = Color(0xFFC0703A);

  //Texte principal (titres, textes, etc.)
  static const textPrimary = Color(0xFF2D2A26);

  //Texte secondaire (sous-titres, textes secondaires, etc.)
  static const textSecondary = Color(0xFF8A8078);

  //Bordure discrète (champs de texte, cartes, etc.)
  static const border = Color(0xFFE8DDD3);

  //Couleur d'erreur (messages d'erreur, etc.)
  static const error = Color(0xFFC0392B);

  //Couleur de succès (messages de succès, etc.)
  static const success = Color(0xFF4A7C59);
}
