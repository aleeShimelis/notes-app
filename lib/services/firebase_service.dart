import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notesapp2/models/note.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final CollectionReference _notesRef = _db.collection('notes');

  static Future<void> syncNoteToFirebase(Note note) async {
    try {
      await _notesRef.doc(note.id).set(note.toJson());
    } catch (e) {
      print("Error syncing note to Firebase: $e");
    }
  }

  static Future<void> deleteNoteFromFirebase(String noteId) async {
    try {
      await _notesRef.doc(noteId).delete();
    } catch (e) {
      print("Error deleting note from Firebase: $e");
    }
  }

  static Future<List<Note>> loadNotesFromFirebase() async {
    try {
      QuerySnapshot snapshot = await _notesRef.get();
      return snapshot.docs.map((doc) => Note.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error loading notes from Firebase: $e");
      return [];
    }
  }
}