import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voxfable/main.dart';
import 'package:voxfable/feature/story/view/screens/story_screen.dart';

void main() {
  testWidgets('App loads and displays StoryScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify StoryScreen is rendered.
    expect(find.byType(StoryScreen), findsOneWidget);
  });
}
