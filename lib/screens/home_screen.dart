import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notes_provider.dart';
import 'note_entry_screen.dart';
import '../utils/extensions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (tag) {
              setState(() {
                _selectedTags.toggleItem(tag);
              });
              notesProvider.setTagsFilter(_selectedTags);
            },
            itemBuilder: (context) {
              return ['Work', 'Personal', 'Ideas', 'Urgent'].map((tag) {
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
      body: notesProvider.notes.isEmpty
          ? const Center(child: Text('No notes yet!'))
          : ListView.builder(
              itemCount: notesProvider.notes.length,
              itemBuilder: (context, index) {
                final note = notesProvider.notes[index];
                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(note.date)),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (context) => NoteEntryScreen(note: note),
                  )),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NoteEntryScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
