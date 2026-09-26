import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../notes/presentation/providers/notes_provider.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Tu devras te reconnecter pour accéder à tes notes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Déconnexion',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final notesCount = context.watch<NotesProvider>().notes.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Profil', style: AppTextStyles.heading2)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar simple avec l'initiale du nom (pas de photo requise
              // par le cahier des charges, on reste sur du texte)
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (user?.fullName?.isNotEmpty == true
                                ? user!.fullName![0]
                                : user?.email[0] ?? '?')
                            .toUpperCase(),
                        style: AppTextStyles.heading1.copyWith(
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'Utilisateur',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '', style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Carte compteur de notes
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      '$notesCount',
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notesCount > 1 ? 'Notes' : 'Note',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Spacer(),

              // Bouton de déconnexion, bien visible en bas de l'écran
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmSignOut(context),
                  icon: Icon(Icons.logout, color: AppColors.error),
                  label: Text(
                    'Déconnexion',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
