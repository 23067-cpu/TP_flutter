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
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool isConnected = results.isNotEmpty && results.first != ConnectivityResult.none;
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = results.isNotEmpty && results.first != ConnectivityResult.none;
    });
  }

  void _showAddNoteDialog(BuildContext context, {Note? existingNote}) {
    final titleController = TextEditingController(text: existingNote?.title ?? '');
    final contentController = TextEditingController(text: existingNote?.content ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingNote == null ? 'Add Note' : 'Edit Note'),
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
              onPressed: () {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  setState(() {
                    if (existingNote == null) {
                      widget.noteService.addNote(
                        titleController.text,
                        contentController.text,
                      );
                    } else {
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
              child: const Text('Save'),
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
          IconButton(
            icon: Icon(
              _isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            tooltip: _isConnected ? 'Online' : 'Offline',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isConnected ? 'You are online' : 'You are offline'),
                ),
              );
            },
          ),
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'API Sync',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ApiNotesPage()),
                );
              },
            ),
        ],
      ),
      body: widget.noteService.notes.isEmpty
          ? Center(
              child: Text(
                _isConnected
                    ? 'No local notes. Tap sync to view remote notes.'
                    : 'No local notes and offline.',
                style: const TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: widget.noteService.notes.length,
              itemBuilder: (context, index) {
                final note = widget.noteService.notes[index];
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
                      widget.noteService.deleteNote(note.id);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note deleted')),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
