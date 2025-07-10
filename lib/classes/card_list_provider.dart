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
  final List<ConnectionProvider> _connectionsProviders = [];
  final GlobalKey _stackKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController();

  List<CardProvider> get cardProviders => List.unmodifiable(_cardProviders);
  List<ConnectionProvider> get connectionProviders =>
      List.unmodifiable(_connectionsProviders);
  GlobalKey get stackKey => _stackKey;
  int get totalCardCount => _cardProviders.length;
  TransformationController? get transformationController =>
      _transformationController;
  List<List<CardProvider>> get cardChainList {
    List<List<CardProvider>> allChains = [];

    // Build a map from card id to CardProvider for quick lookup
    final Map<String, CardProvider> idToProvider = {
      for (var card in _cardProviders) card.id: card,
    };

    // Build adjacency list: from card id to list of target card ids
    final Map<String, List<String>> adjacency = {};
    for (var conn in _connectionsProviders) {
      adjacency.putIfAbsent(conn.fromProvider.id, () => []);
      adjacency[conn.fromProvider.id]!.add(conn.targetProvider.id);
    }

    // Find root cards (cards that are not a target in any connection)
    final Set<String> targets = {
      for (var conn in _connectionsProviders) conn.targetProvider.id,
    };
    final List<CardProvider> roots = _cardProviders
        .where((card) => !targets.contains(card.id))
        .toList();

    // Recursive DFS to find all paths from root to leaves
    void dfs(String currentId, List<CardProvider> path) {
      path.add(idToProvider[currentId]!);
      if (!adjacency.containsKey(currentId) || adjacency[currentId]!.isEmpty) {
        // Leaf node, add the path
        allChains.add(List<CardProvider>.from(path));
      } else {
        for (var nextId in adjacency[currentId]!) {
          if (path.any((c) => c.id == nextId)) continue; // Prevent cycles
          dfs(nextId, path);
        }
      }
      path.removeLast();
    }

    for (var root in roots) {
      dfs(root.id, []);
    }

    return allChains;
  }

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

  List<DateTime> getDateArray(List<CardProvider> cardChain) {
    List<DateTime> dateArray = [];
    for (var card in cardChain) {
      if (card.departureDatetime != null) {
        dateArray.add(card.departureDatetime!);
      }
      if (card.arrivalDatetime != null) {
        dateArray.add(card.arrivalDatetime!);
      }
    }
    return dateArray;
  }

  bool isAscending(List<DateTime> dates) {
    for (int i = 0; i < dates.length - 1; i++) {
      if (dates[i].isAfter(dates[i + 1])) {
        return false;
      }
    }
    return true;
  }

  void checkValidConnections() {
    // Initialize boolean matrix size _connectionsProviders x cardChainList
    List<List<bool>> isValidConnections = List.generate(
      _connectionsProviders.length,
      (_) => List.filled(cardChainList.length, true),
    );
    // Check for each cardChain if the connection is valid, i.e the dates are in ascending order
    for (int j = 0; j < cardChainList.length; j++) {
      List<CardProvider> cardChain = cardChainList[j];
      // if the dateArray is not ascending, set the connections in the cardChain to false
      if (!isAscending(getDateArray(cardChain))) {
        // Find the connections that are in the cardChain
        for (int i = 0; i < _connectionsProviders.length; i++) {
          final connectionProvider = _connectionsProviders[i];
          if (cardChain.contains(connectionProvider.fromProvider) &&
              cardChain.contains(connectionProvider.targetProvider)) {
            isValidConnections[i][j] = false;
          }
        }
      }
    }
    // if any of the rows are false, set the connection to invalid
    for (int i = 0; i < _connectionsProviders.length; i++) {
      bool isValid = isValidConnections[i].every((v) => v);
      _connectionsProviders[i].setValid(isValid);
    }
    notifyListeners();
  }

  // ConnectionProvider management
  void addConnectionProvider(ConnectionProvider connectionProvider) {
    final exists = _connectionsProviders.any(
      (c) => c.id == connectionProvider.id,
    );
    if (!exists) {
      _connectionsProviders.add(connectionProvider);
      notifyListeners();
    }
    // checkValidConnections();
    // notifyListeners();
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
      CardType.flight => FlightCard(cardProvider: cardProvider),
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
