import 'package:flutter/material.dart';

import 'core/network/supabase_client.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  // avant runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Connexion à Supabase avant de lancer l'app
  await SupabaseClientProvider.initialize();

  runApp(const NotelyApp());
}

class NotelyApp extends StatelessWidget {
  const NotelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notely',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Pour l'instant un écran de test — on branchera le vrai Splash
      // Screen à l'étape suivante
      home: const Scaffold(
        body: Center(
          child: Text('Notely — connexion Supabase OK si pas d\'erreur'),
        ),
      ),
    );
  }
}
