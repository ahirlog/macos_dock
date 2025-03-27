import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Create a provider for the dock items
final dockItemsProvider = StateNotifierProvider<DockItemsNotifier, List<IconData>>((ref) {
  return DockItemsNotifier([
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.photo,
  ]);
});

class DockItemsNotifier extends StateNotifier<List<IconData>> {
  DockItemsNotifier(List<IconData> state) : super(state);

  void updateItems(List<IconData> newItems) {
    state = newItems;
  }
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MacOSDock(),
              SizedBox(height: 20),
              ResetButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class MacOSDock extends ConsumerWidget {
  const MacOSDock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(dockItemsProvider);
    final notifier = ref.read(dockItemsProvider.notifier);

    return MouseRegion(
      // onHover: (event) {
      // },
      // onExit: (event) {
      //   // Handle exit
      // },
      child: SizedBox(
        height: 75,
        width: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: BackdropFilter(
                  filter: ColorFilter.mode(
                    Colors.white.withOpacity(0.1),
                    BlendMode.softLight,
                  ),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),

            // Dock items
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(items.length, (index) {
                return DragTarget<IconData>(
                  onAccept: (data) {
                    final newItems = List<IconData>.from(items);
                    newItems.remove(data);
                    newItems.insert(index, data);
                    notifier.updateItems(newItems);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Draggable<IconData>(
                      data: items[index],
                      feedback: Material(
                        color: Colors.transparent,
                        child: DockItem(
                          icon: items[index],
                          scale: 1.2,
                          baseWidth: 48,
                          baseHeight: 48,
                        ),
                      ),
                      childWhenDragging: DockItem(
                        icon: items[index],
                        scale: 1.0,
                        baseWidth: 48,
                        baseHeight: 48,
                        opacity: 0.3,
                      ),
                      // onDragStarted: () {
                      // },
                      onDragEnd: (details) {
                        if (details.wasAccepted) return;
                        final newItems = List<IconData>.from(items);
                        newItems.remove(items[index]);
                        notifier.updateItems(newItems);
                      },
                      child: DockItem(
                        icon: items[index],
                        scale: 1.0,
                        baseWidth: 48,
                        baseHeight: 48,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class DockItem extends StatelessWidget {
  const DockItem({
    super.key,
    required this.icon,
    required this.scale,
    required this.baseWidth,
    required this.baseHeight,
    this.opacity = 1.0,
  });

  final IconData icon;
  final double scale;
  final double baseWidth;
  final double baseHeight;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main icon
          Transform.scale(
            scale: scale,
            child: Container(
              width: baseWidth,
              height: baseHeight,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.black87,
                size: 30 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResetButton extends ConsumerWidget {
  const ResetButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dockItemsProvider.notifier);

    return ElevatedButton(
      onPressed: () {
        notifier.updateItems([
          Icons.person,
          Icons.message,
          Icons.call,
          Icons.camera,
          Icons.photo,
        ]);
      },
      child: const Text('Reset Dock'),
    );
  }
}
