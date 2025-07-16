import 'package:flutter/material.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_field.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_priceUrl_field.dart';
import 'package:travel_scheduler/widgets/CustomCards/customcard.dart';
import 'package:url_launcher/url_launcher.dart';

class TransportationCard extends CustomCard {
  TransportationCard({super.key, required super.cardProvider})
    : super(body: _TransportationCardBody(cardProvider: cardProvider));
}

class _TransportationCardBody extends StatefulWidget {
  final CardProvider cardProvider;
  const _TransportationCardBody({required this.cardProvider});

  @override
  State<_TransportationCardBody> createState() =>
      _TransportationCardBodyState();
}

class _TransportationCardBodyState extends State<_TransportationCardBody> {
  late TextEditingController fromController;
  late TextEditingController toController;
  late TextEditingController priceController;
  late TextEditingController urlController;
  late ScrollController urlScrollController;
  late ScrollController fromScrollController;
  late ScrollController toScrollController;

  late FocusNode fromFocusNode;
  late FocusNode toFocusNode;
  late FocusNode priceFocusNode;
  late FocusNode urlFocusNode;

  final List<IconData> _transportIcons = [
    Icons.directions_car,
    Icons.directions_bus,
    Icons.train,
    Icons.directions_ferry,
    Icons.directions_bike,
  ];

  int _selectedIconIndex = 0;

  @override
  void initState() {
    super.initState();

    _selectedIconIndex = widget.cardProvider.transportIconIndex!;

    fromController = TextEditingController(
      text: widget.cardProvider.departureLocation,
    );
    toController = TextEditingController(
      text: widget.cardProvider.arrivalLocation,
    );
    priceController = TextEditingController(
      text: widget.cardProvider.price.toString(),
    );
    urlController = TextEditingController(text: widget.cardProvider.url);

    urlScrollController = ScrollController();
    fromScrollController = ScrollController();
    toScrollController = ScrollController();

    fromFocusNode = FocusNode();
    toFocusNode = FocusNode();
    priceFocusNode = FocusNode();
    urlFocusNode = FocusNode();

    fromFocusNode.addListener(() {
      widget.cardProvider.setDepartureLocation(fromController.text.trim());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fromController.selection = const TextSelection.collapsed(offset: 0);
        fromScrollController.jumpTo(0);
      });
    });

    toFocusNode.addListener(() {
      if (!toFocusNode.hasFocus) {
        widget.cardProvider.setArrivalLocation(toController.text.trim());
        WidgetsBinding.instance.addPostFrameCallback((_) {
          fromController.selection = const TextSelection.collapsed(offset: 0);
          fromScrollController.jumpTo(0);
        });
      }
    });

    priceFocusNode.addListener(() {
      if (!priceFocusNode.hasFocus) {
        final text = priceController.text.trim();
        final value = double.tryParse(text);
        if (value != null) {
          widget.cardProvider.setPrice(value);
        }
      }
    });

    urlFocusNode.addListener(() {
      if (!urlFocusNode.hasFocus) {
        final text = urlController.text.trim();
        widget.cardProvider.setUrl(text);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          // urlController.text = text;
          urlController.selection = const TextSelection.collapsed(offset: 0);
          urlScrollController.jumpTo(0);
        });
      }
    });
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    priceController.dispose();
    urlController.dispose();
    urlScrollController.dispose();

    fromFocusNode.dispose();
    toFocusNode.dispose();
    priceFocusNode.dispose();
    urlFocusNode.dispose();
    super.dispose();
  }

  Future<void> openGoogleMapsDirections({
    required String destination,
    String? origin,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${Uri.encodeComponent(destination)}'
      '${origin != null ? '&origin=${Uri.encodeComponent(origin)}' : ''}',
    );

    if (!await launchUrl(uri, webOnlyWindowName: '_blank')) {
      throw Exception('Could not launch $uri');
    }
  }

  Widget buildLocationSelector() {
    return Container(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Text("Type:", style: TextStyle(color: Colors.white70)),
          const SizedBox(width: 8),
          ...List.generate(_transportIcons.length, (i) {
            return IconButton(
              icon: Icon(
                _transportIcons[i],
                color: _selectedIconIndex == i
                    ? const Color.fromARGB(255, 255, 215, 64)
                    : Colors.white54,
              ),
              onPressed: () {
                setState(() {
                  _selectedIconIndex = i;
                  widget.cardProvider.setTransportIconIndex(i);
                });
              },
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.cardProvider,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildLocationSelector(),
            CustomCardField(
              label: "From",
              labelWidth: 100,
              iconWidget: GestureDetector(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
                onTap: () async {
                  await openGoogleMapsDirections(
                    origin: "Home",
                    destination: "Brussels Airport (BRU)",
                  );
                },
              ),

              controller: fromController,
              focusNode: fromFocusNode,
              onSubmitted: widget.cardProvider.setDepartureLocation,
              scrollController: fromScrollController,
            ),
            CustomCardField(
              label: "To",
              labelWidth: 100,
              iconWidget: GestureDetector(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const Icon(Icons.arrow_back, color: Colors.white),
                  ],
                ),
                onTap: () async {
                  await openGoogleMapsDirections(
                    origin: "Home",
                    destination: "Brussels Airport (BRU)",
                  );
                },
              ),

              controller: toController,
              focusNode: toFocusNode,
              onSubmitted: widget.cardProvider.setArrivalLocation,
              scrollController: toScrollController,
            ),
            // To location
            PriceUrlCardField(
              priceController: priceController,
              priceFocusNode: priceFocusNode,
              urlController: urlController,
              urlFocusNode: urlFocusNode,
              onUrlSubmitted: widget.cardProvider.setUrl,
              urlScrollController: urlScrollController,
            ),
          ],
        );
      },
    );
  }
}
