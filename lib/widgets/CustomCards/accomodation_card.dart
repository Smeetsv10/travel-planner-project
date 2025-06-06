import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_price_field.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_url_field.dart';
import 'package:travel_scheduler/widgets/CustomCards/customcard_widget.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:travel_scheduler/widgets/CustomCards/custom_card_field.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Uint8List? _imageBytes; // Drag & drop image bytes
  String? _previewImageUrl; // Extracted from URL

  @override
  void initState() {
    super.initState();
    priceController = TextEditingController(
      text: widget.cardProvider.price.toString(),
    );
    urlController = TextEditingController(text: widget.cardProvider.url ?? '');
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

    urlFocusNode.addListener(() async {
      if (!urlFocusNode.hasFocus) {
        final url = urlController.text.trim();
        widget.cardProvider.setUrl(url);

        // Scroll to start after editing, like in flight_card
        WidgetsBinding.instance.addPostFrameCallback((_) {
          urlController.text = url;
          urlController.selection = const TextSelection.collapsed(offset: 0);
          urlScrollController.jumpTo(0);
        });

        if (url.isNotEmpty) {
          final imgUrl = await extractPreviewImageUrl(url);
          if (mounted) {
            setState(() {
              _previewImageUrl = imgUrl;
            });
          }
        } else {
          setState(() {
            _previewImageUrl = null;
          });
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

  // Extract preview image from URL
  Future<String?> extractPreviewImageUrl(String pageUrl) async {
    try {
      final response = await http.get(Uri.parse(pageUrl));
      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        // Try Open Graph
        final ogImage = document
            .querySelector('meta[property="og:image"]')
            ?.attributes['content'];
        if (ogImage != null && ogImage.isNotEmpty) return ogImage;

        // Try Twitter Card
        final twitterImage = document
            .querySelector('meta[name="twitter:image"]')
            ?.attributes['content'];
        if (twitterImage != null && twitterImage.isNotEmpty)
          return twitterImage;

        // Try favicon
        final icon = document
            .querySelector('link[rel="icon"]')
            ?.attributes['href'];
        if (icon != null && icon.isNotEmpty) {
          final uri = Uri.parse(pageUrl);
          return Uri.parse(icon).isAbsolute
              ? icon
              : uri.resolve(icon).toString();
        }
      }
    } catch (_) {}
    return null;
  }

  Widget _buildImagePreview() {
    Widget? imageWidget;
    if (_imageBytes != null) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(
              _imageBytes!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 120,
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _imageBytes = null;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_previewImageUrl != null) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _previewImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 120,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Text(
              'No preview image found',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ),
      );
    } else {
      imageWidget = const Center(
        child: Text(
          "Drag & drop an image here\nor enter a URL above",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: imageWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCardPriceField(
          controller: priceController,
          focusNode: priceFocusNode,
        ),
        CustomCardUrlField(
          controller: urlController,
          focusNode: urlFocusNode,
          onSubmitted: widget.cardProvider.setUrl,
          scrollController: urlScrollController,
        ),
        const SizedBox(height: 10),
        DragTarget<Uint8List>(
          onAccept: (bytes) {
            setState(() {
              _imageBytes = bytes;
            });
          },
          onWillAccept: (data) => true,
          builder: (context, candidateData, rejectedData) {
            return _buildImagePreview();
          },
        ),
      ],
    );
  }
}
