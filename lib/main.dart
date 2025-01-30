import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'models/note.dart';
import 'providers/notes_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async calls pre-runApp
  runApp(
    ChangeNotifierProvider(
      create: (context) => NotesProvider()..loadNotes(), // Load notes at startup
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NotesSearchDelegate(),
              );
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
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(
                      '${note.content}\n${DateFormat('MMM dd, yyyy – hh:mm a').format(note.date)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => notesProvider.deleteNote(note.id),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteEntryScreen(
                          note: note,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NoteEntryScreen(),
          ),
        ),
      ),
    );
  }
}

class NoteEntryScreen extends StatelessWidget {
  final Note? note;

  const NoteEntryScreen({super.key, this.note});

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(note == null ? 'New Note' : 'Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (titleController.text.isEmpty) return;

                if (note == null) {
                  notesProvider.addNote(
                    Note(
                      id: DateTime.now().toString(),
                      title: titleController.text,
                      content: contentController.text,
                      date: DateTime.now(),
                    ),
                  );
                } else {
                  notesProvider.updateNote(
                    note!.id,
                    titleController.text,
                    contentController.text,
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NotesSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    notesProvider.setSearchQuery(query);
    return const HomeScreen(); // Reuse the HomeScreen list with filtered notes
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // Optional: Add suggestions
  }
}