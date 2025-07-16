import 'package:flutter/material.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_price_field.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_url_field.dart';

class PriceUrlCardField extends StatelessWidget {
  final TextEditingController priceController;
  final FocusNode priceFocusNode;
  final TextEditingController urlController;
  final FocusNode urlFocusNode;
  final void Function(String)? onUrlSubmitted;
  final ScrollController? urlScrollController;

  const PriceUrlCardField({
    super.key,
    required this.priceController,
    required this.priceFocusNode,
    required this.urlController,
    required this.urlFocusNode,
    this.onUrlSubmitted,
    this.urlScrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: CustomCardPriceField(
            controller: priceController,
            focusNode: priceFocusNode,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomCardUrlField(
            controller: urlController,
            focusNode: urlFocusNode,
            onSubmitted: onUrlSubmitted,
            scrollController: urlScrollController,
          ),
        ),
      ],
    );
  }
}
