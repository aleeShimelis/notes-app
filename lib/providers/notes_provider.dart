import 'package:flutter/foundation.dart';
import 'package:notesapp2/models/note.dart';
import 'package:notesapp2/services/notes_storage.dart';
import 'package:notesapp2/services/firebase_service.dart';
import 'package:notesapp2/services/notification_service.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  String _searchQuery = "";
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
    filteredNotes.sort((a, b) {
      if (a.isPinned == b.isPinned) {
        return b.date.compareTo(a.date);
      }
      return b.isPinned ? 1 : -1;
    });
    return filteredNotes;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTagsFilter(List<String> tags) {
    _selectedTags = [...tags];
    notifyListeners();
  }

  Future<void> loadNotes() async {
    try {
      _notes = await FirebaseService.loadNotesFromFirebase();
    } catch (e) {
      print("Error loading notes: $e");
      _notes = [];
    }
    notifyListeners();
  }

  Future<void> _saveNotes() async {
    try {
      await NotesStorage.saveNotes(_notes);
    } catch (e) {
      print("Error saving notes: $e");
    }
  }

  void addNote(Note note) {
    _notes.add(note);
    _saveNotes();
    notifyListeners();
    try {
      FirebaseService.syncNoteToFirebase(note);
    } catch (e) {
      print("Error syncing note to Firebase: $e");
    }
    if (note.reminder != null) {
      NotificationService.scheduleNotification(
        note.id,
        "Reminder for ${note.title}",
        "Don't forget your note!",
        note.reminder!,
      );
    }
  }

  void updateNote(String id, String newTitle, String newContent, List<String> newTags, bool isPinned) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = Note(
        id: id,
        title: newTitle,
        content: newContent,
        date: DateTime.now(),
        tags: newTags,
        isPinned: isPinned,
        reminder: _notes[index].reminder,
      );
      _saveNotes();
      notifyListeners();
      try {
        FirebaseService.syncNoteToFirebase(_notes[index]);
      } catch (e) {
        print("Error syncing note to Firebase: $e");
      }
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    _saveNotes();
    notifyListeners();
    try {
      FirebaseService.deleteNoteFromFirebase(id);
    } catch (e) {
      print("Error deleting note from Firebase: $e");
    }
    NotificationService.cancelNotification(id);
  }

  void togglePinStatus(String id) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index].isPinned = !_notes[index].isPinned;
      _saveNotes();
      notifyListeners();
      try {
        FirebaseService.syncNoteToFirebase(_notes[index]);
      } catch (e) {
        print("Error syncing note to Firebase: $e");
      }
    }
  }

  void setReminder(String id, DateTime? reminder) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = Note(
        id: _notes[index].id,
        title: _notes[index].title,
        content: _notes[index].content,
        date: _notes[index].date,
        tags: _notes[index].tags,
        isPinned: _notes[index].isPinned,
        reminder: reminder,
      );
      if (reminder != null) {
        NotificationService.scheduleNotification(
          id,
          "Reminder for ${_notes[index].title}",
          "Don't forget your note!",
          reminder,
        );
      } else {
        NotificationService.cancelNotification(id);
      }
      _saveNotes();
      notifyListeners();
      try {
        FirebaseService.syncNoteToFirebase(_notes[index]);
      } catch (e) {
        print("Error syncing note to Firebase: $e");
      }
    }
  }
}