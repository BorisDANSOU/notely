import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/cache/hive_config.dart';
import 'core/di/injection_container.dart';
import 'core/network/network_info.dart';
import 'core/network/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/notes/domain/repositories/notes_repository.dart';
import 'features/notes/presentation/pages/home_page.dart';
import 'features/notes/presentation/providers/notes_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientProvider.initialize();
  await HiveConfig.initialize();
  // Construit toutes les dépendances (repositories, datasources, réseau)
  // à un seul endroit, injectées ensuite via leurs interfaces uniquement.
  await initDependencies();
  runApp(const NotelyApp());
}

class NotelyApp extends StatelessWidget {
  const NotelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: sl<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => NotesProvider(
            repository: sl<NotesRepository>(),
            networkInfo: sl<NetworkInfo>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Notely',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/notes': (context) => const HomePage(),
        },
      ),
    );
  }
}
