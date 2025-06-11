import 'package:flutter/material.dart';

class Connection {
  final Offset startOffset;
  final Offset endOffset;

  Connection({required this.startOffset, required this.endOffset});

  Widget buildConnection() {
    return ConnectionSpline(start: startOffset, end: endOffset);
  }
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
