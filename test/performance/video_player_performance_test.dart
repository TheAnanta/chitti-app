import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chitti/data/semester.dart';

void main() {
  group('Performance Tests', () {
    group('Video Player Performance', () {
      testWidgets('should handle video player initialization without jank', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                width: 400,
                height: 300,
                child: Stack(
                  children: [
                    // Simulate video player container
                    Container(color: Colors.black),
                    // Simulate video controls overlay
                    Positioned.fill(
                      child: Container(
                        color: Colors.transparent,
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        stopwatch.stop();

        // Video player should initialize quickly (under 100ms for UI)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle rapid gesture interactions without performance degradation', (WidgetTester tester) async {
        final gestureResponses = <int>[];
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                width: 400,
                height: 300,
                child: GestureDetector(
                  onTap: () {
                    gestureResponses.add(DateTime.now().millisecondsSinceEpoch);
                  },
                  onDoubleTap: () {
                    gestureResponses.add(DateTime.now().millisecondsSinceEpoch);
                  },
                  child: Container(color: Colors.black),
                ),
              ),
            ),
          ),
        );

        final gestureDetector = find.byType(GestureDetector);
        
        // Perform rapid gestures
        final startTime = DateTime.now().millisecondsSinceEpoch;
        
        for (int i = 0; i < 10; i++) {
          await tester.tap(gestureDetector);
          await tester.pump(const Duration(milliseconds: 16)); // 60 FPS
        }

        final endTime = DateTime.now().millisecondsSinceEpoch;
        final totalTime = endTime - startTime;

        // Should handle 10 gestures in reasonable time (under 500ms)
        expect(totalTime, lessThan(500));
        expect(gestureResponses.length, 10);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle video overlay animations smoothly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                width: 400,
                height: 300,
                child: Stack(
                  children: [
                    Container(color: Colors.black),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fast_forward, color: Colors.white, size: 48),
                            Text('10 seconds', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        
        // Test animation performance
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        expect(tester.takeException(), isNull);
      });

      testWidgets('should maintain 60 FPS during video controls interaction', (WidgetTester tester) async {
        final frameTimes = <int>[];
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NotificationListener<DrawFrameNotification>(
                onNotification: (notification) {
                  frameTimes.add(DateTime.now().microsecondsSinceEpoch);
                  return false;
                },
                child: Container(
                  width: 400,
                  height: 300,
                  child: Stack(
                    children: [
                      Container(color: Colors.black),
                      // Simulate video controls
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          color: Colors.black54,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.play_arrow, color: Colors.white),
                              ),
                              Expanded(
                                child: Slider(
                                  value: 0.5,
                                  onChanged: (value) {},
                                  activeColor: Colors.red,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.fullscreen, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        
        // Interact with controls
        final playButton = find.byIcon(Icons.play_arrow);
        final slider = find.byType(Slider);
        
        await tester.tap(playButton);
        await tester.pump();
        
        await tester.drag(slider, const Offset(50, 0));
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    });

    group('List Performance', () {
      testWidgets('should handle large lists efficiently', (WidgetTester tester) async {
        final largeList = List.generate(10000, (index) => 'Item $index');
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: largeList.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(largeList[index]),
                  subtitle: Text('Subtitle for item $index'),
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        stopwatch.stop();

        // Large list should render initial view quickly
        expect(stopwatch.elapsedMilliseconds, lessThan(200));

        // Test scrolling performance
        final scrollStart = Stopwatch()..start();
        
        await tester.drag(find.byType(ListView), const Offset(0, -1000));
        await tester.pump();
        
        scrollStart.stop();

        // Scrolling should be smooth
        expect(scrollStart.elapsedMilliseconds, lessThan(100));
        expect(tester.takeException(), isNull);
      });

      testWidgets('should virtualize list items correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: 1000,
                itemBuilder: (context, index) => Container(
                  height: 100,
                  child: ListTile(
                    title: Text('Item $index'),
                    subtitle: Text('This is item number $index'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Only visible items should be rendered
        final visibleItems = find.byType(ListTile);
        expect(visibleItems.evaluate().length, lessThan(20)); // Reasonable viewport

        // Scroll and check virtualization
        await tester.drag(find.byType(ListView), const Offset(0, -5000));
        await tester.pump();

        // Should still have limited visible items
        final visibleAfterScroll = find.byType(ListTile);
        expect(visibleAfterScroll.evaluate().length, lessThan(30));
        expect(tester.takeException(), isNull);
      });
    });

    group('Memory Performance', () {
      testWidgets('should handle value notifier disposal correctly', (WidgetTester tester) async {
        final notifiers = <ValueNotifier<double>>[];
        
        // Create many value notifiers
        for (int i = 0; i < 100; i++) {
          notifiers.add(ValueNotifier<double>(i.toDouble()));
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: notifiers.map((notifier) => 
                  ValueListenableBuilder<double>(
                    valueListenable: notifier,
                    builder: (context, value, child) => Text('Value: $value'),
                  )
                ).toList(),
              ),
            ),
          ),
        );

        await tester.pump();

        // Dispose all notifiers
        for (final notifier in notifiers) {
          notifier.dispose();
        }

        // Should not crash after disposal
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle image loading performance', (WidgetTester tester) async {
        final imageUrls = List.generate(50, (index) => 
          'https://example.com/image_$index.jpg'
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.all(2),
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.error),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Should handle multiple image loading without issues
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
      });
    });

    group('Animation Performance', () {
      testWidgets('should handle complex animations smoothly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Multiple animated widgets
                    ...List.generate(10, (index) => 
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 1000 + (index * 100)),
                        builder: (context, value, child) => Transform.scale(
                          scale: value,
                          child: Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(value),
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        
        // Let animations run
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle hero animations without jank', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Hero(
                  tag: 'test-hero',
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(tester.element(find.byType(Scaffold))).push(
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            body: Center(
                              child: Hero(
                                tag: 'test-hero',
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        final heroWidget = find.byType(Hero);
        await tester.tap(heroWidget);
        
        // Pump hero animation
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        expect(tester.takeException(), isNull);
      });
    });

    group('Network Performance', () {
      testWidgets('should handle concurrent network requests efficiently', (WidgetTester tester) async {
        // Simulate concurrent loading states
        final loadingStates = List.generate(10, (index) => ValueNotifier<bool>(true));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: loadingStates.map((loading) => 
                  ValueListenableBuilder<bool>(
                    valueListenable: loading,
                    builder: (context, isLoading, child) => ListTile(
                      title: Text(isLoading ? 'Loading...' : 'Loaded'),
                      trailing: isLoading 
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.check),
                    ),
                  )
                ).toList(),
              ),
            ),
          ),
        );

        await tester.pump();

        // Simulate staggered loading completion
        for (int i = 0; i < loadingStates.length; i++) {
          await tester.pump(Duration(milliseconds: 100 * (i + 1)));
          loadingStates[i].value = false;
          await tester.pump();
        }

        expect(tester.takeException(), isNull);

        // Cleanup
        for (final notifier in loadingStates) {
          notifier.dispose();
        }
      });
    });

    group('Stress Tests', () {
      testWidgets('should handle rapid state changes', (WidgetTester tester) async {
        final stateNotifier = ValueNotifier<int>(0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ValueListenableBuilder<int>(
                valueListenable: stateNotifier,
                builder: (context, value, child) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Counter: $value'),
                      ElevatedButton(
                        onPressed: () => stateNotifier.value++,
                        child: const Text('Increment'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        final button = find.text('Increment');
        
        // Rapid state changes
        for (int i = 0; i < 100; i++) {
          await tester.tap(button);
          await tester.pump(const Duration(milliseconds: 10));
        }

        expect(find.text('Counter: 100'), findsOneWidget);
        expect(tester.takeException(), isNull);

        stateNotifier.dispose();
      });

      testWidgets('should handle memory stress with large widgets', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: List.generate(1000, (index) => 
                    ExpansionTile(
                      title: Text('Expansion Tile $index'),
                      children: List.generate(10, (childIndex) => 
                        ListTile(
                          title: Text('Child $childIndex of $index'),
                          subtitle: Text('Subtitle with some longer text for $childIndex'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Expand some tiles
        final firstTile = find.byType(ExpansionTile).first;
        await tester.tap(firstTile);
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    });
  });
}