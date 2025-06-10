import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/classes/connection.dart';
import 'package:travel_scheduler/widgets/CustomCards/accomodation_card.dart';
import 'package:travel_scheduler/widgets/CustomCards/customcard.dart';
import 'package:travel_scheduler/widgets/CustomCards/flight_card.dart';
import 'package:travel_scheduler/widgets/CustomCards/transportation_card.dart';

class CardListProvider with ChangeNotifier {
  List<CardProvider> _cardProviders = [];
  List<Connection> _connections = [
    Connection(fromOffset: Offset(0, 0), toOffset: Offset(100, 100)),
  ];

  List<Connection> get connections => List.unmodifiable(_connections);
  List<CardProvider> get cardProviders => List.unmodifiable(_cardProviders);

  void addCardProvider(CardProvider cardProvider) {
    _cardProviders.add(cardProvider);
    notifyListeners();
  }

  void removeCardProvider(CardProvider cardProvider) {
    final findId = _cardProviders.indexWhere(
      (cardP) => cardP.id == cardProvider.id,
    );
    if (findId != -1) {
      _cardProviders.removeAt(findId);
      notifyListeners();
    }
  }

  void clearCardProviders() {
    _cardProviders.clear();
    notifyListeners();
  }

  void selectCard(String cardId) {
    final selectedIndex = _cardProviders.indexWhere(
      (provider) => provider.id == cardId,
    );

    if (selectedIndex != -1 && selectedIndex != _cardProviders.length - 1) {
      // Remove the selected card and add it to the end (top of stack)
      final selectedProvider = _cardProviders.removeAt(selectedIndex);
      _cardProviders.add(selectedProvider);
      notifyListeners();
    }
  }

  // Build card from cardProvider
  Widget buildCardFromProvider(CardProvider cardProvider) {
    final card = switch (cardProvider.cardType) {
      CardType.blank => CustomCard(cardProvider: cardProvider),
      CardType.outFlight ||
      CardType.returnFlight => FlightCard(cardProvider: cardProvider),
      CardType.accommodation => AccommodationCard(cardProvider: cardProvider),
      CardType.transportation => TransportationCard(cardProvider: cardProvider),
    };

    return card;
  }

  List<Widget> buildAllCards() {
    return _cardProviders.map(buildCardFromProvider).toList();
  }

  // Json encoding
  List<Map<String, dynamic>> toJson() {
    return _cardProviders.map((cardP) => cardP.toJson()).toList();
  }

  void fromJson(List<dynamic> jsonList) {
    _cardProviders = jsonList
        .map((json) => CardProvider.fromJson(json as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<void> saveCardsLocally(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final cardProvidersJson = toJson();
    final encoded = jsonEncode(cardProvidersJson);
    await prefs.setString('saved_cards', encoded);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cards saved successfully!')));
  }

  Future<void> saveCardsToFile(BuildContext context) async {
    try {
      final cardProvidersJson = toJson();
      final encoded = jsonEncode(cardProvidersJson);

      final bytes = Uint8List.fromList(utf8.encode(encoded));
      final fileName = 'cards_backup.json';

      await FilePicker.platform.saveFile(
        dialogTitle: 'Save your cards as JSON file',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes, // required on web
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cards saved as file successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving file: $e')));
    }
  }

  Future<void> loadCardsLocally(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('saved_cards');
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      fromJson(jsonList);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cards loaded successfully!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No saved cards found.')));
    }
  }

  Future<void> loadCardsFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select a JSON file to load',
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      // User canceled
      return;
    }

    final bytes = result.files.single.bytes;
    if (bytes == null) throw Exception('Failed to read file bytes');
    final contents = utf8.decode(bytes);
    final jsonList = jsonDecode(contents) as List<dynamic>;
    fromJson(jsonList);
  }

  // Dependant properties
  int get totalCardCount => _cardProviders.length;
}
