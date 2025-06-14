import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/classes/connection_provider.dart';
import 'package:travel_scheduler/widgets/CustomCards/accomodation_card.dart';
import 'package:travel_scheduler/widgets/CustomCards/connection.dart';
import 'package:travel_scheduler/widgets/CustomCards/customcard.dart';
import 'package:travel_scheduler/widgets/CustomCards/flight_card.dart';
import 'package:travel_scheduler/widgets/CustomCards/transportation_card.dart';

class CardListProvider with ChangeNotifier {
  List<CardProvider> _cardProviders = [];
  List<ConnectionProvider> _connectionsProviders = [];
  GlobalKey _stackKey = GlobalKey();

  List<CardProvider> get cardProviders => List.unmodifiable(_cardProviders);
  List<ConnectionProvider> get connectionProviders =>
      List.unmodifiable(_connectionsProviders);
  GlobalKey get stackKey => _stackKey;
  int get totalCardCount => _cardProviders.length;

  // CardProvider management
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

  // Connections management
  void addConnectionProvider(ConnectionProvider connectionProvider) {
    final exists = _connectionsProviders.any(
      (c) => c.id == connectionProvider.id,
    );
    if (!exists) {
      _connectionsProviders.add(connectionProvider);
      notifyListeners();
    }
  }

  void removeConnectionProvider(ConnectionProvider connectionProvider) {
    _connectionsProviders.removeWhere((c) => c.id == connectionProvider.id);
    notifyListeners();
  }

  void clearConnectionProviders() {
    _connectionsProviders.clear();
    notifyListeners();
  }

  void removeConnectionsForCard(CardProvider cardProvider) {
    // Collect all connections to be removed
    final toRemove = _connectionsProviders
        .where(
          (conn) =>
              conn.fromProvider.id == cardProvider.id ||
              conn.targetProvider.id == cardProvider.id,
        )
        .toList();

    // For each connection to be removed, reconnect its other endpoint to all other endpoints
    for (final conn in toRemove) {
      // Find all connections that share the same start or end as the card being removed
      for (final other in toRemove) {
        if (conn == other) continue;

        // If both connections share the same card as start or end, connect their other endpoints
        if (conn.fromProvider.id == cardProvider.id &&
            other.targetProvider.id == cardProvider.id) {
          // Connect conn.targetProvider to other.fromProvider
          addConnectionProvider(
            ConnectionProvider(
              fromProvider: other.fromProvider,
              targetProvider: conn.targetProvider,
            ),
          );
        }
        if (conn.targetProvider.id == cardProvider.id &&
            other.fromProvider.id == cardProvider.id) {
          // Connect conn.fromProvider to other.targetProvider
          addConnectionProvider(
            ConnectionProvider(
              fromProvider: conn.fromProvider,
              targetProvider: other.targetProvider,
            ),
          );
        }
      }
    }

    // Remove all connections involving the card
    _connectionsProviders.removeWhere(
      (conn) =>
          conn.fromProvider.id == cardProvider.id ||
          conn.targetProvider.id == cardProvider.id,
    );
    notifyListeners();
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

  // Build connection from connectionProvider
  Widget buildConnectionFromProvider(ConnectionProvider connectionProvider) {
    return Connection(
      connectionProvider: connectionProvider,
      stackKey: _stackKey,
    );
  }

  List<Widget> buildAllConnections() {
    return _connectionsProviders
        .map((conn) => buildConnectionFromProvider(conn))
        .toList();
  }

  // Json encoding
  Map<String, dynamic> toJson() {
    return {
      'cards': _cardProviders.map((cardP) => cardP.toJson()).toList(),
      'connections': _connectionsProviders
          .map((conn) => conn.toJson())
          .toList(),
    };
  }

  void fromJson(Map<String, dynamic> json) {
    _cardProviders = (json['cards'] as List)
        .map((j) => CardProvider.fromJson(j as Map<String, dynamic>))
        .toList();

    _connectionsProviders.clear();
    if (json['connections'] != null) {
      for (final connJson in json['connections']) {
        _connectionsProviders.add(
          ConnectionProvider.fromJson(
            connJson as Map<String, dynamic>,
            _cardProviders,
          ),
        );
      }
    }
    notifyListeners();

    // Add this to trigger a rebuild after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
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
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      fromJson(jsonMap);
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
    final jsonMap = jsonDecode(contents) as Map<String, dynamic>;
    fromJson(jsonMap);
  }
}
