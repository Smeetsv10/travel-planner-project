import 'package:flutter/material.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/widgets/CustomCards/customcard.dart';

class TransportationCard extends CustomCard {
  TransportationCard({
    super.key,
    required super.cardProvider, // Super parameter
  }) : super(body: _TransportationCardBody(cardProvider: cardProvider));
}

class _TransportationCardBody extends StatefulWidget {
  final CardProvider cardProvider;
  const _TransportationCardBody({required this.cardProvider});

  @override
  State<_TransportationCardBody> createState() =>
      _TransportationCardBodyState();
}

class _TransportationCardBodyState extends State<_TransportationCardBody> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.cardProvider,
      builder: (context, _) {
        return Container();
      },
    );
  }
}
