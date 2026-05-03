import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteService {
  final SharedPreferences prefs;
  // Clé constante utilisée pour identifier nos données dans SharedPreferences
  static const String _notesKey = 'local_notes';
  
  // Liste privée pour stocker les notes en mémoire
  List<Note> _notes = [];

  // Constructeur qui initialise SharedPreferences et charge les notes au démarrage
  NoteService(this.prefs) {
    _loadNotes();
  }

  // Getter public pour accéder à la liste des notes
  List<Note> get notes => _notes;

  // Méthode privée pour charger les notes depuis le stockage local
  void _loadNotes() {
    final String? notesJson = prefs.getString(_notesKey);
    if (notesJson != null) {
      final List<dynamic> decodedList = jsonDecode(notesJson);
      _notes = decodedList.map((json) => Note.fromJson(json as Map<String, dynamic>)).toList();
    }
  }

  // Méthode privée pour sauvegarder l'état actuel des notes dans le stockage local
  Future<void> _saveNotes() async {
    final List<Map<String, dynamic>> notesMapList =
        _notes.map((note) => note.toJson()).toList();
    await prefs.setString(_notesKey, jsonEncode(notesMapList));
  }

  // Ajouter une nouvelle note et l'enregistrer localement
  void addNote(String title, String content) {
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID unique basé sur l'horodatage
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _notes.insert(0, newNote); // Ajouter au début de la liste
    _saveNotes(); // Sauvegarder immédiatement
  }

  // Mettre à jour une note existante en utilisant son ID
  void updateNote(String id, String title, String content) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index].title = title;
      _notes[index].content = content;
      _notes[index].updatedAt = DateTime.now(); // Actualiser la date de modification
      _saveNotes(); // Sauvegarder les changements
    }
  }

  // Supprimer une note par son ID
  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    _saveNotes(); // Sauvegarder l'état après suppression
  }
}
