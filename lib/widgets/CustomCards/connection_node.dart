import 'package:flutter/material.dart';
import 'package:travel_scheduler/classes/card_provider.dart';

class ConnectionNode extends StatelessWidget {
  final void Function(Offset)? onDragStart;
  final void Function(Offset)? onDragUpdate;
  final void Function(Offset)? onDragEnd;
  final Color color;
  final double size;
  final CardProvider cardProvider;
  final GlobalKey? nodeKey;

  const ConnectionNode({
    super.key,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.color = Colors.blue,
    this.size = 16,
    required this.cardProvider,
    this.nodeKey,
  });

  Offset get position {
    final RenderBox? renderBox =
        nodeKey?.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset(size / 2, size / 2)) ?? Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: nodeKey,
      onPanStart: (details) {
        onDragStart?.call(details.globalPosition);
      },
      onPanUpdate: (details) {
        onDragUpdate?.call(details.globalPosition);
      },
      onPanEnd: (details) {
        onDragEnd?.call(details.globalPosition);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

class FromConnectionNode extends ConnectionNode {
  const FromConnectionNode({
    super.key,
    super.onDragStart,
    super.onDragUpdate,
    super.onDragEnd,
    super.nodeKey,
    required super.cardProvider,
    super.size = 16,
    super.color = Colors.white,
  });
}

class ToConnectionNode extends ConnectionNode {
  const ToConnectionNode({
    super.key,
    super.onDragStart,
    super.onDragUpdate,
    super.onDragEnd,
    super.nodeKey,
    required super.cardProvider,
    super.size = 16,
    super.color = Colors.white,
  });
}
