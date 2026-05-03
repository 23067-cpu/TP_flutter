import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteService {
  final SharedPreferences prefs;
  static const String _notesKey = 'local_notes';
  List<Note> _notes = [];

  NoteService(this.prefs) {
    _loadNotes();
  }

  List<Note> get notes => _notes;

  void _loadNotes() {
    final String? notesJson = prefs.getString(_notesKey);
    if (notesJson != null) {
      final List<dynamic> decodedList = jsonDecode(notesJson);
      _notes = decodedList.map((json) => Note.fromJson(json)).toList();
    }
  }

  Future<void> _saveNotes() async {
    final List<Map<String, dynamic>> notesMapList =
        _notes.map((note) => note.toJson()).toList();
    await prefs.setString(_notesKey, jsonEncode(notesMapList));
  }

  void addNote(String title, String content) {
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _notes.insert(0, newNote);
    _saveNotes();
  }

  void updateNote(String id, String title, String content) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index].title = title;
      _notes[index].content = content;
      _notes[index].updatedAt = DateTime.now();
      _saveNotes();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    _saveNotes();
  }
}
