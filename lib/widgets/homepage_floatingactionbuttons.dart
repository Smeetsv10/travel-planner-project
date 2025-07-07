import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_scheduler/classes/card_list_provider.dart';
import 'package:travel_scheduler/classes/app_settings.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/classes/functions.dart';
import 'package:travel_scheduler/widgets/card_chains_page.dart';

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

  Widget _buildAddCardButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'add_card',
      onPressed: () =>
          showModalBottomSheet<CardType>(
            context: context,
            backgroundColor: Colors.blueAccent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: SizedBox(width: 50, child: blankIcon()),
                  title: const Text(
                    'Add Blank Card',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, CardType.blank),
                ),
                ListTile(
                  leading: SizedBox(width: 50, child: outgoingFlightIcon()),
                  title: const Text(
                    'Add Flight Card',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, CardType.flight),
                ),

                ListTile(
                  leading: SizedBox(width: 50, child: accomodationIcon()),
                  title: const Text(
                    'Add Accomodation Card',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, CardType.accommodation),
                ),
                ListTile(
                  leading: SizedBox(width: 50, child: transportationIcon()),
                  title: const Text(
                    'Add Transportation Card',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, CardType.transportation),
                ),
              ],
            ),
          ).then((choice) {
            if (choice != null) _addCard(context, choice);
          }),
      backgroundColor: Colors.blueAccent,
      child: const Icon(Icons.add),
    );
  }

  Widget _buildPrintButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'print_cardproviders',
      onPressed: () => _printAllCardProviders(context),
      backgroundColor: Colors.green,
      tooltip: 'Print all CardProviders',
      child: const Icon(Icons.print),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    CardListProvider cardListProvider,
  ) {
    return FloatingActionButton(
      heroTag: 'save_menu',
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.blueAccent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.save, color: Colors.white),
                title: const Text(
                  'Save Locally',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  cardListProvider.saveCardsLocally(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_download, color: Colors.white),
                title: const Text(
                  'Save As File',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  cardListProvider.saveCardsToFile(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_open, color: Colors.white),
                title: const Text(
                  'Load From File',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await cardListProvider.loadCardsFromFile();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error loading file: $e')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore_page, color: Colors.white),
                title: const Text(
                  'Reload App',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  cardListProvider.loadCardsLocally(context);
                },
              ),
            ],
          ),
        );
      },
      backgroundColor: Colors.amber[700],
      child: const Icon(Icons.save),
    );
  }

  Widget _buildShowRootCardsButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'show_root_cards',
      onPressed: () {
        final chains = context.read<CardListProvider>().cardChainList;
        for (var chain in chains) {
          print(chain.map((c) => c.title).join(' -> '));
        }
      },
      backgroundColor: Colors.purple,
      tooltip: 'Show Root Cards',
      child: const Icon(Icons.account_tree),
    );
  }

  void openCardChainsPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CardChainsPage()));
  }

  Widget _buildShowChainsButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'show_card_chains',
      onPressed: () => openCardChainsPage(context),
      backgroundColor: Colors.teal,
      tooltip: 'Show Card Chains',
      child: const Icon(Icons.grid_view),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardListProvider = context.read<CardListProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAddCardButton(context),
        const SizedBox(height: 12),
        _buildPrintButton(context),
        const SizedBox(height: 12),
        _buildSaveButton(context, cardListProvider),
        const SizedBox(height: 12),
        _buildShowRootCardsButton(context),
        const SizedBox(height: 12),
        _buildShowChainsButton(context),
      ],
    );
  }
}
