/// Note editor screen with AppFlowy rich text editor.
///
/// Features auto-save, image insertion, and rich text formatting toolbar.
library;

import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notes_provider.dart';
import '../services/image_service.dart';
import '../themes/theme_config.dart';
import '../utils/constants.dart' as app_constants;

/// Auto-save debounce duration.
const _autoSaveDelay = Duration(seconds: 2);

/// The note editor screen with rich text editing capabilities.
class NoteEditorScreen extends ConsumerStatefulWidget {
  /// ID of the note to edit. Null for new notes.
  final String noteId;

  /// Callback when saving is complete and navigating back.
  final VoidCallback onSave;

  /// Creates a [NoteEditorScreen] widget.
  const NoteEditorScreen({
    super.key,
    required this.noteId,
    required this.onSave,
  });

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  late EditorState _editorState;
  final ImageService _imageService = ImageService();

  Timer? _autoSaveTimer;
  bool _isSaving = false;
  bool _hasChanges = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _editorState = EditorState.blank();
    _initializeEditor();
  }

  void _initializeEditor() {
    final note = ref.read(noteByIdProvider(widget.noteId));

    if (note != null) {
      _titleController.text = note.title;

      // Try to parse existing content
      try {
        if (note.content.isNotEmpty) {
          final document = Document.blank();
          // For now, add content as a paragraph
          final lines = note.content.split('\n');
          for (final line in lines) {
            if (line.isNotEmpty) {
              document.insert(
                [document.root.children.length],
                [paragraphNode(text: line)],
              );
            }
          }
          _editorState = EditorState(document: document);
        }
      } catch (e) {
        // Fall back to blank editor
        _editorState = EditorState.blank();
      }
    }

    // Listen for title changes
    _titleController.addListener(_onContentChanged);

    setState(() {
      _isInitialized = true;
    });
  }

  void _onContentChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(_autoSaveDelay, _saveNote);
  }

  Future<void> _saveNote() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final note = ref.read(noteByIdProvider(widget.noteId));
      if (note == null) return;

      // Get content from editor - simplified approach
      final content = _extractTextFromEditor();

      final updatedNote = note.copyWith(
        title: _titleController.text,
        content: content,
        updatedAt: DateTime.now(),
      );

      await ref.read(notesProvider.notifier).updateNote(updatedNote);

      setState(() {
        _hasChanges = false;
      });
    } catch (e) {
      // Handle save error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(app_constants.Strings.errorSaving),
            backgroundColor: ThemeConfig.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Extracts plain text from the editor document.
  String _extractTextFromEditor() {
    final buffer = StringBuffer();
    for (final node in _editorState.document.root.children) {
      final text = node.delta?.toPlainText() ?? '';
      if (text.isNotEmpty) {
        if (buffer.isNotEmpty) buffer.write('\n');
        buffer.write(text);
      }
    }
    return buffer.toString();
  }

  Future<void> _insertImage() async {
    final imagePath = await _imageService.pickImageFromGallery();
    if (imagePath != null && mounted) {
      // Insert image into editor
      final transaction = _editorState.transaction;
      transaction.insertNode(
        _editorState.selection?.end.path ?? [0],
        imageNode(url: imagePath),
      );
      _editorState.apply(transaction);
      _onContentChanged();
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      await _saveNote();
    }
    return true;
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop && _hasChanges) {
          await _saveNote();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context, isDark, theme),
        body: !_isInitialized
            ? const Center(
                child: CircularProgressIndicator(
                  color: ThemeConfig.primaryAccent,
                ),
              )
            : Column(
                children: [
                  // Title input
                  _buildTitleInput(context, isDark, theme),

                  // Toolbar
                  _buildToolbar(context, isDark),

                  // Editor
                  Expanded(child: _buildEditor(context, isDark)),
                ],
              ),
      ),
    );
  }

  /// Builds the app bar.
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDark,
    ThemeData theme,
  ) {
    return AppBar(
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () async {
          await _onWillPop();
          widget.onSave();
        },
        child: Text(
          '< ${app_constants.Strings.notes}',
          style: TextStyle(
            color: ThemeConfig.primaryAccent,
            fontSize: ThemeConfig.fontSizeBody,
          ),
        ),
      ),
      leadingWidth: 80,
      title: Text(
        _titleController.text.isEmpty
            ? app_constants.Strings.untitledNote
            : _titleController.text,
        style: theme.textTheme.titleMedium,
      ),
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.only(right: ThemeConfig.spacingMd),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ThemeConfig.primaryAccent,
                ),
              ),
            ),
          )
        else
          CupertinoButton(
            padding: const EdgeInsets.only(right: ThemeConfig.spacingMd),
            onPressed: _saveNote,
            child: Text(
              _hasChanges
                  ? app_constants.Strings.save
                  : app_constants.Strings.saved,
              style: TextStyle(
                color: _hasChanges
                    ? ThemeConfig.primaryAccent
                    : ThemeConfig.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the title input field.
  Widget _buildTitleInput(BuildContext context, bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(ThemeConfig.spacingMd),
      child: TextField(
        controller: _titleController,
        style: theme.textTheme.displayLarge,
        decoration: InputDecoration(
          hintText: app_constants.Strings.untitledNote,
          hintStyle: theme.textTheme.displayLarge?.copyWith(
            color: isDark
                ? ThemeConfig.darkTextSecondary
                : ThemeConfig.lightTextSecondary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          fillColor: Colors.transparent,
          filled: false,
        ),
      ),
    );
  }

  /// Builds the formatting toolbar.
  Widget _buildToolbar(BuildContext context, bool isDark) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacingMd),
      child: Row(
        children: [
          _buildToolbarButton(
            icon: Icons.format_bold,
            onPressed: () => _applyFormat('bold'),
            isDark: isDark,
          ),
          _buildToolbarButton(
            icon: Icons.format_italic,
            onPressed: () => _applyFormat('italic'),
            isDark: isDark,
          ),
          _buildToolbarButton(
            icon: Icons.format_list_bulleted,
            onPressed: _onContentChanged,
            isDark: isDark,
          ),
          _buildToolbarButton(
            icon: Icons.image_outlined,
            onPressed: _insertImage,
            isDark: isDark,
          ),
          _buildToolbarButton(
            icon: Icons.format_quote,
            onPressed: _onContentChanged,
            isDark: isDark,
          ),
          _buildToolbarButton(
            icon: Icons.format_size,
            onPressed: _onContentChanged,
            isDark: isDark,
          ),
          _buildToolbarButton(
            icon: Icons.link,
            onPressed: _onContentChanged,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      iconSize: 22,
      color: isDark
          ? ThemeConfig.darkTextPrimary
          : ThemeConfig.lightTextPrimary,
      padding: const EdgeInsets.all(8),
    );
  }

  void _applyFormat(String format) {
    // Formatting is handled by AppFlowy Editor's built-in commands
    // This is a simplified placeholder - full implementation would use
    // AppFlowy's command system
    _onContentChanged();
  }

  /// Builds the AppFlowy editor.
  Widget _buildEditor(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacingMd),
      child: AppFlowyEditor(
        editorState: _editorState,
        editorStyle: _buildEditorStyle(isDark),
      ),
    );
  }

  EditorStyle _buildEditorStyle(bool isDark) {
    // Use mobile style which has sensible defaults for mobile/touch editing
    final baseStyle = EditorStyle.mobile(
      padding: const EdgeInsets.all(0),
      cursorColor: ThemeConfig.primaryAccent,
      selectionColor: ThemeConfig.primaryAccent.withAlpha(77),
      dragHandleColor: ThemeConfig.primaryAccent,
      textStyleConfiguration: TextStyleConfiguration(
        text: TextStyle(
          color: isDark
              ? ThemeConfig.darkTextPrimary
              : ThemeConfig.lightTextPrimary,
          fontSize: ThemeConfig.fontSizeBody,
        ),
      ),
    );
    return baseStyle;
  }
}
