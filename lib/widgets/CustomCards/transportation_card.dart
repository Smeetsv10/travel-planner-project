import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_field.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_price_field.dart';
import 'package:travel_scheduler/widgets/CustomCards/customcard.dart';
import 'package:travel_scheduler/widgets/CustomCards/location_picker_dialog.dart';

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

  late FocusNode fromFocusNode;
  late FocusNode toFocusNode;
  late FocusNode priceFocusNode;
  late FocusNode urlFocusNode;

  final List<IconData> _transportIcons = [
    Icons.directions_bus,
    Icons.train,
    Icons.directions_car,
    Icons.flight,
    Icons.directions_boat,
  ];

  int _selectedIconIndex = 0;

  @override
  void initState() {
    super.initState();

    _selectedIconIndex = widget.cardProvider.transportIconIndex;

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

    fromFocusNode = FocusNode();
    toFocusNode = FocusNode();
    priceFocusNode = FocusNode();
    urlFocusNode = FocusNode();

    fromFocusNode.addListener(() {
      widget.cardProvider.setDepartureLocation(fromController.text.trim());
    });

    toFocusNode.addListener(() {
      if (!toFocusNode.hasFocus) {
        widget.cardProvider.setArrivalLocation(toController.text.trim());
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
          urlController.text = text;
          urlController.selection = const TextSelection.collapsed(offset: 0);
          urlScrollController.jumpTo(
            0,
          ); // This forces the scroll to the beginning
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.cardProvider,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
            ),
            // From Location selection
            CustomCardField(
              label: "From",
              iconWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.location_on, color: Colors.white),
                    tooltip: "Pick location on map",
                    onPressed: () async {
                      final picked = await showDialog<LatLng>(
                        context: context,
                        builder: (context) => LocationPickerDialog(),
                      );
                      if (picked != null) {
                        fromController.text =
                            "${picked.latitude}, ${picked.longitude}";
                        widget.cardProvider.setDepartureLocation(
                          fromController.text.trim(),
                        );
                        setState(() {});
                      }
                    },
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
              controller: fromController,
              focusNode: fromFocusNode,
              onSubmitted: widget.cardProvider.setDepartureLocation,
            ),
            // To location
            CustomCardPriceField(
              controller: priceController,
              focusNode: priceFocusNode,
            ),
          ],
        );
      },
    );
  }
}
