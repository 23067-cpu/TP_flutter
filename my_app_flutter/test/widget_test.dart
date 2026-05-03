import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app_flutter/main.dart';
import 'package:my_app_flutter/services/note_service.dart';

void main() {
  testWidgets('Bloc-Notes smoke test', (WidgetTester tester) async {
    // Set up mock SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final noteService = NoteService(prefs);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(noteService: noteService));

    // Verify that the title 'Bloc-Notes' is present.
    expect(find.text('Bloc-Notes'), findsOneWidget);
  });
}
