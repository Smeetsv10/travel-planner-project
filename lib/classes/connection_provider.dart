import 'package:flutter/material.dart';
import 'package:travel_scheduler/classes/card_provider.dart';

class ConnectionProvider extends ChangeNotifier {
  String? id;
  final GlobalKey? fromNodeKey;
  final GlobalKey? toNodeKey;
  final CardProvider fromProvider;
  final CardProvider targetProvider;
  Color? color;

  ConnectionProvider({
    final String? id,
    final Color? color,
    final GlobalKey? fromNodeKey,
    final GlobalKey? toNodeKey,
    required this.fromProvider,
    required this.targetProvider,
  }) : id = id ?? '${fromProvider.id}_${targetProvider.id}',
       color = color ?? Colors.white,
       fromNodeKey = fromNodeKey ?? fromProvider.fromNodeKey,
       toNodeKey = toNodeKey ?? targetProvider.toNodeKey;

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
