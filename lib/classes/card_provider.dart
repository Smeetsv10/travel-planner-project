import 'package:flutter/material.dart';
import 'package:travel_scheduler/classes/functions.dart';
import 'package:uuid/uuid.dart';

enum CardType { blank, outFlight, returnFlight, accommodation, transportation }

class CardProvider extends ChangeNotifier {
  final String id;
  final CardType cardType;
  final GlobalKey fromNodeKey = GlobalKey();
  final GlobalKey toNodeKey = GlobalKey();

  String title;
  Offset position;
  Widget icon;
  DateTime departureDatetime;
  DateTime arrivalDatetime;
  String departureLocation;
  String arrivalLocation;
  String url;
  double price;
  Color color;
  int transportIconIndex = 0;

  bool isConnect = false;

  CardProvider({
    CardType? cardType,
    String? id,
    Offset? position,

    DateTime? departureDatetime,
    DateTime? arrivalDatetime,
    String? title,
    String? departureLocation,
    String? arrivalLocation,
    String? url,
    double? price,
    Color? color,
    int? transportIconIndex,
  }) : cardType = cardType ?? CardType.blank,
       id = id ?? const Uuid().v4(),
       position = position ?? Offset.zero,
       departureDatetime = departureDatetime ?? DateTime.now(),
       arrivalDatetime = arrivalDatetime ?? DateTime.now(),
       departureLocation = departureLocation ?? '',
       arrivalLocation = arrivalLocation ?? '',
       url = url ?? '',
       price = price ?? 0.0,
       icon = _getIcon(cardType ?? CardType.blank),
       title = title ?? _getTitle(cardType ?? CardType.blank),
       color = color ?? _getColor(cardType ?? CardType.blank);

  // Dependant properties
  static Widget _getIcon(CardType type) {
    switch (type) {
      case CardType.blank:
        return blankIcon();
      case CardType.outFlight:
        return outgoingFlightIcon();
      case CardType.returnFlight:
        return returnFlightIcon();
      case CardType.accommodation:
        return accomodationIcon();
      case CardType.transportation:
        return transportationIcon();
    }
  }

  static String _getTitle(CardType type) {
    switch (type) {
      case CardType.blank:
        return 'Blank card';
      case CardType.outFlight:
        return 'Outgoing Flight';
      case CardType.returnFlight:
        return 'Return Flight';
      case CardType.accommodation:
        return 'Accomodation';
      case CardType.transportation:
        return 'Transportation';
    }
  }

  static Color _getColor(CardType type) {
    switch (type) {
      case CardType.blank:
        return const Color.fromRGBO(96, 125, 139, 0.9); // Keep existing
      case CardType.outFlight:
        return const Color.fromRGBO(33, 150, 243, 0.9); // Bright Blue
      case CardType.returnFlight:
        return const Color.fromRGBO(63, 81, 181, 0.9); // Indigo Blue
      case CardType.accommodation:
        return const Color.fromARGB(230, 221, 70, 24); // Red-Orange
      case CardType.transportation:
        return const Color.fromRGBO(46, 125, 50, 0.9); // Forest Green
    }
  }

  // Setters with notifyListeners
  void setTitle(String newTitle) {
    title = newTitle;
    notifyListeners();
  }

  void setDepartureDatetime(DateTime dt) {
    departureDatetime = dt;
    notifyListeners();
  }

  void setDepartureDate(DateTime dt) {
    departureDatetime = DateTime(
      dt.year,
      dt.month,
      dt.day,
      departureDatetime.hour,
      departureDatetime.minute,
    );
    notifyListeners();
  }

  void setDepartureTime(TimeOfDay time) {
    departureDatetime = DateTime(
      departureDatetime.year,
      departureDatetime.month,
      departureDatetime.day,
      time.hour,
      time.minute,
    );
    notifyListeners();
  }

  void setArrivalDate(DateTime dt) {
    arrivalDatetime = DateTime(
      dt.year,
      dt.month,
      dt.day,
      arrivalDatetime.hour,
      arrivalDatetime.minute,
    );
    notifyListeners();
  }

  void setArrivalTime(TimeOfDay time) {
    arrivalDatetime = DateTime(
      arrivalDatetime.year,
      arrivalDatetime.month,
      arrivalDatetime.day,
      time.hour,
      time.minute,
    );
    notifyListeners();
  }

  void setArrivalDatetime(DateTime dt) {
    arrivalDatetime = dt;
    notifyListeners();
  }

  void setDepartureLocation(String loc) {
    departureLocation = loc.toUpperCase(); // Always uppercase
    notifyListeners();
  }

  void setArrivalLocation(String loc) {
    arrivalLocation = loc.toUpperCase(); // Always uppercase
    notifyListeners();
  }

  void setUrl(String newUrl) {
    url = newUrl;
    notifyListeners();
  }

  void setPrice(double newPrice) {
    price = newPrice;
    notifyListeners();
  }

  void setPosition(Offset newPosition) {
    position = newPosition;
    notifyListeners();
  }

  void setTransportIconIndex(int index) {
    transportIconIndex = index;
    notifyListeners();
  }

  // Json formatting
  Map<String, dynamic> toJson() => {
    'id': id,
    'departureDatetime': departureDatetime.toIso8601String(),
    'arrivalDatetime': arrivalDatetime.toIso8601String(),
    'departureLocation': departureLocation,
    'arrivalLocation': arrivalLocation,
    'url': url,
    'price': price,
    'position': {'dx': position.dx, 'dy': position.dy},
    'cardType': cardType.name,
    'transportIconIndex': transportIconIndex,
  };

  // Deserialize from JSON (Map)
  factory CardProvider.fromJson(Map<String, dynamic> json) {
    return CardProvider(
      id: json['id'] as String,
      departureDatetime: DateTime.parse(json['departureDatetime']),
      arrivalDatetime: DateTime.parse(json['arrivalDatetime']),
      departureLocation: json['departureLocation'] ?? '',
      arrivalLocation: json['arrivalLocation'] ?? '',
      url: json['url'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      position: Offset(
        (json['position']?['dx'] ?? 0).toDouble(),
        (json['position']?['dy'] ?? 0).toDouble(),
      ),
      cardType: CardType.values.firstWhere(
        (e) => e.name == (json['cardType'] ?? 'blank'),
        orElse: () => CardType.blank,
      ),
      transportIconIndex: json['transportIconIndex'] ?? 0,
    );
  }

  // Computed properties
  Duration get flightDuration => arrivalDatetime.difference(departureDatetime);

  TimeOfDay get departureTime =>
      TimeOfDay(hour: departureDatetime.hour, minute: departureDatetime.minute);

  int get departureHour => departureDatetime.hour;

  int get departureMinute => departureDatetime.minute;

  TimeOfDay get arrivalTime =>
      TimeOfDay(hour: arrivalDatetime.hour, minute: arrivalDatetime.minute);

  int get arrivalHour => arrivalDatetime.hour;

  int get arrivalMinute => arrivalDatetime.minute;
}
