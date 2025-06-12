import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_scheduler/classes/card_list_provider.dart';
import 'package:travel_scheduler/classes/card_provider.dart';

class Connection {
  final GlobalKey startNodeKey;
  final GlobalKey endNodeKey;
  final CardProvider startProvider;
  final CardProvider endProvider;

  Connection({
    required this.startNodeKey,
    required this.endNodeKey,
    required this.startProvider,
    required this.endProvider,
  });

  Widget buildConnection(GlobalKey stackKey) {
    return AnimatedBuilder(
      animation: Listenable.merge([startProvider, endProvider]),
      builder: (context, _) {
        final box = stackKey.currentContext?.findRenderObject() as RenderBox?;
        if (box == null) return const SizedBox.shrink();

        final fromContext = startNodeKey.currentContext;
        final toContext = endNodeKey.currentContext;
        if (fromContext == null || toContext == null)
          return const SizedBox.shrink();

        final fromRenderBox = fromContext.findRenderObject() as RenderBox?;
        final toRenderBox = toContext.findRenderObject() as RenderBox?;
        if (fromRenderBox == null || toRenderBox == null)
          return const SizedBox.shrink();

        final fromSize = fromRenderBox.size;
        final toSize = toRenderBox.size;

        final globalStart = fromRenderBox.localToGlobal(
          Offset(fromSize.width / 2, fromSize.height / 2),
        );
        final globalEnd = toRenderBox.localToGlobal(
          Offset(toSize.width / 2, toSize.height / 2),
        );

        final localStart = box.globalToLocal(globalStart);
        final localEnd = box.globalToLocal(globalEnd);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onDoubleTap: () {
            Provider.of<CardListProvider>(
              context,
              listen: false,
            ).removeConnection(this);
          },
          child: ConnectionSpline(start: localStart, end: localEnd),
        );
      },
    );
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
