import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notes_provider.dart';
import 'note_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final notes = notesProvider.notes;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Notes"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (tag) {
              setState(() {
                if (_selectedTags.contains(tag)) {
                  _selectedTags.remove(tag);
                } else {
                  _selectedTags.add(tag);
                }
              });
              notesProvider.setTagsFilter(_selectedTags);
            },
            itemBuilder: (context) {
              return ["Work", "Personal", "Ideas", "Urgent"].map((tag) {
                return CheckedPopupMenuItem(
                  value: tag,
                  checked: _selectedTags.contains(tag),
                  child: Text(tag),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Wrap(
                spacing: 8.0,
                children: _selectedTags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        _selectedTags.remove(tag);
                      });
                      notesProvider.setTagsFilter(_selectedTags);
                    },
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text('No notes found!'))
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return ListTile(
                        title: Text(note.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('MMM dd, yyyy').format(note.date)),
                            if (note.reminder != null)
                              Row(
                                children: [
                                  const Icon(Icons.alarm, size: 16, color: Colors.red),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Reminder: ${DateFormat('MMM dd, yyyy – HH:mm').format(note.reminder!)}",
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (note.tags.isNotEmpty)
                              Wrap(
                                spacing: 4.0,
                                children: note.tags.map((tag) {
                                  return Chip(
                                    label: Text(tag, style: const TextStyle(fontSize: 10)),
                                    visualDensity: VisualDensity.compact,
                                  );
                                }).toList(),
                              ),
                            IconButton(
                              icon: Icon(
                                note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                color: note.isPinned ? Colors.blue : Colors.grey,
                              ),
                              onPressed: () {
                                notesProvider.togglePinStatus(note.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _confirmDelete(context, notesProvider, note.id);
                              },
                            ),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NoteEntryScreen(note: note)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NoteEntryScreen()),
        ),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(BuildContext context, NotesProvider provider, String noteId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Note"),
          content: const Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                provider.deleteNote(noteId);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}