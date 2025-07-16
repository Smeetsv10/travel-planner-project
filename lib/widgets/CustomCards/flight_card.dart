import 'package:flutter/material.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/classes/functions.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_field.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_priceUrl_field.dart';
import 'package:travel_scheduler/widgets/CustomCards/customcard.dart';

class FlightCard extends CustomCard {
  FlightCard({super.key, required super.cardProvider})
    : super(body: _FlightCardBody(cardProvider: cardProvider));
}

class _FlightCardBody extends StatefulWidget {
  final CardProvider cardProvider;
  const _FlightCardBody({required this.cardProvider});

  @override
  State<_FlightCardBody> createState() => _FlightCardBodyState();
}

class _FlightCardBodyState extends State<_FlightCardBody> {
  late TextEditingController fromController;
  late TextEditingController toController;
  late TextEditingController priceController;
  late TextEditingController urlController;
  late ScrollController urlScrollController;

  late FocusNode fromFocusNode;
  late FocusNode toFocusNode;
  late FocusNode priceFocusNode;
  late FocusNode urlFocusNode;

  @override
  void initState() {
    super.initState();
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

  void _updateControllerText(TextEditingController controller, String newText) {
    if (controller.text != newText) {
      controller.text = newText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.cardProvider,
      builder: (context, _) {
        _updateControllerText(
          fromController,
          widget.cardProvider.departureLocation,
        );
        _updateControllerText(
          toController,
          widget.cardProvider.arrivalLocation,
        );
        _updateControllerText(
          priceController,
          widget.cardProvider.price.toString(),
        );
        _updateControllerText(urlController, widget.cardProvider.url);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCardField(
              label: "From",
              iconWidget: Icon(Icons.flight_takeoff, color: Colors.white),
              controller: fromController,
              focusNode: fromFocusNode,
              dateTime: widget.cardProvider.departureDatetime,
              onSubmitted: widget.cardProvider.setDepartureLocation,
              onDatePicked: widget.cardProvider.setDepartureDate,
              onTimePicked: widget.cardProvider.setDepartureTime,
              inputFormatters: [UpperCaseTextFormatter()],
              showDateField: true,
              showTimeField: true,
            ),
            CustomCardField(
              label: "To",
              iconWidget: Icon(Icons.flight_land, color: Colors.white),
              controller: toController,
              focusNode: toFocusNode,
              dateTime: widget.cardProvider.arrivalDatetime,
              onSubmitted: widget.cardProvider.setArrivalLocation,
              onDatePicked: widget.cardProvider.setArrivalDate,
              onTimePicked: widget.cardProvider.setArrivalTime,
              inputFormatters: [UpperCaseTextFormatter()],
              showDateField: true,
              showTimeField: true,
            ),
            PriceUrlCardField(
              priceController: priceController,
              priceFocusNode: priceFocusNode,
              urlController: urlController,
              urlFocusNode: urlFocusNode,
              onUrlSubmitted: widget.cardProvider.setUrl,
              urlScrollController: urlScrollController,
            ),
            // CustomCardPriceField(
            //   controller: priceController,
            //   focusNode: priceFocusNode,
            // ),
            // CustomCardUrlField(
            //   controller: urlController,
            //   focusNode: urlFocusNode,
            //   onSubmitted: widget.cardProvider.setUrl,
            //   scrollController: urlScrollController,
            // ),
          ],
        );
      },
    );
  }
}
