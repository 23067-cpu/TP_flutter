import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app_flutter/main.dart';
import 'package:my_app_flutter/services/note_service.dart';

void main() {
  // Test de base pour vérifier que l'application démarre correctement
  testWidgets('Test de fumée (Smoke test) pour Bloc-Notes', (WidgetTester tester) async {
    // 1. Initialiser une instance simulée (mock) de SharedPreferences pour les tests
    // Cela permet au test de s'exécuter sans nécessiter le stockage réel de l'appareil
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    
    // 2. Initialiser le service de notes avec l'instance simulée
    final noteService = NoteService(prefs);

    // 3. Construire notre application et déclencher un rendu visuel (frame)
    await tester.pumpWidget(MyApp(noteService: noteService));

    // 4. Vérifier que le titre 'Bloc-Notes' est présent à l'écran
    // Cela confirme que la page d'accueil (HomePage) s'est chargée correctement
    expect(find.text('Bloc-Notes'), findsOneWidget);
  });
}
