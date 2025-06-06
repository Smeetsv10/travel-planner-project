import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_field.dart';

class CustomCardPriceField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(double)? onPriceChanged;

  const CustomCardPriceField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCardField(
      label: "Price",
      iconWidget: const Icon(Icons.euro, color: Colors.white),
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      onSubmitted: (value) {
        final v = double.tryParse(value);
        if (v != null && onPriceChanged != null) {
          onPriceChanged!(v);
        }
      },
    );
  }
}
