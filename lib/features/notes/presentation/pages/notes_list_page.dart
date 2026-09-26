import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import 'note_form_page.dart';

class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  @override
  void initState() {
    super.initState();
    // Charge les notes dès l'affichage de l'écran.
    // addPostFrameCallback évite d'appeler notifyListeners() pendant le build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Mes notes', style: AppTextStyles.heading2)),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, _) {
          switch (notesProvider.status) {
            case NotesStatus.initial:
            case NotesStatus.loading:
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );

            case NotesStatus.error:
              return _ErrorState(
                message:
                    notesProvider.errorMessage ?? 'Une erreur est survenue.',
                onRetry: () => notesProvider.loadNotes(),
              );

            case NotesStatus.loaded:
              if (notesProvider.notes.isEmpty) {
                return const _EmptyState();
              }
              return RefreshIndicator(
                onRefresh: notesProvider.loadNotes,
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: notesProvider.notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final note = notesProvider.notes[index];
                    return NoteCard(
                      note: note,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => NoteFormPage(existingNote: note),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const NoteFormPage()));
        },
        child: const Icon(Icons.add, color: AppColors.surface),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.note_add_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text('Aucune note pour l\'instant', style: AppTextStyles.body),
          const SizedBox(height: 4),
          Text(
            'Appuie sur + pour créer ta première note.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
