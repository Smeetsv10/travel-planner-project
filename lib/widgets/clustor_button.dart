import 'package:flutter/material.dart';

class ClusterButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final List<Widget> children;
  final double buttonSize;
  final Color backgroundColor;
  final Duration animationDuration;
  final AxisDirection axisDirection; // New parameter

  const ClusterButton({
    super.key,
    required this.child,
    this.onPressed,
    this.children = const [],
    this.buttonSize = 56.0,
    this.backgroundColor = Colors.blue,
    this.animationDuration = const Duration(milliseconds: 120),
    this.axisDirection = AxisDirection.right, // Default to right
  });

  @override
  State<ClusterButton> createState() => _ClusterButtonState();
}

class _ClusterButtonState extends State<ClusterButton>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _createOverlay() {
    if (_overlayEntry != null) return;

    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);

    // Calculate positioning based on axis direction
    double left, top;
    Widget childrenWidget;

    final totalHeight =
        (widget.children.length * widget.buttonSize) +
        ((widget.children.length - 1) * 16.0);
    final totalWidth =
        (widget.children.length * widget.buttonSize) +
        ((widget.children.length - 1) * 16.0);
    switch (widget.axisDirection) {
      case AxisDirection.right:
        left = offset.dx + 1.5 * widget.buttonSize;
        top = offset.dy + (widget.buttonSize / 2) - (totalHeight / 2);
        childrenWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildChildrenWithSpacing(isVertical: true),
        );
        break;

      case AxisDirection.left:
        left = offset.dx - widget.buttonSize - 16;
        top = offset.dy + (widget.buttonSize / 2) - (totalHeight / 2);
        childrenWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _buildChildrenWithSpacing(isVertical: true),
        );
        break;

      case AxisDirection.down:
        top = offset.dy + widget.buttonSize + 16;
        left = offset.dx + (widget.buttonSize / 2) - (totalWidth / 2);
        childrenWidget = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildChildrenWithSpacing(isVertical: false),
        );
        break;

      case AxisDirection.up:
        top = offset.dy - widget.buttonSize - 16;
        left = offset.dx + (widget.buttonSize / 2) - (totalWidth / 2);
        childrenWidget = Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _buildChildrenWithSpacing(isVertical: false),
        );
        break;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        child: Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: childrenWidget,
                ),
              );
            },
          ),
        ),
      ),
    );

    if (mounted) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  List<Widget> _buildChildrenWithSpacing({required bool isVertical}) {
    return widget.children.asMap().entries.map((entry) {
      final index = entry.key;
      final button = entry.value;
      return Padding(
        padding: EdgeInsets.only(
          top: isVertical && index > 0 ? 16.0 : 0.0,
          left: !isVertical && index > 0 ? 16.0 : 0.0,
        ),
        child: button,
      );
    }).toList();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _createOverlay();
        _animationController.forward();
      } else {
        _animationController.reverse().then((_) {
          _removeOverlay();
        });
      }
    });
  }

  void _handlePressed() {
    if (widget.children.isNotEmpty) {
      _toggleExpansion();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _buttonKey,
      onTap: _handlePressed,
      child: AnimatedContainer(
        duration: widget.animationDuration,
        curve: Curves.easeOut,
        width: widget.buttonSize,
        height: widget.buttonSize,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        transform: Matrix4.identity()
          ..rotateZ(_isExpanded ? 0.785398 : 0), // π/4 radians = 45 degrees
        transformAlignment: Alignment.center,
        child: Center(child: widget.child),
      ),
    );
  }
}
