import 'package:flutter/material.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/widgets/CustomCards/customcard_widget.dart';

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
