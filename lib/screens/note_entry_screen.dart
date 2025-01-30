import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import '../models/note.dart';
import '../providers/notes_provider.dart';

class NoteEntryScreen extends StatefulWidget {
  final Note? note;

  const NoteEntryScreen({super.key, this.note});

  @override
  // ignore: library_private_types_in_public_api
  _NoteEntryScreenState createState() => _NoteEntryScreenState();
}

class _NoteEntryScreenState extends State<NoteEntryScreen> {
  final List<String> categories = ['Work', 'Personal', 'Shopping', 'Uncategorized'];
  late quill.QuillController _controller;
  late TextEditingController _titleController;
  late String _selectedCategory;
  late FocusNode _focusNode; // Focus node for QuillEditor

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _selectedCategory = widget.note?.category ?? 'Uncategorized';
    _focusNode = FocusNode();

    if (widget.note != null) {
      try {
        final contentJson = jsonDecode(widget.note!.content);
        _controller = quill.QuillController(
          document: quill.Document.fromJson(contentJson),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _controller = quill.QuillController.basic();
      }
    } else {
      _controller = quill.QuillController.basic();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.isEmpty) return;

    final contentJson = jsonEncode(_controller.document.toDelta().toJson());
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    if (widget.note == null) {
      notesProvider.addNote(
        Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          content: contentJson,
          date: DateTime.now(),
          category: _selectedCategory,
        ),
      );
    } else {
      notesProvider.updateNote(
        widget.note!.id,
        _titleController.text,
        contentJson,
        _selectedCategory,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.note == null ? 'New Note' : 'Edit Note')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // QUILL TOOLBAR
            quill.QuillToolbar.simple(controller: _controller),

            // QUILL EDITOR
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: quill.QuillEditor.basic(
                  controller: _controller,
                  focusNode: _focusNode,
                  //readOnly: false, // Allow editing
                ),
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveNote,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
