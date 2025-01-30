import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/notes_storage.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  String _searchQuery = '';
  String _categoryFilter = 'All';

  List<Note> get notes {
    List<Note> filteredNotes = _notes;
    if (_searchQuery.isNotEmpty) {
      filteredNotes = filteredNotes.where((note) =>
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_categoryFilter != 'All') {
      filteredNotes = filteredNotes.where((note) => note.category == _categoryFilter).toList();
    }
    return filteredNotes;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _categoryFilter = category;
    notifyListeners();
  }

  Future<void> loadNotes() async {
    _notes = await NotesStorage.loadNotes();
    notifyListeners();
  }

  Future<void> _saveNotes() async {
    await NotesStorage.saveNotes(_notes);
  }

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
    _saveNotes();
  }

  void updateNote(String id, String newTitle, String newContent, String newCategory) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = Note(
        id: id,
        title: newTitle,
        content: newContent,
        date: DateTime.now(),
        category: newCategory,
      );
      notifyListeners();
      _saveNotes();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
    _saveNotes();
  }
}
