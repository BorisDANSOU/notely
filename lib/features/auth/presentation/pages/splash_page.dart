import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';

/// Écran affiché au lancement de l'app, le temps de vérifier
/// si une session utilisateur est déjà active.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // On attend un court instant (petit effet visuel) avant de rediriger,
    // le temps que Supabase restaure la session locale si elle existe.
    Future.delayed(const Duration(milliseconds: 800), _redirect);
  }

  void _redirect() {
    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;

    // On utilise pushReplacementNamed pour empêcher de revenir
    // au Splash avec le bouton retour.
    Navigator.of(context)
        .pushReplacementNamed(isAuthenticated ? '/notes' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône simple en attendant l'intégration du vrai logo vectoriel
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.edit_note,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text('Notely', style: AppTextStyles.heading1),
            const SizedBox(height: 8),
            Text(
              'Vos pensées, organisées avec clarté.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
