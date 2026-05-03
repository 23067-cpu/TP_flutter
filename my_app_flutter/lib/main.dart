import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/note_service.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final noteService = NoteService(prefs);

  runApp(MyApp(noteService: noteService));
}

class MyApp extends StatelessWidget {
  final NoteService noteService;

  const MyApp({super.key, required this.noteService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloc-Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      ),
      themeMode: ThemeMode.system,
      home: HomePage(noteService: noteService),
    );
  }
}
