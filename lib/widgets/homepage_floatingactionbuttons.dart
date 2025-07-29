import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_scheduler/classes/card_list_provider.dart';
import 'package:travel_scheduler/classes/app_settings.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/classes/functions.dart';
import 'package:travel_scheduler/widgets/card_chains_page.dart';
import 'package:travel_scheduler/widgets/clustor_button.dart';

class HomePageFloatingActionButtons extends StatefulWidget {
  final TransformationController transformationController;

  const HomePageFloatingActionButtons({
    super.key,
    required this.transformationController,
  });

  @override
  State<HomePageFloatingActionButtons> createState() =>
      _HomePageFloatingActionButtonsState();
}

class _HomePageFloatingActionButtonsState
    extends State<HomePageFloatingActionButtons> {
  Offset _getCurrentViewportCenter(BuildContext context) {
    final matrix = widget.transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();
    final translation = matrix.getTranslation();
    final screenSize = MediaQuery.of(context).size;
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    final canvasCenter =
        (screenCenter - Offset(translation.x, translation.y)) / scale;
    final snappedX = (canvasCenter.dx - AppSettings.cardWidth / 2).round();
    final snappedY = canvasCenter.dy.round();
    return Offset(snappedX.toDouble(), snappedY.toDouble());
  }

  void _addCard(BuildContext context, CardType type) {
    try {
      final cardListProvider = context.read<CardListProvider>();
      final cardProvider = CardProvider(
        cardType: type,
        position: _getCurrentViewportCenter(context),
      );
      cardListProvider.addCardProvider(cardProvider);
    } catch (e) {
      debugPrint('Failed to add card: $e');
    }
  }

  void _printAllCardProviders(BuildContext context) {
    final cardListProvider = context.read<CardListProvider>();
    print('--- Printing all CardProviders ---');
    print('Total card count: ${cardListProvider.totalCardCount}');
    for (var cardProvider in cardListProvider.cardProviders) {
      print('Card title: ${cardProvider.title}');
      print('Departure location: ${cardProvider.departureLocation}');
      print('Departure datetime: ${cardProvider.departureDatetime}');
      print('Arrival location: ${cardProvider.arrivalLocation}');
      print('Arrival datetime: ${cardProvider.arrivalDatetime}');
      print('Price: ${cardProvider.price}');
      print('Url: ${cardProvider.url}');
      print('Uid: ${cardProvider.id}');
      print('transportIconIndex: ${cardProvider.transportIconIndex}');
      print('---');
    }
    print('--- End of CardProviders ---');
    print(
      cardListProvider.connectionProviders
          .map((c) => c.fromProvider.id)
          .toList(),
    );
    print(
      cardListProvider.connectionProviders
          .map((c) => c.targetProvider.id)
          .toList(),
    );
  }

  void openCardChainsPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CardChainsPage()));
  }

  @override
  Widget build(BuildContext context) {
    final cardListProvider = context.read<CardListProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Add Card Button with nested card type buttons
        ClusterButton(
          backgroundColor: Colors.blueAccent,
          axisDirection: AxisDirection.left,
          child: const Icon(Icons.add, color: Colors.white),
          children: [
            ClusterButton(
              backgroundColor: AppSettings.blankCardColor,
              buttonSize: const Size(50, 50),
              child: blankIcon(),
              onPressed: () => _addCard(context, CardType.blank),
              children: const [],
            ),
            ClusterButton(
              backgroundColor: AppSettings.flightCardColor,
              buttonSize: const Size(50, 50),
              child: flightIcon(),
              onPressed: () => _addCard(context, CardType.flight),
              children: const [],
            ),
            ClusterButton(
              backgroundColor: AppSettings.accommodationCardColor,
              buttonSize: const Size(50, 50),
              child: accommodationIcon(),
              onPressed: () => _addCard(context, CardType.accommodation),
              children: const [],
            ),
            ClusterButton(
              backgroundColor: AppSettings.transportationCardColor,
              buttonSize: const Size(50, 50),
              child: transportationIcon(),
              onPressed: () => _addCard(context, CardType.transportation),
              children: const [],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Print Button
        ClusterButton(
          backgroundColor: Colors.green,
          child: const Icon(Icons.print, color: Colors.white),
          onPressed: () => _printAllCardProviders(context),
          children: const [],
        ),
        const SizedBox(height: 12),

        // Save/Load Button with nested options
        ClusterButton(
          backgroundColor: Colors.amber,
          axisDirection: AxisDirection.left,
          child: const Icon(Icons.save, color: Colors.white),
          children: [
            ClusterButton(
              backgroundColor: Colors.orange,
              buttonSize: const Size(50, 50),
              child: const Icon(Icons.save, color: Colors.white, size: 20),
              onPressed: () => cardListProvider.saveCardsLocally(context),
              children: const [],
            ),
            ClusterButton(
              backgroundColor: Colors.deepOrange,
              buttonSize: const Size(50, 50),
              child: const Icon(
                Icons.file_download,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => cardListProvider.saveCardsToFile(context),
              children: const [],
            ),
            ClusterButton(
              backgroundColor: Colors.red,
              buttonSize: const Size(50, 50),
              child: const Icon(
                Icons.folder_open,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () async {
                try {
                  await cardListProvider.loadCardsFromFile();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading file: $e')),
                  );
                }
              },
              children: const [],
            ),
            ClusterButton(
              backgroundColor: Colors.purple,
              buttonSize: const Size(50, 50),
              child: const Icon(
                Icons.restore_page,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => cardListProvider.loadCardsLocally(context),
              children: const [],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Show Chains Button
        ClusterButton(
          backgroundColor: Colors.teal,
          child: const Icon(Icons.grid_view, color: Colors.white),
          onPressed: () => openCardChainsPage(context),
          children: const [],
        ),
      ],
    );
  }
}
