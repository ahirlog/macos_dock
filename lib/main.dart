import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: MacOSDock(
            items: [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}

class MacOSDock extends StatefulWidget {
  const MacOSDock({
    super.key,
    required this.items,
  });

  final List<IconData> items;

  @override
  State<MacOSDock> createState() => _MacOSDockState();
}

class _MacOSDockState extends State<MacOSDock> with TickerProviderStateMixin {
  late final List<IconData> _items = widget.items.toList();
  double? _mouseX;
  IconData? _draggedItem;
  int? _draggedIndex;
  static const double _baseWidth = 48;
  static const double _baseHeight = 48;
  static const double _maxZoom = 1.3;

  late final AnimationController _bounceController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onDragStarted(IconData item, int index) {
    setState(() {
      _draggedItem = item;
      _draggedIndex = index;
    });
  }

  void _onDragUpdate(DragUpdateDetails details, int index) {
    if (_draggedIndex == null) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final double localPosition = box.globalToLocal(details.globalPosition).dx;

    final int newIndex = (localPosition / (_baseWidth + 10)).floor();

    if (newIndex != _draggedIndex && newIndex >= 0 && newIndex < _items.length) {
      setState(() {
        final item = _items.removeAt(_draggedIndex!);
        _items.insert(newIndex, item);
        _draggedIndex = newIndex;
      });
    }
  }

  void _onDragEnd(DraggableDetails details) {
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });

    setState(() {
      _draggedItem = null;
      _draggedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        if (_draggedItem == null) {
          setState(() {
            _mouseX = event.localPosition.dx;
          });
        }
      },
      onExit: (event) {
        setState(() {
          _mouseX = null;
        });
      },
      child: SizedBox(
        height: 75,
        width: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glass background
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
              children: List.generate(_items.length, (index) {
                final double distance = _mouseX != null
                    ? (_mouseX! - (index * (_baseWidth + 10) + _baseWidth / 2)).abs()
                    : double.infinity;

                double scale = 1.0;
                if (distance < _baseWidth * 2 && _draggedItem == null) {
                  scale = 1.0 + (_maxZoom - 1.0) * (1 - distance / (_baseWidth * 2));
                }

                return Draggable<IconData>(
                  data: _items[index],
                  feedback: Material(
                    color: Colors.transparent,
                    child: DockItem(
                      icon: _items[index],
                      scale: _maxZoom,
                      baseWidth: _baseWidth,
                      baseHeight: _baseHeight,
                    ),
                  ),
                  childWhenDragging: DockItem(
                    icon: _items[index],
                    scale: 1.0,
                    baseWidth: _baseWidth,
                    baseHeight: _baseHeight,
                    opacity: 0.3,
                  ),
                  onDragStarted: () => _onDragStarted(_items[index], index),
                  onDragUpdate: (details) => _onDragUpdate(details, index),
                  onDragEnd: _onDragEnd,
                  child: DockItem(
                    icon: _items[index],
                    scale: scale,
                    baseWidth: _baseWidth,
                    baseHeight: _baseHeight,
                  ),
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
