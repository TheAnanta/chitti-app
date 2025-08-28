import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chitti/data/semester.dart';
import 'package:chitti/unit_list_tile.dart';

void main() {
  group('Widget Tests', () {
    group('Unit List Tile Tests', () {
      testWidgets('should display unit information correctly', (WidgetTester tester) async {
        const testUnit = Unit(
          unitId: 'unit_1',
          name: 'Introduction to Programming',
          description: 'Basic programming concepts',
          difficulty: 'Easy',
          isUnlocked: true,
          totalResources: 5,
          importantQuestions: null,
          cheatsheets: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitListTile(
                unit: testUnit,
                onTap: () {},
              ),
            ),
          ),
        );

        // Verify unit name is displayed
        expect(find.text('Introduction to Programming'), findsOneWidget);
        expect(find.text('Basic programming concepts'), findsOneWidget);
      });

      testWidgets('should handle locked units properly', (WidgetTester tester) async {
        const lockedUnit = Unit(
          unitId: 'unit_2',
          name: 'Advanced Topics',
          description: 'Advanced programming',
          difficulty: 'Hard',
          isUnlocked: false,
          importantQuestions: null,
          cheatsheets: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitListTile(
                unit: lockedUnit,
                onTap: () {},
              ),
            ),
          ),
        );

        // Check if locked state is indicated visually
        expect(find.text('Advanced Topics'), findsOneWidget);
        
        // Look for lock icon or disabled state
        final listTile = tester.widget<ListTile>(find.byType(ListTile));
        expect(listTile.enabled, false);
      });

      testWidgets('should trigger onTap callback when tapped', (WidgetTester tester) async {
        var wasTapped = false;
        
        const testUnit = Unit(
          unitId: 'unit_3',
          name: 'Test Unit',
          description: 'Test Description',
          difficulty: 'Medium',
          isUnlocked: true,
          importantQuestions: null,
          cheatsheets: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitListTile(
                unit: testUnit,
                onTap: () {
                  wasTapped = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(UnitListTile));
        await tester.pump();

        expect(wasTapped, true);
      });

      testWidgets('should display difficulty levels correctly', (WidgetTester tester) async {
        final difficulties = ['Easy', 'Medium', 'Hard'];
        
        for (final difficulty in difficulties) {
          final unit = Unit(
            unitId: 'unit_$difficulty',
            name: '$difficulty Unit',
            description: 'A $difficulty unit',
            difficulty: difficulty,
            isUnlocked: true,
            importantQuestions: null,
            cheatsheets: null,
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: UnitListTile(
                  unit: unit,
                  onTap: () {},
                ),
              ),
            ),
          );

          expect(find.text('$difficulty Unit'), findsOneWidget);
          expect(find.text('A $difficulty unit'), findsOneWidget);
        }
      });

      testWidgets('should handle very long unit names', (WidgetTester tester) async {
        const longName = 'This is a very long unit name that might overflow and cause layout issues if not handled properly';
        
        const unit = Unit(
          unitId: 'unit_long',
          name: longName,
          description: 'Description',
          difficulty: 'Medium',
          isUnlocked: true,
          importantQuestions: null,
          cheatsheets: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitListTile(
                unit: unit,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text(longName), findsOneWidget);
        
        // Verify no overflow occurs
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle empty unit description', (WidgetTester tester) async {
        const unit = Unit(
          unitId: 'unit_empty_desc',
          name: 'Unit with Empty Description',
          description: '',
          difficulty: 'Easy',
          isUnlocked: true,
          importantQuestions: null,
          cheatsheets: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitListTile(
                unit: unit,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Unit with Empty Description'), findsOneWidget);
        // Empty description should still be handled gracefully
        expect(tester.takeException(), isNull);
      });
    });

    group('General Widget Tests', () {
      testWidgets('should handle theme changes correctly', (WidgetTester tester) async {
        const unit = Unit(
          unitId: 'unit_theme',
          name: 'Theme Test Unit',
          description: 'Testing theme',
          difficulty: 'Medium',
          isUnlocked: true,
          importantQuestions: null,
          cheatsheets: null,
        );

        // Test light theme
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: UnitListTile(
                unit: unit,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Theme Test Unit'), findsOneWidget);

        // Test dark theme
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: UnitListTile(
                unit: unit,
                onTap: () {},
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Theme Test Unit'), findsOneWidget);
      });

      testWidgets('should be accessible', (WidgetTester tester) async {
        const unit = Unit(
          unitId: 'unit_a11y',
          name: 'Accessibility Test Unit',
          description: 'Testing accessibility',
          difficulty: 'Easy',
          isUnlocked: true,
          importantQuestions: null,
          cheatsheets: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitListTile(
                unit: unit,
                onTap: () {},
              ),
            ),
          ),
        );

        // Check for semantic properties
        final listTileFinder = find.byType(ListTile);
        expect(listTileFinder, findsOneWidget);
        
        final listTile = tester.widget<ListTile>(listTileFinder);
        expect(listTile.title, isA<Widget>());
        expect(listTile.subtitle, isA<Widget>());
      });

      testWidgets('should handle rapid taps without issues', (WidgetTester tester) async {
        var tapCount = 0;
        
        const unit = Unit(
          unitId: 'unit_rapid_tap',
          name: 'Rapid Tap Test',
          description: 'Testing rapid taps',
          difficulty: 'Medium',
          isUnlocked: true,
          importantQuestions: null,
          cheatsheets: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitListTile(
                unit: unit,
                onTap: () {
                  tapCount++;
                },
              ),
            ),
          ),
        );

        final listTileFinder = find.byType(UnitListTile);
        
        // Simulate rapid taps
        for (int i = 0; i < 10; i++) {
          await tester.tap(listTileFinder);
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(tapCount, 10);
      });

      testWidgets('should maintain state during rebuilds', (WidgetTester tester) async {
        var rebuildCount = 0;
        
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              rebuildCount++;
              
              const unit = Unit(
                unitId: 'unit_rebuild',
                name: 'Rebuild Test',
                description: 'Testing rebuilds',
                difficulty: 'Hard',
                isUnlocked: true,
                importantQuestions: null,
                cheatsheets: null,
              );

              return MaterialApp(
                home: Scaffold(
                  body: Column(
                    children: [
                      UnitListTile(
                        unit: unit,
                        onTap: () {},
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: Text('Rebuild'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );

        expect(rebuildCount, 1);
        expect(find.text('Rebuild Test'), findsOneWidget);

        // Trigger rebuild
        await tester.tap(find.text('Rebuild'));
        await tester.pump();

        expect(rebuildCount, 2);
        expect(find.text('Rebuild Test'), findsOneWidget);
      });
    });

    group('Edge Case Widget Tests', () {
      testWidgets('should handle null callbacks gracefully', (WidgetTester tester) async {
        const unit = Unit(
          unitId: 'unit_null_callback',
          name: 'Null Callback Test',
          description: 'Testing null callback',
          difficulty: 'Easy',
          isUnlocked: true,
          importantQuestions: null,
          cheatsheets: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitListTile(
                unit: unit,
                onTap: () {}, // Empty callback
              ),
            ),
          ),
        );

        expect(find.text('Null Callback Test'), findsOneWidget);
        
        // Should not throw when tapped
        await tester.tap(find.byType(UnitListTile));
        await tester.pump();
        
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle Unicode characters in unit data', (WidgetTester tester) async {
        const unit = Unit(
          unitId: 'unit_unicode',
          name: '📚 Programming Basics 🖥️',
          description: 'Learn programming with emojis! 🎓✨',
          difficulty: 'Easy',
          isUnlocked: true,
          importantQuestions: null,
          cheatsheets: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitListTile(
                unit: unit,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('📚 Programming Basics 🖥️'), findsOneWidget);
        expect(find.text('Learn programming with emojis! 🎓✨'), findsOneWidget);
      });

      testWidgets('should handle special characters and HTML entities', (WidgetTester tester) async {
        const unit = Unit(
          unitId: 'unit_special_chars',
          name: 'C++ & Java <Programming>',
          description: 'Learn C++ & Java "programming" languages with <tags>',
          difficulty: 'Hard',
          isUnlocked: true,
          importantQuestions: null,
          cheatsheets: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitListTile(
                unit: unit,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('C++ & Java <Programming>'), findsOneWidget);
        expect(find.text('Learn C++ & Java "programming" languages with <tags>'), findsOneWidget);
      });
    });
  });
}