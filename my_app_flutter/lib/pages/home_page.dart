import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/note_service.dart';
import '../models/note.dart';
import 'api_notes_page.dart';

class HomePage extends StatefulWidget {
  final NoteService noteService;

  const HomePage({super.key, required this.noteService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variable pour suivre l'état de la connexion internet
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity(); // Vérification initiale
    
    // Écouter les changements de connexion en temps réel
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool isConnected = results.isNotEmpty && results.first != ConnectivityResult.none;
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });
  }

  // Vérifier la connexion internet actuelle
  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = results.isNotEmpty && results.first != ConnectivityResult.none;
    });
  }

  // Afficher une boîte de dialogue pour ajouter ou modifier une note
  void _showAddNoteDialog(BuildContext context, {Note? existingNote}) {
    final titleController = TextEditingController(text: existingNote?.title ?? '');
    final contentController = TextEditingController(text: existingNote?.content ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingNote == null ? 'Ajouter une note' : 'Modifier la note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Contenu'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  setState(() {
                    if (existingNote == null) {
                      // Créer une nouvelle note locale
                      widget.noteService.addNote(
                        titleController.text,
                        contentController.text,
                      );
                    } else {
                      // Mettre à jour la note existante
                      widget.noteService.updateNote(
                        existingNote.id,
                        titleController.text,
                        contentController.text,
                      );
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloc-Notes'),
        actions: [
          // Icône indiquant si l'appareil est en ligne ou hors ligne
          IconButton(
            icon: Icon(
              _isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            tooltip: _isConnected ? 'En ligne' : 'Hors ligne',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isConnected ? 'Vous êtes en ligne' : 'Vous êtes hors ligne'),
                ),
              );
            },
          ),
          // Bouton de synchronisation visible uniquement si connecté
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'Synchronisation API',
              onPressed: () {
                // Naviguer vers la page de l'API
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ApiNotesPage()),
                );
              },
            ),
        ],
      ),
      // Afficher un message si aucune note locale, sinon afficher la liste
      body: widget.noteService.notes.isEmpty
          ? Center(
              child: Text(
                _isConnected
                    ? 'Aucune note locale. Appuyez sur synchroniser pour voir l\'API.'
                    : 'Aucune note locale et vous êtes hors ligne.',
                style: const TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: widget.noteService.notes.length,
              itemBuilder: (context, index) {
                final note = widget.noteService.notes[index];
                // Dismissible permet de supprimer en balayant (swipe)
                return Dismissible(
                  key: Key(note.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      widget.noteService.deleteNote(note.id); // Suppression locale
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note supprimée')),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () => _showAddNoteDialog(context, existingNote: note),
                    ),
                  ),
                );
              },
            ),
      // Bouton d'action flottant pour ajouter une nouvelle note locale
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
