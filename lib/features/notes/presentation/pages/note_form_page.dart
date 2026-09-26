import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_provider.dart';

/// Écran de création et de modification d'une note.
/// Si existingNote est fourni, on est en mode édition.
/// Sinon, on est en mode création.
class NoteFormPage extends StatefulWidget {
  final Note? existingNote;

  const NoteFormPage({super.key, this.existingNote});

  bool get isEditing => existingNote != null;

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pré-remplit les champs si on modifie une note existante
    _titleController = TextEditingController(
      text: widget.existingNote?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.existingNote?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final notesProvider = context.read<NotesProvider>();

    try {
      if (widget.isEditing) {
        final updated = widget.existingNote!.copyWith(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          updatedAt: DateTime.now(),
        );
        await notesProvider.updateNote(updated);
      } else {
        await notesProvider.createNote(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
        );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(
        () => _errorMessage =
            'Impossible d\'enregistrer la note. Vérifie ta connexion.',
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette note ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Supprimer', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<NotesProvider>().deleteNote(widget.existingNote!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Modifier la note' : 'Nouvelle note',
          style: AppTextStyles.heading2,
        ),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  style: AppTextStyles.heading2,
                  decoration: const InputDecoration(
                    hintText: 'Titre',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le titre est requis.';
                    }
                    return null;
                  },
                ),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),
                Expanded(
                  child: TextFormField(
                    controller: _contentController,
                    style: AppTextStyles.body,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: 'Écris ta note ici...',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le contenu ne peut pas être vide.';
                      }
                      return null;
                    },
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.surface,
                            ),
                          )
                        : Text(
                            widget.isEditing ? 'Enregistrer' : 'Créer la note',
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
