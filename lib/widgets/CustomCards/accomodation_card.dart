import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_field.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_price_field.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_url_field.dart';
import 'package:travel_scheduler/widgets/CustomCards/customcard.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:pasteboard/pasteboard.dart';

class AccommodationCard extends CustomCard {
  AccommodationCard({super.key, required super.cardProvider})
    : super(body: _AccommodationCardBody(cardProvider: cardProvider));
}

class _AccommodationCardBody extends StatefulWidget {
  final CardProvider cardProvider;
  const _AccommodationCardBody({required this.cardProvider});

  @override
  State<_AccommodationCardBody> createState() => _AccommodationCardBodyState();
}

class _AccommodationCardBodyState extends State<_AccommodationCardBody> {
  late TextEditingController priceController;
  late TextEditingController urlController;
  late ScrollController urlScrollController;

  late FocusNode priceFocusNode;
  late FocusNode urlFocusNode;

  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    priceController = TextEditingController(
      text: widget.cardProvider.price.toString(),
    );
    urlController = TextEditingController(text: widget.cardProvider.url);
    urlScrollController = ScrollController();

    priceFocusNode = FocusNode();
    urlFocusNode = FocusNode();

    priceFocusNode.addListener(() {
      if (!priceFocusNode.hasFocus) {
        final text = priceController.text.trim();
        final value = double.tryParse(text);
        if (value != null) {
          widget.cardProvider.setPrice(value);
        }
      }
    });
  }

  @override
  void dispose() {
    priceController.dispose();
    urlController.dispose();
    urlScrollController.dispose();
    priceFocusNode.dispose();
    urlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.cardProvider,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageField(
              imageBytes: _imageBytes,
              onImageChanged: (bytes) {
                setState(() {
                  _imageBytes = bytes;
                });
              },
            ),
            CustomCardField(
              label: "Check-in",
              iconWidget: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event, color: Colors.white),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
              dateTime: widget.cardProvider.arrivalDatetime,
              onDatePicked: widget.cardProvider.setArrivalDate,
              flagDateField: true,
              flagTextField: false,
            ),
            CustomCardField(
              label: "Check-out",
              iconWidget: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event, color: Colors.white),
                  Icon(Icons.arrow_back, color: Colors.white),
                ],
              ),
              dateTime: widget.cardProvider.departureDatetime,
              onDatePicked: widget.cardProvider.setDepartureDate,
              flagDateField: true,
              flagTextField: false,
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: CustomCardPriceField(
                    controller: priceController,
                    focusNode: priceFocusNode,
                  ),
                ),
                Expanded(
                  child: CustomCardUrlField(
                    controller: urlController,
                    focusNode: urlFocusNode,
                    onSubmitted: widget.cardProvider.setUrl,
                    scrollController: urlScrollController,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class ImageField extends StatefulWidget {
  final Uint8List? imageBytes;
  final ValueChanged<Uint8List?> onImageChanged;

  const ImageField({
    super.key,
    required this.imageBytes,
    required this.onImageChanged,
  });

  @override
  State<ImageField> createState() => _ImageFieldState();
}

class _ImageFieldState extends State<ImageField> {
  bool _hovering = false;
  bool _isCtrlPressed = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select an image',
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.single.bytes;
    if (bytes != null) {
      widget.onImageChanged(bytes);
    }
  }

  Future<void> _pasteImageFromClipboard() async {
    final imageBytes = await Pasteboard.image;
    if (imageBytes != null) {
      widget.onImageChanged(imageBytes);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image found in clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) async {
        if (detail.files.isNotEmpty) {
          final file = detail.files.first;
          final bytes = await file.readAsBytes();
          widget.onImageChanged(bytes);
        }
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _hovering = true);
          _focusNode.requestFocus();
        },
        onExit: (_) {
          setState(() {
            _hovering = false;
            _isCtrlPressed = false;
          });
          _focusNode.unfocus(); // Unfocus when mouse exits
        },
        child: GestureDetector(
          onDoubleTap: _pickImageFromFile,
          child: Focus(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (node, event) {
              final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;

              final isCtrlPressed =
                  keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
                  keysPressed.contains(LogicalKeyboardKey.controlRight);
              final isVPressed = event.logicalKey == LogicalKeyboardKey.keyV;
              if (isCtrlPressed) {
                setState(() {
                  _isCtrlPressed = true;
                });
              }
              if (_hovering &&
                  isVPressed &&
                  _isCtrlPressed &&
                  event is KeyDownEvent) {
                _pasteImageFromClipboard();
                return KeyEventResult.handled;
              }

              return KeyEventResult.ignored;
            },
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.imageBytes != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            widget.imageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 120,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () => widget.onImageChanged(null),
                            child: Container(
                              width: 25,
                              height: 25,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        "Double click, drag, or paste (Ctrl+V or right-click) an image here",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
