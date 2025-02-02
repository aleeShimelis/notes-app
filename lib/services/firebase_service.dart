import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final CollectionReference _notesRef = _db.collection('notes');


  static Future<void> syncNoteToFirebase(Note note) async {
    await _notesRef.doc(note.id).set(note.toJson());
  }

 
  static Future<void> deleteNoteFromFirebase(String noteId) async {
    await _notesRef.doc(noteId).delete();
  }


  static Future<List<Note>> loadNotesFromFirebase() async {
    QuerySnapshot snapshot = await _notesRef.get();
    return snapshot.docs.map((doc) => Note.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }
}
