import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../logic/journal_provider.dart';
import '../models/journal_entry.dart';
import '../../auth/logic/auth_provider.dart';
import '../../ai_insights/logic/ai_provider.dart';

enum BlockType { text, image }

class ContentBlock {
  final String id = const Uuid().v4();
  final BlockType type;
  String? text;
  String? imageUrl;
  Alignment alignment;
  TextEditingController? controller;
  FocusNode? focusNode;

  ContentBlock.text(this.text)
      : type = BlockType.text,
        alignment = Alignment.centerLeft {
    controller = TextEditingController(text: text);
    focusNode = FocusNode();
  }

  ContentBlock.image(this.imageUrl, {this.alignment = Alignment.centerLeft})
      : type = BlockType.image;

  void dispose() {
    controller?.dispose();
    focusNode?.dispose();
  }
}

class EntryEditorScreen extends ConsumerStatefulWidget {
  final JournalEntry? entry;

  const EntryEditorScreen({super.key, this.entry});

  @override
  ConsumerState<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends ConsumerState<EntryEditorScreen> {
  final _titleController = TextEditingController();
  final List<ContentBlock> _blocks = [];
  bool _isFavorite = false;
  late bool _isEditing;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.entry != null;
    if (_isEditing) {
      _titleController.text = widget.entry!.title ?? '';
      _isFavorite = widget.entry!.isFavorite;
      _parseContent(widget.entry!.content);
    } else {
      _blocks.add(ContentBlock.text(''));
    }
  }

  void _parseContent(String content) {
    if (content.isEmpty) {
      _blocks.add(ContentBlock.text(''));
      return;
    }

    // Updated parser: detects [[image:URL;align:LEFT|CENTER|RIGHT]]
    final regex = RegExp(r'\[\[image:(.*?)(?:;align:(LEFT|CENTER|RIGHT))?\]\]');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(content)) {
      final textBefore = content.substring(lastMatchEnd, match.start);
      if (textBefore.isNotEmpty || _blocks.isEmpty) {
        _blocks.add(ContentBlock.text(textBefore));
      }

      final url = match.group(1);
      final alignStr = match.group(2);

      Alignment alignment = Alignment.centerLeft;
      if (alignStr == 'CENTER') alignment = Alignment.center;
      if (alignStr == 'RIGHT') alignment = Alignment.centerRight;

      _blocks.add(ContentBlock.image(url, alignment: alignment));
      lastMatchEnd = match.end;
    }

    final remainingText = content.substring(lastMatchEnd);
    if (remainingText.isNotEmpty ||
        _blocks.isEmpty ||
        _blocks.last.type == BlockType.image) {
      _blocks.add(ContentBlock.text(remainingText));
    }
  }

  String _serialiseContent() {
    String content = '';
    for (var block in _blocks) {
      if (block.type == BlockType.text) {
        content += block.controller?.text ?? '';
      } else {
        String alignStr = 'LEFT';
        if (block.alignment == Alignment.center) alignStr = 'CENTER';
        if (block.alignment == Alignment.centerRight) alignStr = 'RIGHT';
        content += '[[image:${block.imageUrl};align:$alignStr]]';
      }
    }
    return content;
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var block in _blocks) {
      block.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() => _isUploading = true);
      try {
        final url = await ref
            .read(journalProvider.notifier)
            .uploadImage(File(image.path));
        if (url != null) {
          _insertImageBlock(url);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    }
  }

  void _insertImageBlock(String url) {
    int focusedIndex = -1;
    int cursorPosition = 0;

    for (int i = 0; i < _blocks.length; i++) {
      if (_blocks[i].type == BlockType.text &&
          _blocks[i].focusNode?.hasFocus == true) {
        focusedIndex = i;
        cursorPosition = _blocks[i].controller?.selection.baseOffset ?? 0;
        break;
      }
    }

    setState(() {
      if (focusedIndex == -1) {
        _blocks.add(ContentBlock.image(url));
        _blocks.add(ContentBlock.text(''));
      } else {
        final block = _blocks[focusedIndex];
        final text = block.controller!.text;
        final textBefore = text.substring(0, cursorPosition);
        final textAfter = text.substring(cursorPosition);

        block.controller!.text = textBefore;
        _blocks.insert(focusedIndex + 1, ContentBlock.image(url));
        _blocks.insert(focusedIndex + 2, ContentBlock.text(textAfter));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _blocks[focusedIndex + 2].focusNode?.requestFocus();
        });
      }
    });
  }

  Future<void> _saveEntry() async {
    final content = _serialiseContent();
    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please write something in your journal.')),
      );
      return;
    }

    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    final now = DateTime.now();
    final imageUrls = _blocks
        .where((b) => b.type == BlockType.image)
        .map((b) => b.imageUrl!)
        .toList();

    if (_isEditing) {
      final updatedEntry = widget.entry!.copyWith(
        title: _titleController.text.trim(),
        content: content,
        isFavorite: _isFavorite,
        imageUrls: imageUrls,
        updatedAt: now,
      );

      final result =
          await ref.read(journalProvider.notifier).updateEntry(updatedEntry);
      if (result != null) {
        ref.read(aiAnalysisProvider.notifier).analyzeAndSave(result);
      }
    } else {
      final newEntry = JournalEntry(
        id: const Uuid().v4(),
        userId: userId,
        title: _titleController.text.trim(),
        content: content,
        isFavorite: _isFavorite,
        imageUrls: imageUrls,
        createdAt: now,
        updatedAt: now,
      );

      final result =
          await ref.read(journalProvider.notifier).addEntry(newEntry);
      if (result != null) {
        ref.read(aiAnalysisProvider.notifier).analyzeAndSave(result);
      }
    }

    if (mounted) context.pop();
  }

  Future<void> _deleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
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
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFA), // Blended soft paper background
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'New Entry'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: _deleteEntry),
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _isUploading ? null : _saveEntry,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Entry Title',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverReorderableList(
              itemCount: _blocks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _blocks.removeAt(oldIndex);
                  _blocks.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final block = _blocks[index];
                return ReorderableDelayedDragStartListener(
                  key: ValueKey(block.id),
                  index: index,
                  child: _buildBlock(index, block),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildActionChip(
                        icon: Icons.image_outlined,
                        label: _isUploading ? 'Uploading...' : 'Insert Image',
                        onTap: _isUploading ? null : _pickImage,
                        active: true,
                      ),
                      const SizedBox(width: 12),
                      _buildActionChip(
                        icon: Icons.auto_awesome,
                        label: 'AI Ready',
                        active: true,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(_isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded),
                        color: _isFavorite ? Colors.red : null,
                        onPressed: () =>
                            setState(() => _isFavorite = !_isFavorite),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlock(int index, ContentBlock block) {
    if (block.type == BlockType.text) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: TextField(
          controller: block.controller,
          focusNode: block.focusNode,
          decoration: const InputDecoration(
            hintText: 'Start writing...',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          maxLines: null,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: Colors.blueGrey[800],
              ),
        ),
      );
    } else {
      return Align(
        alignment: block.alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (block.alignment == Alignment.centerLeft) {
                  block.alignment = Alignment.center;
                } else if (block.alignment == Alignment.center) {
                  block.alignment = Alignment.centerRight;
                } else {
                  block.alignment = Alignment.centerLeft;
                }
              });
            },
            child: Transform.rotate(
              angle: (index % 2 == 0 ? 0.04 : -0.04),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          block.imageUrl!,
                          width:
                              block.alignment == Alignment.center ? 200 : 150,
                          height:
                              block.alignment == Alignment.center ? 200 : 150,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          block.alignment == Alignment.centerLeft
                              ? Icons.format_align_left_rounded
                              : block.alignment == Alignment.center
                                  ? Icons.format_align_center_rounded
                                  : Icons.format_align_right_rounded,
                          size: 10,
                          color: Colors.blueGrey[200],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -10,
                    left: block.alignment == Alignment.center ? 75 : 50,
                    child: Transform.rotate(
                      angle: index % 2 == 0 ? 0.1 : -0.1,
                      child: Container(
                        width: 50,
                        height: 20,
                        color: const Color(0xFFFFD54F).withOpacity(0.4),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -10,
                    right: -10,
                    child: GestureDetector(
                      onTap: () => setState(() => _blocks.removeAt(index)),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4)
                          ],
                        ),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.blueGrey),
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

  Widget _buildActionChip(
      {required IconData icon,
      required String label,
      VoidCallback? onTap,
      bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: active ? Theme.of(context).primaryColor : Colors.grey),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: active
                        ? Theme.of(context).primaryColor
                        : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
