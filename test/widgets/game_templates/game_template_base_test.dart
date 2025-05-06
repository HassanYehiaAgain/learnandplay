import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learn_play_level_up_flutter/providers/accessibility_provider.dart';
import 'package:learn_play_level_up_flutter/widgets/game_templates/game_template_base.dart';
import 'package:learn_play_level_up_flutter/widgets/common/loading_indicator.dart';
import 'package:learn_play_level_up_flutter/widgets/common/error_display.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestWidget({
    required Widget child,
    String title = 'Test Title',
    String description = 'Test Description',
    bool isLoading = false,
    String? errorMessage,
    VoidCallback? onRetry,
    bool showAppBar = true,
    List<Widget>? actions,
    Widget? floatingActionButton,
    Color? backgroundColor,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AccessibilityProvider(prefs),
          ),
        ],
        child: GameTemplateBase(
          title: title,
          description: description,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRetry: onRetry,
          showAppBar: showAppBar,
          actions: actions,
          floatingActionButton: floatingActionButton,
          backgroundColor: backgroundColor,
          child: child,
        ),
      ),
    );
  }

  testWidgets('renders child when not loading and no error',
      (WidgetTester tester) async {
    const testChild = Text('Test Child');
    
    await tester.pumpWidget(buildTestWidget(child: testChild));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Test Title'), findsOneWidget);
    expect(find.byWidget(testChild), findsOneWidget);
  });

  testWidgets('shows loading indicator when loading',
      (WidgetTester tester) async {
    const testChild = Text('Test Child');
    
    await tester.pumpWidget(buildTestWidget(
      child: testChild,
      isLoading: true,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(LoadingIndicator), findsOneWidget);
    expect(find.byWidget(testChild), findsNothing);
  });

  testWidgets('shows error display when error message provided',
      (WidgetTester tester) async {
    const testChild = Text('Test Child');
    const errorMessage = 'Test Error';
    bool retryPressed = false;
    
    await tester.pumpWidget(buildTestWidget(
      child: testChild,
      errorMessage: errorMessage,
      onRetry: () => retryPressed = true,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorDisplay), findsOneWidget);
    expect(find.text(errorMessage), findsOneWidget);
    expect(find.byWidget(testChild), findsNothing);

    // Test retry button
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(retryPressed, isTrue);
  });

  testWidgets('hides app bar when showAppBar is false',
      (WidgetTester tester) async {
    const testChild = Text('Test Child');
    
    await tester.pumpWidget(buildTestWidget(
      child: testChild,
      showAppBar: false,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
  });

  testWidgets('shows actions when provided', (WidgetTester tester) async {
    const testChild = Text('Test Child');
    final actions = [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {},
      ),
    ];
    
    await tester.pumpWidget(buildTestWidget(
      child: testChild,
      actions: actions,
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.settings), findsOneWidget);
  });

  testWidgets('shows floating action button when provided',
      (WidgetTester tester) async {
    const testChild = Text('Test Child');
    bool fabPressed = false;
    final fab = FloatingActionButton(
      onPressed: () => fabPressed = true,
      child: const Icon(Icons.add),
    );
    
    await tester.pumpWidget(buildTestWidget(
      child: testChild,
      floatingActionButton: fab,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(fabPressed, isTrue);
  });

  testWidgets('applies custom background color when provided',
      (WidgetTester tester) async {
    const testChild = Text('Test Child');
    const backgroundColor = Colors.red;
    
    await tester.pumpWidget(buildTestWidget(
      child: testChild,
      backgroundColor: backgroundColor,
    ));
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, backgroundColor);
  });
} 