import 'package:travel_scheduler/classes/card_provider.dart';

class Connection {
  final CardProvider fromCardProvider;
  final CardProvider toCardProvider;

  Connection({required this.fromCardProvider, required this.toCardProvider});
}
