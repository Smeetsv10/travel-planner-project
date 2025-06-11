import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_scheduler/classes/app_settings.dart';
import 'package:travel_scheduler/classes/card_list_provider.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/classes/connection.dart';
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

  @override
  void initState() {
    super.initState();
    _position = widget.cardProvider.position;

    widget.cardProvider.addListener(() {
      if (mounted) {
        setState(() {
          _position = widget.cardProvider.position;
        });
      }
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
        _buildDialogAction(
          text: 'Cancel',
          isPrimary: false,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        _buildDialogAction(
          text: 'Delete',
          isPrimary: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }

  Widget _buildDialogAction({
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: isPrimary ? Theme.of(context).colorScheme.error : null,
          fontWeight: isPrimary ? FontWeight.bold : null,
        ),
      ),
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
      setState(() {
        widget.cardProvider.setTitle(newTitle.trim());
      });
    }
  }

  void _onFromDragStart(Offset globalPosition) {
    setState(() {
      _isConnecting = true;
      _dragStart = globalPosition;
      _dragCurrent = globalPosition;
    });
  }

  void _onFromDragUpdate(Offset globalPosition) {
    setState(() {
      _dragStart = widget.cardProvider.getFromKeyOffset();
      _dragCurrent = globalPosition;
    });
  }

  void _onToDragStart(Offset globalPosition) {
    setState(() {
      _isConnecting = true;
      _dragStart = globalPosition;
      _dragCurrent = globalPosition;
    });
  }

  void _onToDragUpdate(Offset globalPosition) {
    setState(() {
      _dragStart = widget.cardProvider.getToKeyOffset();
      _dragCurrent = globalPosition;
    });
  }

  void _onFromDragEnd(Offset globalPosition) {
    final cardListProvider = Provider.of<CardListProvider>(
      context,
      listen: false,
    );

    for (final targetCard in cardListProvider.cardProviders) {
      // Don't connect to self
      if (targetCard.id == widget.cardProvider.id) continue;

      // Check if the drag ended on the ToNode of another card
      final toNodeKey = targetCard.toNodeKey;
      final context = toNodeKey.currentContext;
      if (context == null) continue;
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox) continue;
      final toBox = renderObject as RenderBox;
      final toRect = toBox.localToGlobal(Offset.zero) & toBox.size;
      if (toRect.contains(globalPosition)) {
        // Add connection using offsets
        cardListProvider.addConnection(
          Connection(
            startOffset: widget.cardProvider.getFromKeyOffset(),
            endOffset: targetCard.getToKeyOffset(),
          ),
        );
        break;
      }
    }

    setState(() {
      _isConnecting = false;
      _dragStart = null;
      _dragCurrent = null;
    });
  }

  void _onToDragEnd(Offset globalPosition) {
    final cardListProvider = Provider.of<CardListProvider>(
      context,
      listen: false,
    );

    for (final targetCard in cardListProvider.cardProviders) {
      // Don't connect to self
      if (targetCard.id == widget.cardProvider.id) continue;

      // Check if the drag ended on the FromNode of another card
      final fromNodeKey = targetCard.fromNodeKey;
      final fromBox =
          fromNodeKey.currentContext?.findRenderObject() as RenderBox?;
      if (fromBox != null) {
        final fromRect = fromBox.localToGlobal(Offset.zero) & fromBox.size;
        if (fromRect.contains(globalPosition)) {
          // Add connection using offsets
          cardListProvider.addConnection(
            Connection(
              startOffset: targetCard.getFromKeyOffset(),
              endOffset: widget.cardProvider.getToKeyOffset(),
            ),
          );
          break;
        }
      }
    }

    setState(() {
      _isConnecting = false;
      _dragStart = null;
      _dragCurrent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardListProvider = Provider.of<CardListProvider>(
      context,
      listen: false,
    );
    final GlobalKey _stackKey = GlobalKey();

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onTap: () {
          cardListProvider.selectCard(widget.cardProvider.id);
        },
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
        onPanEnd: (_) {
          setState(() => _isDragging = false);
        },
        child: Stack(
          key: _stackKey,

          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: 8,
              shadowColor: Colors.black45,
              shape: RoundedRectangleBorder(
                side: _isDragging
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
                    GestureDetector(
                      onDoubleTap: editTitle,
                      child: Row(
                        children: [
                          SizedBox(width: 60, child: widget.cardProvider.icon),
                          Expanded(
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
                    const SizedBox(height: 8),
                    widget.body,
                  ],
                ),
              ),
            ),
            // From Node
            Positioned(
              right: 0,
              top: 40,
              child: FromConnectionNode(
                cardProvider: widget.cardProvider,
                nodeKey: widget.cardProvider.fromNodeKey,
                onDragStart: _onFromDragStart,
                onDragUpdate: _onFromDragUpdate,
                onDragEnd: _onFromDragEnd,
              ),
            ),
            // To Node (left side)
            Positioned(
              left: 0,
              top: 40,
              child: ToConnectionNode(
                cardProvider: widget.cardProvider,
                nodeKey: widget.cardProvider.toNodeKey,
                onDragStart: _onToDragStart,
                onDragUpdate: _onToDragUpdate,
                onDragEnd: _onToDragEnd,
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
