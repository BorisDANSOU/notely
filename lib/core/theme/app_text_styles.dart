import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

///Styles de texte utilisés dans l'application : Lora (serif) pour les titres et Open Sans (sans-serif) pour le texte principal.
///Inter (sans serif) est utilisé pour les textes secondaires et les boutons.

class AppTextStyles {
  AppTextStyles._();

  //Titre principal (H1)
  static TextStyle get heading1 => GoogleFonts.lora(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  //Titre secondaire (H2)
  static TextStyle get heading2 => GoogleFonts.lora(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  //Texte courant (contenu des notes, lables, etc.)
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  //Texte des boutons (CTA)
  static TextStyle get button => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
  );
}
