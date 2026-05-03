import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/note.dart';

class ApiNotesPage extends StatefulWidget {
  const ApiNotesPage({super.key});

  @override
  State<ApiNotesPage> createState() => _ApiNotesPageState();
}

class _ApiNotesPageState extends State<ApiNotesPage> {
  // Instance du service API pour gérer les requêtes
  final ApiService _apiService = ApiService();
  
  // Variables d'état pour gérer l'affichage de la page
  List<Note> _notes = [];
  bool _isLoading = true; // Indicateur de chargement
  String? _errorMessage; // Stocke l'erreur éventuelle

  @override
  void initState() {
    super.initState();
    _fetchNotes(); // Récupération initiale des notes lors de l'ouverture de la page
  }

  // Fonction asynchrone pour charger toutes les notes depuis l'API
  Future<void> _fetchNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Réinitialiser l'erreur
    });

    try {
      final notes = await _apiService.getAllNotes();
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Affiche une boîte de dialogue pour créer une nouvelle note via l'API
  void _showAddNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une note API'),
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
              onPressed: () async {
                // Créer une note seulement si les champs ne sont pas vides
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  Navigator.pop(context); // Fermer la boîte de dialogue
                  _createNote(titleController.text, contentController.text);
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  // Création d'une note en effectuant une requête POST
  Future<void> _createNote(String title, String content) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final newNote = await _apiService.createNote(title, content);
      setState(() {
        _notes.insert(0, newNote); // L'insérer visuellement en haut de la liste
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note créée avec succès sur le serveur')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la création : $e')),
        );
      }
    }
  }

  // Suppression d'une note en effectuant une requête DELETE
  Future<void> _deleteNote(String id, int index) async {
    final note = _notes[index];
    
    // Suppression optimiste (immédiate) dans l'interface utilisateur
    setState(() {
      _notes.removeAt(index);
    });

    try {
      final success = await _apiService.deleteNote(id);
      if (!success) {
        throw Exception('Le serveur a renvoyé une erreur lors de la suppression');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note supprimée du serveur')),
        );
      }
    } catch (e) {
      // En cas d'échec, remettre la note dans la liste
      setState(() {
        _notes.insert(index, note);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la suppression : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes de l\'API'),
        actions: [
          // Bouton d'actualisation manuelle de l'API
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotes,
          )
        ],
      ),
      // Affichage du widget correspondant à l'état actuel (Chargement, Erreur ou Liste)
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Spinner pendant le chargement
          : _errorMessage != null
              ? Center(
                  // Affichage du message d'erreur si l'API échoue
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('Erreur : $_errorMessage', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchNotes,
                        child: const Text('Réessayer'),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Dismissible(
                      // Permettre de glisser pour supprimer la note via l'API
                      key: Key('${note.id}_$index'),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _deleteNote(note.id, index);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    );
                  },
                ),
      // Bouton permettant l'ajout d'une note via POST
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
