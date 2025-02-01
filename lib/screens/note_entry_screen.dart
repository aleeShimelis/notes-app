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
  _NoteEntryScreenState createState() => _NoteEntryScreenState();
}

class _NoteEntryScreenState extends State<NoteEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  late quill.QuillController _controller;

  List<String> _selectedTags = [];
  final List<String> availableTags = ['Work', 'Personal', 'Ideas', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note?.title ?? '';
    _selectedTags = widget.note?.tags ?? [];

    try {
      final contentJson = widget.note?.content.isNotEmpty ?? false
          ? jsonDecode(widget.note!.content)
          : [];
      _controller = quill.QuillController(
        document: quill.Document.fromJson(contentJson),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      _controller = quill.QuillController.basic();
    }
  }

  void _saveNote() {
    if (_titleController.text.isEmpty) return;

    final contentJson = jsonEncode(_controller.document.toDelta().toJson());
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    if (widget.note == null) {
      notesProvider.addNote(Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: contentJson,
        date: DateTime.now(),
        tags: _selectedTags,
      ));
    } else {
      notesProvider.updateNote(
        widget.note!.id,
        _titleController.text,
        contentJson,
        _selectedTags,
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
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              children: availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      isSelected ? _selectedTags.remove(tag) : _selectedTags.add(tag);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            quill.QuillToolbar.simple(controller: _controller),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: quill.QuillEditor.basic(
                  controller: _controller,
                  focusNode: FocusNode(),
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
