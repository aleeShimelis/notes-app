import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/notes_storage.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

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
    FirebaseService.syncNoteToFirebase(note); 

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
      FirebaseService.syncNoteToFirebase(_notes[index]); 
    }
  }


  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    _saveNotes();
    notifyListeners();
    FirebaseService.deleteNoteFromFirebase(id); 
    NotificationService.cancelNotification(id);
  }

  void togglePinStatus(String id) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index].isPinned = !_notes[index].isPinned;
      _saveNotes();
      notifyListeners();
      FirebaseService.syncNoteToFirebase(_notes[index]); 
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
      FirebaseService.syncNoteToFirebase(_notes[index]); 
    }
  }
}
