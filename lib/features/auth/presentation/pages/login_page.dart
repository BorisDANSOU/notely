import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Toujours libérer les controllers pour éviter les fuites mémoire
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Ne rien faire si les champs ne sont pas valides
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/notes');
    }
    // En cas d'échec, authProvider.errorMessage est mis à jour
    // et affiché automatiquement grâce au Consumer plus bas.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text('Heureux de vous revoir', style: AppTextStyles.heading1),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous pour retrouver vos notes.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 32),

                AuthTextField(
                  controller: _emailController,
                  label: 'Adresse courriel',
                  hint: 'sophie.martin@studio.fr',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'L\'email est requis.';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalide.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                AuthTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hint: '••••••••••',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le mot de passe est requis.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Affiche le message d'erreur du provider si présent
                // (ex: identifiants invalides, erreur réseau)
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.errorMessage == null) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        authProvider.errorMessage!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    );
                  },
                ),

                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _submit,
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.surface,
                                ),
                              )
                            : const Text('Se connecter'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.body,
                        children: [
                          const TextSpan(text: 'Nouveau sur Notely ? '),
                          TextSpan(
                            text: 'Créer un compte',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
