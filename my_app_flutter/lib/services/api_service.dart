import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class ApiService {
  // L'URL de base de l'API REST factice (JSONPlaceholder) utilisée pour tester
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // Récupérer toutes les notes depuis l'API distante via la méthode GET
  Future<List<Note>> getAllNotes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));
      if (response.statusCode == 200) { // Succès de la requête
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) {
          // Convertir la réponse du serveur (JSONPlaceholder) en objets Note
          return Note(
            id: item['id'].toString(),
            title: item['title'] ?? '',
            content: item['body'] ?? '', // 'body' est utilisé au lieu de 'content' sur cette API
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }).toList();
      } else {
        throw Exception('Échec du chargement des notes depuis le serveur');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notes : $e');
    }
  }

  // Créer une nouvelle note sur le serveur distant via la méthode POST
  Future<Note> createNote(String title, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'}, // Préciser que nous envoyons du JSON
        body: jsonEncode({
          'title': title,
          'body': content,
          'userId': 1, // Requis par l'API JSONPlaceholder
        }),
      );

      // Codes 201 (Created) ou 200 (OK) indiquent un succès
      if (response.statusCode == 201 || response.statusCode == 200) {
        final item = jsonDecode(response.body);
        return Note(
          id: item['id'].toString(),
          title: item['title'] ?? title,
          content: item['body'] ?? content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        throw Exception('Échec de la création de la note sur le serveur');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de la note : $e');
    }
  }

  // Supprimer une note sur le serveur distant via la méthode DELETE
  Future<bool> deleteNote(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));
      // Codes 200 (OK) ou 204 (No Content) indiquent une suppression réussie
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la note : $e');
    }
  }
}
