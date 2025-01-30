import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/notes_storage.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  String _searchQuery = '';

  List<Note> get notes => _searchQuery.isEmpty
      ? _notes
      : _notes.where((note) => note.title.contains(_searchQuery)).toList();

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Load notes from storage on app startup
  Future<void> loadNotes() async {
    _notes = await NotesStorage.loadNotes();
    notifyListeners();
  }

  // Save notes after every change
  Future<void> _saveNotes() async {
    await NotesStorage.saveNotes(_notes);
  }

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
    _saveNotes(); // Auto-save
  }

  void updateNote(String id, String newTitle, String newContent) {
    final index = _notes.indexWhere((note) => note.id == id);
    _notes[index] = Note(
      id: id,
      title: newTitle,
      content: newContent,
      date: DateTime.now(),
    );
    notifyListeners();
    _saveNotes(); // Auto-save
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
    _saveNotes(); // Auto-save
  }
}