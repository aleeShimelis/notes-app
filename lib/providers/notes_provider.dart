import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/notes_storage.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  String _searchQuery = '';
  List<String> _selectedTags = [];

  List<Note> get notes {
    List<Note> filteredNotes = _notes;

    if (_searchQuery.isNotEmpty) {
      filteredNotes = filteredNotes.where((note) =>
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (_selectedTags.isNotEmpty) {
      filteredNotes = filteredNotes.where((note) =>
          _selectedTags.every((tag) => note.tags.contains(tag))).toList();
    }

    return filteredNotes;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTagsFilter(List<String> tags) {
    _selectedTags = [...tags]; // Ensuring state change
    notifyListeners();
  }

  Future<void> loadNotes() async {
    try {
      _notes = await NotesStorage.loadNotes();
    } catch (e) {
      _notes = [];
    }
    notifyListeners();
  }

  Future<void> _saveNotes() async {
    await NotesStorage.saveNotes(_notes);
  }

  void addNote(Note note) {
    _notes.add(note);
    _saveNotes();
    notifyListeners();
  }

  void updateNote(String id, String newTitle, String newContent, List<String> newTags) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = Note(
        id: id,
        title: newTitle,
        content: newContent,
        date: DateTime.now(),
        tags: newTags,
      );
      _saveNotes();
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    _saveNotes();
    notifyListeners();
  }
}
