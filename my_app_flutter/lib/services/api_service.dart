import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Note>> getAllNotes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) {
          return Note(
            id: item['id'].toString(),
            title: item['title'] ?? '',
            content: item['body'] ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }).toList();
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (e) {
      throw Exception('Error fetching notes: $e');
    }
  }

  Future<Note> createNote(String title, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'body': content,
          'userId': 1,
        }),
      );

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
        throw Exception('Failed to create note');
      }
    } catch (e) {
      throw Exception('Error creating note: $e');
    }
  }

  Future<bool> deleteNote(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error deleting note: $e');
    }
  }
}
