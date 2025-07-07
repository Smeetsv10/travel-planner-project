import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_scheduler/classes/app_settings.dart';
import 'package:travel_scheduler/classes/card_list_provider.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/classes/connection_provider.dart';
import 'package:travel_scheduler/widgets/CustomCards/connection.dart';
import 'package:travel_scheduler/widgets/CustomCards/connection_node.dart';

class CustomCard extends StatefulWidget {
  final CardProvider cardProvider;
  final Widget body;

  CustomCard({
    Key? key,
    required this.cardProvider,
    this.body = const SizedBox.shrink(),
  }) : super(key: key ?? ValueKey(cardProvider.id));

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  late Offset _position;
  bool _isDragging = false;
  Offset? _dragStart;
  Offset? _dragCurrent;
  bool _isConnecting = false;
  late final GlobalKey _stackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _position = widget.cardProvider.position;
    widget.cardProvider.addListener(() {
      if (mounted) {
        setState(() => _position = widget.cardProvider.position);
      }
    });
  }

  void _onDragStart(Offset globalPosition, {required bool fromNode}) {
    setState(() {
      _isConnecting = true;
      _dragStart = globalPosition;
      _dragCurrent = globalPosition;
    });
  }

  void _onDragUpdate(Offset globalPosition, {required bool fromNode}) {
    setState(() {
      _dragCurrent = globalPosition;
    });
  }

  void _onDragEnd(Offset globalPosition, {required bool fromNode}) {
    final cardListProvider = Provider.of<CardListProvider>(
      context,
      listen: false,
    );

    for (final targetCardProvider in cardListProvider.cardProviders) {
      if (targetCardProvider.id == widget.cardProvider.id) continue;

      // Determine which node to check on the target card
      final targetNodeKey = fromNode
          ? targetCardProvider.toNodeKey
          : targetCardProvider.fromNodeKey;
      final context = targetNodeKey?.currentContext;
      if (context == null) continue;
      final renderBox = context.findRenderObject();
      if (renderBox is! RenderBox) continue;
      final rect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
      if (rect.contains(globalPosition)) {
        // Build the connection based on the drag direction
        if (fromNode) {
          // Drag started from this card's fromNode, connect to target's toNode
          cardListProvider.addConnectionProvider(
            ConnectionProvider(
              fromProvider: widget.cardProvider,
              targetProvider: targetCardProvider,
              fromNodeKey: widget.cardProvider.fromNodeKey,
              toNodeKey: targetCardProvider.toNodeKey,
            ),
          );
        } else {
          // Drag started from this card's toNode, connect to target's fromNode
          cardListProvider.addConnectionProvider(
            ConnectionProvider(
              fromProvider: widget.cardProvider,
              targetProvider: targetCardProvider,
              fromNodeKey: widget.cardProvider.toNodeKey,
              toNodeKey: targetCardProvider.fromNodeKey,
            ),
          );
        }
        break;
      }
    }

    setState(() {
      _isConnecting = false;
      _dragStart = null;
      _dragCurrent = null;
    });
  }

  Widget _buildDeleteIcon(
    BuildContext context,
    CardListProvider cardListProvider,
  ) {
    return Positioned(
      top: -10,
      right: -5,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[900],
          border: Border.all(color: widget.cardProvider.color, width: 2),
        ),
        child: IconButton(
          icon: const Icon(Icons.delete, size: 18, color: Colors.white),
          tooltip: "Delete card",
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => _buildDeleteConfirmationDialog(context),
            );
            if (confirm == true) {
              cardListProvider.removeConnectionsForCard(widget.cardProvider);
              cardListProvider.removeCardProvider(widget.cardProvider);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDeleteConfirmationDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Card'),
      content: const Text(
        'Are you sure you want to delete this card? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Delete',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> editTitle() async {
    final controller = TextEditingController(text: widget.cardProvider.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Title'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Card Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newTitle != null && newTitle.trim().isNotEmpty) {
      setState(() => widget.cardProvider.setTitle(newTitle.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardListProvider = Provider.of<CardListProvider>(
      context,
      listen: false,
    );

    final bool isInteractive = widget.cardProvider.isInteractive;

    Widget cardContent = Card(
      elevation: 8,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(
        side: _isDragging && isInteractive
            ? const BorderSide(color: Colors.white, width: 2)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(16),
      ),
      color: widget.cardProvider.color,
      child: Container(
        width: AppSettings.cardWidth,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.cardProvider.icon,
                  SizedBox(width: 10),
                  GestureDetector(
                    onDoubleTap: isInteractive ? editTitle : null,
                    child: Text(
                      widget.cardProvider.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Divider(
            //   color: Colors.white,
            //   height: 0,
            //   thickness: 2,
            //   indent: 35,
            //   endIndent: 10 + 16,
            // ),
            const SizedBox(height: 8),
            widget.body,
          ],
        ),
      ),
    );

    if (!isInteractive) {
      return cardContent;
    }

    // Interactive card (with drag, delete, connection nodes)
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onTap: () => cardListProvider.selectCard(widget.cardProvider.id),
        onPanStart: (_) {
          cardListProvider.selectCard(widget.cardProvider.id);
          setState(() => _isDragging = true);
        },
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
            widget.cardProvider.setPosition(_position);
          });
        },
        onPanEnd: (_) => setState(() => _isDragging = false),
        child: Stack(
          key: _stackKey,
          clipBehavior: Clip.none,
          children: [
            cardContent,
            // From Node (right)
            Positioned(
              right: 0,
              top: 16 + 25,
              child: FromConnectionNode(
                cardProvider: widget.cardProvider,
                nodeKey: widget.cardProvider.fromNodeKey,
                onDragStart: (pos) => _onDragStart(pos, fromNode: true),
                onDragUpdate: (pos) => _onDragUpdate(pos, fromNode: true),
                onDragEnd: (pos) => _onDragEnd(pos, fromNode: true),
              ),
            ),
            // To Node (left)
            Positioned(
              left: 0,
              top: 40,
              child: ToConnectionNode(
                cardProvider: widget.cardProvider,
                nodeKey: widget.cardProvider.toNodeKey,
                onDragStart: (pos) => _onDragStart(pos, fromNode: false),
                onDragUpdate: (pos) => _onDragUpdate(pos, fromNode: false),
                onDragEnd: (pos) => _onDragEnd(pos, fromNode: false),
              ),
            ),
            if (_isConnecting && _dragStart != null && _dragCurrent != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Builder(
                    builder: (context) {
                      final box =
                          _stackKey.currentContext?.findRenderObject()
                              as RenderBox?;
                      final localStart =
                          box?.globalToLocal(_dragStart!) ?? Offset.zero;
                      final localEnd =
                          box?.globalToLocal(_dragCurrent!) ?? Offset.zero;
                      return ConnectionSpline(start: localStart, end: localEnd);
                    },
                  ),
                ),
              ),
            _buildDeleteIcon(context, cardListProvider),
          ],
        ),
      ),
    );
  }
}
