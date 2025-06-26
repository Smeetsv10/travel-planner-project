import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_scheduler/classes/card_list_provider.dart';
import 'package:travel_scheduler/classes/connection_provider.dart';

class Connection extends StatefulWidget {
  final ConnectionProvider connectionProvider;
  final GlobalKey stackKey;

  Connection({
    Key? key,
    required this.connectionProvider,
    required this.stackKey,
  }) : super(key: key ?? ValueKey(connectionProvider.id));

  @override
  State<Connection> createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.connectionProvider.fromProvider,
        widget.connectionProvider.targetProvider,
      ]),
      builder: (context, _) {
        final fromNodeContext =
            widget.connectionProvider.fromProvider.fromNodeKey.currentContext;
        final toNodeContext =
            widget.connectionProvider.targetProvider.toNodeKey.currentContext;
        final stackContext = widget.stackKey.currentContext;

        if (fromNodeContext == null ||
            toNodeContext == null ||
            stackContext == null) {
          return const SizedBox.shrink();
        }

        final fromRenderBox = fromNodeContext.findRenderObject() as RenderBox?;
        final toRenderBox = toNodeContext.findRenderObject() as RenderBox?;
        final stackRenderBox = stackContext.findRenderObject() as RenderBox?;

        if (fromRenderBox == null ||
            toRenderBox == null ||
            stackRenderBox == null) {
          return const SizedBox.shrink();
        }

        // Get the center of the fromNode and toNode in global coordinates
        final fromSize = fromRenderBox.size;
        final toSize = toRenderBox.size;
        final fromGlobal = fromRenderBox.localToGlobal(
          Offset(fromSize.width / 2, fromSize.height / 2),
        );
        final toGlobal = toRenderBox.localToGlobal(
          Offset(toSize.width / 2, toSize.height / 2),
        );

        // Convert global coordinates to the stack's local coordinates
        final fromOffset = stackRenderBox.globalToLocal(fromGlobal);
        final toOffset = stackRenderBox.globalToLocal(toGlobal);

        // Calculate bounding box
        final minX = fromOffset.dx < toOffset.dx ? fromOffset.dx : toOffset.dx;
        final minY = fromOffset.dy < toOffset.dy ? fromOffset.dy : toOffset.dy;
        final maxX = fromOffset.dx > toOffset.dx ? fromOffset.dx : toOffset.dx;
        final maxY = fromOffset.dy > toOffset.dy ? fromOffset.dy : toOffset.dy;

        final boundingRect = Rect.fromLTRB(minX, minY, maxX, maxY);

        // Offset the spline's start/end to be relative to the bounding box
        final localStart = fromOffset - boundingRect.topLeft;
        final localEnd = toOffset - boundingRect.topLeft;

        return Positioned(
          left: boundingRect.left,
          top: boundingRect.top,
          width: boundingRect.width == 0 ? 1 : boundingRect.width,
          height: boundingRect.height == 0 ? 1 : boundingRect.height,
          child: ConnectionSpline(
            start: localStart,
            end: localEnd,

            onTap: () {},
            onDoubleTap: () {
              Provider.of<CardListProvider>(
                context,
                listen: false,
              ).removeConnectionProvider(widget.connectionProvider);
            },
          ),
        );
      },
    );
  }
}

class ConnectionSpline extends StatefulWidget {
  final Offset start;
  final Offset end;
  final Rect? debugRect;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const ConnectionSpline({
    super.key,
    required this.start,
    required this.end,
    this.debugRect,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  State<ConnectionSpline> createState() => _ConnectionSplineState();
}

class _ConnectionSplineState extends State<ConnectionSpline> {
  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPos = box.globalToLocal(details.globalPosition);
        final painter = _SplinePainter(
          widget.start,
          widget.end,
          debugRect: widget.debugRect,
        );
        if (painter.hitTest(localPos)) {
          final now = DateTime.now();
          if (_lastTapTime != null &&
              now.difference(_lastTapTime!) <
                  const Duration(milliseconds: 300)) {
            if (widget.onDoubleTap != null) widget.onDoubleTap!();
            _lastTapTime = null;
          } else {
            if (widget.onTap != null) widget.onTap!();
            _lastTapTime = now;
          }
        }
      },
      child: CustomPaint(
        painter: _SplinePainter(
          widget.start,
          widget.end,
          debugRect: widget.debugRect,
        ),
        size: Size(widget.debugRect?.width ?? 1, widget.debugRect?.height ?? 1),
      ),
    );
  }
}

class _SplinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Rect? debugRect;

  _SplinePainter(this.start, this.end, {this.debugRect});

  Path _buildSplinePath() {
    final controlPoint1 = Offset(start.dx + 80, start.dy);
    final controlPoint2 = Offset(end.dx - 80, end.dy);

    return Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        end.dx,
        end.dy,
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildSplinePath();

    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);

    // Draw debug rect if provided
    if (debugRect != null) {
      final debugPaint = Paint()
        ..color = Colors.red.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawRect(debugRect!, debugPaint);

      final borderPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawRect(debugRect!, borderPaint);
    }
  }

  // Custom hit test: returns true if the pointer is close to the path
  bool hitTest(Offset position) {
    final path = _buildSplinePath();
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      for (double t = 0.0; t < metric.length; t += 1.0) {
        final tangent = metric.getTangentForOffset(t);
        if (tangent != null && (tangent.position - position).distance < 10) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
