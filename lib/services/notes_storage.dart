import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

class NotesStorage {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/notes.json');
  }

  static Future<List<Note>> loadNotes() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final List<dynamic> jsonNotes = jsonDecode(contents);
      return jsonNotes.map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<File> saveNotes(List<Note> notes) async {
    final file = await _localFile;
    final jsonNotes = notes.map((note) => note.toJson()).toList();
    return file.writeAsString(jsonEncode(jsonNotes));
  }
}