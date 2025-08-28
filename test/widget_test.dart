// Chitti app widget tests
//
// This file contains basic smoke tests for the Chitti educational app.
// For comprehensive test coverage, see the test/ directory structure.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chitti/main.dart';

void main() {
  group('Chitti App Basic Tests', () {
    testWidgets('App should launch without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that the app launches and shows the MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Should not throw any exceptions during initialization
      expect(tester.takeException(), isNull);
    });

    testWidgets('App should handle theme correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Verify MaterialApp is using Material 3
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.useMaterial3, true);
      expect(materialApp.darkTheme?.useMaterial3, true);
    });

    testWidgets('App should show correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'Chitti');
    });

    testWidgets('App should handle orientation changes', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Test landscape orientation
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pump();
      expect(tester.takeException(), isNull);
      
      // Test portrait orientation
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();
      expect(tester.takeException(), isNull);
      
      // Reset to default
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('App should be accessible', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Check that the app has semantic information
      final semantics = tester.getSemantics(find.byType(MaterialApp));
      expect(semantics, isNotNull);
    });
  });
}
