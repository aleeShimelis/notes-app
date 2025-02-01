import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import 'package:intl/intl.dart';
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
  bool _isPinned = false;
  DateTime? _reminder;
  List<String> _selectedTags = [];
  final List<String> availableTags = ['Work', 'Personal', 'Ideas', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note?.title ?? '';
    _selectedTags = widget.note?.tags ?? [];
    _isPinned = widget.note?.isPinned ?? false;
    _reminder = widget.note?.reminder;

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

  void _pickReminder() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminder ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _reminder = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _removeReminder() {
    setState(() {
      _reminder = null;
    });
  }

  void _saveNote() {
    if (_titleController.text.isEmpty) return;

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    final contentJson = jsonEncode(_controller.document.toDelta().toJson());

    if (widget.note == null) {
      notesProvider.addNote(Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: contentJson,
        date: DateTime.now(),
        tags: _selectedTags,
        isPinned: _isPinned,
        reminder: _reminder,
      ));
    } else {
      notesProvider.updateNote(
        widget.note!.id,
        _titleController.text,
        contentJson,
        _selectedTags,
        _isPinned,
      );
      notesProvider.setReminder(widget.note!.id, _reminder);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? Colors.blue : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
              });
            },
          ),
        ],
      ),
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
            // Reminder Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _reminder == null
                      ? "No Reminder Set"
                      : "Reminder: ${DateFormat('MMM dd, yyyy – HH:mm').format(_reminder!)}",
                  style: TextStyle(color: _reminder == null ? Colors.grey : Colors.red),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.alarm, color: Colors.red),
                      onPressed: _pickReminder,
                    ),
                    if (_reminder != null)
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: _removeReminder,
                      ),
                  ],
                ),
              ],
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
