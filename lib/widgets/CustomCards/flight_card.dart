import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/classes/functions.dart';
import 'package:travel_scheduler/widgets/CustomCards/customcard_widget.dart';
import 'package:travel_scheduler/widgets/date_picker_dialog.dart';
import 'package:travel_scheduler/widgets/time_picker_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class FlightCard extends CustomCard {
  FlightCard({
    super.key,
    required super.cardProvider, // Super parameter
  }) : super(body: _FlightCardBody(cardProvider: cardProvider));
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

  static const _labelStyle = TextStyle(color: Colors.white70);
  static const _dateTimeStyle = TextStyle(color: Colors.white54, fontSize: 14);
  final _borderDecoration = BoxDecoration(
    border: Border.all(color: Colors.white38, width: 1),
    borderRadius: BorderRadius.circular(4),
  );

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
      if (!fromFocusNode.hasFocus) {
        widget.cardProvider.setDepartureLocation(fromController.text.trim());
      }
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

  String _formatDate(DateTime dt) => DateFormat('dd-MMM-yyyy').format(dt);
  String _formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initialDateTime,
    required void Function(DateTime) onDatePicked,
  }) async {
    final picked = await showDatePickerDialog(
      context: context,
      initialDateTime: initialDateTime,
    );
    if (picked != null) {
      onDatePicked(picked);
    }
  }

  Future<void> _pickTime({
    required BuildContext context,
    required DateTime initialDateTime,
    required void Function(TimeOfDay) onTimePicked,
  }) async {
    final picked = await showTimePickerDialog(
      context: context,
      initialDateTime: initialDateTime,
    );
    if (picked != null) {
      onTimePicked(picked);
    }
  }

  void _updateControllerText(TextEditingController controller, String newText) {
    if (controller.text != newText) {
      controller.text = newText;
    }
  }

  Widget buildField({
    required BuildContext context,
    Widget? iconWidget,
    required String label,
    TextEditingController? controller,
    FocusNode? focusNode,
    DateTime? dateTime,
    void Function(String)? onSubmitted,
    void Function(DateTime)? onDatePicked,
    void Function(TimeOfDay)? onTimePicked,
  }) {
    final bool isDateTimeField =
        dateTime != null && onDatePicked != null && onTimePicked != null;
    if (focusNode != null && controller != null) {
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        }
      });
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      width: 303,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (iconWidget != null) ...[iconWidget, const SizedBox(width: 8)],
          SizedBox(width: 40, child: Text(label, style: _labelStyle)),
          const SizedBox(width: 5),
          if (controller != null && focusNode != null) ...[
            Expanded(
              child: TextField(
                controller: controller,
                scrollController: label == "URL" ? urlScrollController : null,

                focusNode: focusNode,
                onSubmitted: onSubmitted,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.left,
                keyboardType: label == "Price"
                    ? TextInputType.numberWithOptions(decimal: true)
                    : null,
                inputFormatters: label == "Price"
                    ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]
                    : (label == "From" || label == "To"
                          ? [UpperCaseTextFormatter()]
                          : []),
              ),
            ),
          ],
          if (isDateTimeField) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: () => _pickDate(
                context: context,
                initialDateTime: dateTime,
                onDatePicked: onDatePicked,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: _borderDecoration,
                child: Text(_formatDate(dateTime), style: _dateTimeStyle),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _pickTime(
                context: context,
                initialDateTime: dateTime,
                onTimePicked: onTimePicked,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: _borderDecoration,
                child: Text(_formatTime(dateTime), style: _dateTimeStyle),
              ),
            ),
          ],
        ],
      ),
    );
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
            buildField(
              context: context,
              iconWidget: Icon(Icons.flight_takeoff, color: Colors.white),
              label: "From",
              controller: fromController,
              focusNode: fromFocusNode,
              dateTime: widget.cardProvider.departureDatetime,
              onSubmitted: widget.cardProvider.setDepartureLocation,
              onDatePicked: widget.cardProvider.setDepartureDate,
              onTimePicked: widget.cardProvider.setDepartureTime,
            ),
            buildField(
              context: context,
              iconWidget: Icon(Icons.flight_land, color: Colors.white),
              label: "To",
              controller: toController,
              focusNode: toFocusNode,
              dateTime: widget.cardProvider.arrivalDatetime,
              onSubmitted: widget.cardProvider.setArrivalLocation,
              onDatePicked: widget.cardProvider.setArrivalDate,
              onTimePicked: widget.cardProvider.setArrivalTime,
            ),
            buildField(
              context: context,
              iconWidget: Icon(Icons.euro, color: Colors.white),
              label: "Price",
              controller: priceController,
              focusNode: priceFocusNode,
              onSubmitted: (value) {
                final v = double.tryParse(value);
                if (v != null) widget.cardProvider.setPrice(v);
              },
            ),
            buildField(
              context: context,
              iconWidget: InkWell(
                onTap: () async {
                  final urlText = urlController.text.trim();
                  if (urlText.isNotEmpty) {
                    final uri = Uri.tryParse(urlText);
                    if (uri != null && await canLaunchUrl(uri)) {
                      if (!mounted) return;
                      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid URL')),
                      );
                    }
                  }
                },

                child: const Icon(Icons.link, color: Colors.white),
              ),
              label: "URL",
              controller: urlController,
              focusNode: urlFocusNode,
              onSubmitted: widget.cardProvider.setUrl,
            ),
          ],
        );
      },
    );
  }
}
