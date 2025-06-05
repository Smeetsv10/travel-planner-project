import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_scheduler/classes/app_settings.dart';
import 'package:travel_scheduler/classes/card_list_provider.dart';
import 'package:travel_scheduler/classes/card_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final cardListProvider = Provider.of<CardListProvider>(
      context,
      listen: false,
    );

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
                    Row(
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
                    const SizedBox(height: 8),
                    widget.body,
                  ],
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
