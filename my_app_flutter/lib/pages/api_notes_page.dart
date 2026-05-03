import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/note.dart';

class ApiNotesPage extends StatefulWidget {
  const ApiNotesPage({super.key});

  @override
  State<ApiNotesPage> createState() => _ApiNotesPageState();
}

class _ApiNotesPageState extends State<ApiNotesPage> {
  final ApiService _apiService = ApiService();
  List<Note> _notes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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

  void _showAddNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add API Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _createNote(titleController.text, contentController.text);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createNote(String title, String content) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final newNote = await _apiService.createNote(title, content);
      setState(() {
        _notes.insert(0, newNote);
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note created successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create note: $e')),
        );
      }
    }
  }

  Future<void> _deleteNote(String id, int index) async {
    final note = _notes[index];
    setState(() {
      _notes.removeAt(index);
    });

    try {
      final success = await _apiService.deleteNote(id);
      if (!success) {
        throw Exception('Server returned error');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted')),
        );
      }
    } catch (e) {
      setState(() {
        _notes.insert(index, note);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete note: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotes,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('Error: $_errorMessage', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchNotes,
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Dismissible(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
