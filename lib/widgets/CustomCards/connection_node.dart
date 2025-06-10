import 'package:flutter/material.dart';

class ConnectionNode extends StatelessWidget {
  final VoidCallback? onDragStart;
  final void Function(Offset)? onDragUpdate;
  final void Function()? onDragEnd;
  final Color color;
  final double size;
  final GlobalKey? nodeKey;

  const ConnectionNode({
    super.key,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.color = Colors.blue,
    this.size = 16,
    this.nodeKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: nodeKey,
      onPanStart: (_) => onDragStart?.call(),
      onPanUpdate: (details) => onDragUpdate?.call(details.globalPosition),
      onPanEnd: (_) => onDragEnd?.call(),
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
    super.size = 16,
    super.color = Colors.green,
  });
}

class ToConnectionNode extends ConnectionNode {
  const ToConnectionNode({
    super.key,
    super.onDragStart,
    super.onDragUpdate,
    super.onDragEnd,
    super.nodeKey,
    super.size = 16,
    super.color = Colors.red,
  });
}

class ConnectionSpline extends StatelessWidget {
  final Offset start;
  final Offset end;

  const ConnectionSpline({super.key, required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SplinePainter(start, end),
      size: Size.infinite,
    );
  }
}

class _SplinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  _SplinePainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final controlPoint1 = Offset(start.dx + 80, start.dy);
    final controlPoint2 = Offset(end.dx - 80, end.dy);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        end.dx,
        end.dy,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
