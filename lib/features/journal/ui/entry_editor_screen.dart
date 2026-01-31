import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../logic/journal_provider.dart';
import '../models/journal_entry.dart';
import '../../auth/logic/auth_provider.dart';

class EntryEditorScreen extends ConsumerStatefulWidget {
  final JournalEntry? entry;

  const EntryEditorScreen({super.key, this.entry});

  @override
  ConsumerState<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends ConsumerState<EntryEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isFavorite = false;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.entry != null;
    if (_isEditing) {
      _titleController.text = widget.entry!.title ?? '';
      _contentController.text = widget.entry!.content;
      _isFavorite = widget.entry!.isFavorite;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please write something in your journal.')),
      );
      return;
    }

    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    final now = DateTime.now();

    if (_isEditing) {
      final updatedEntry = widget.entry!.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        isFavorite: _isFavorite,
        updatedAt: now,
      );
      await ref.read(journalProvider.notifier).updateEntry(updatedEntry);
    } else {
      final newEntry = JournalEntry(
        id: const Uuid().v4(),
        userId: userId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        isFavorite: _isFavorite,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(journalProvider.notifier).addEntry(newEntry);
    }

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _deleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text(
            'This action cannot be undone. The entry will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(journalProvider.notifier).deleteEntry(widget.entry!.id);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'New Entry'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _deleteEntry,
            ),
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title (optional)',
                border: InputBorder.none,
              ),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'Dear Journal...',
                border: InputBorder.none,
              ),
              maxLines: null,
              minLines: 10,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 16, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'AI Mood Analysis Active',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: _isFavorite
                        ? Colors.red.withOpacity(0.1)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => setState(() => _isFavorite = !_isFavorite),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
