import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/notes/data/datasources/notes_remote_datasource.dart';
import 'features/notes/data/repositories/notes_repository_impl.dart';
import 'features/notes/presentation/pages/notes_list_page.dart';
import 'features/notes/presentation/providers/notes_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientProvider.initialize();
  runApp(const NotelyApp());
}

class NotelyApp extends StatelessWidget {
  const NotelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repository: AuthRepositoryImpl(
              remoteDataSource: AuthRemoteDataSourceImpl(
                supabaseClient: SupabaseClientProvider.client,
              ),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => NotesProvider(
            repository: NotesRepositoryImpl(
              remoteDataSource: NotesRemoteDataSourceImpl(
                supabaseClient: SupabaseClientProvider.client,
              ),
            ),
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
          '/notes': (context) => const NotesListPage(),
        },
      ),
    );
  }
}
