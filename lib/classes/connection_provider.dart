import 'package:flutter/material.dart';
import 'package:travel_scheduler/classes/card_provider.dart';

class ConnectionProvider extends ChangeNotifier {
  final String? id;
  final GlobalKey? fromNodeKey;
  final GlobalKey? toNodeKey;
  final CardProvider fromProvider;
  final CardProvider targetProvider;
  Color? color;
  bool isValid = true;

  ConnectionProvider({
    String? id,
    Color? color,
    GlobalKey? fromNodeKey,
    GlobalKey? toNodeKey,
    required this.fromProvider,
    required this.targetProvider,
  }) : id = id ?? '${fromProvider.id}_${targetProvider.id}',
       fromNodeKey = fromNodeKey ?? fromProvider.fromNodeKey,
       toNodeKey = toNodeKey ?? targetProvider.toNodeKey {
    this.color = color ?? (isValid ? Colors.white : Colors.red);
  }

  void setValid(bool valid) {
    isValid = valid;
    color = valid ? Colors.white : Colors.red;
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
    'fromProviderId': fromProvider.id,
    'targetProviderId': targetProvider.id,
  };

  static ConnectionProvider fromJson(
    Map<String, dynamic> json,
    List<CardProvider> providers,
  ) {
    final from = providers.firstWhere((p) => p.id == json['fromProviderId']);
    final to = providers.firstWhere((p) => p.id == json['targetProviderId']);
    return ConnectionProvider(fromProvider: from, targetProvider: to);
  }
}
