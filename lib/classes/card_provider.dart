import 'package:flutter/material.dart';
import 'package:travel_scheduler/classes/functions.dart';
import 'package:uuid/uuid.dart';

enum CardType { blank, flight, accommodation, transportation }

class CardProvider extends ChangeNotifier {
  final String id;
  final CardType cardType;
  final GlobalKey? fromNodeKey;
  final GlobalKey? toNodeKey;
  final bool isInteractive;

  String title;
  Offset position;
  Widget icon;
  DateTime? departureDatetime;
  DateTime? arrivalDatetime;
  String departureLocation;
  String arrivalLocation;
  String url;
  double price;
  Color color;
  Color borderColor;
  int? transportIconIndex;
  CardProvider({
    String? id,
    CardType? cardType,
    GlobalKey? fromNodeKey,
    GlobalKey? toNodeKey,
    Offset? position,

    DateTime? departureDatetime,
    DateTime? arrivalDatetime,
    String? title,
    String? departureLocation,
    String? arrivalLocation,
    String? url,
    double? price,
    Color? color,
    Color? borderColor,
    int? transportIconIndex,
    bool? isInteractive,
  }) : cardType = cardType ?? CardType.blank,
       id = id ?? const Uuid().v4(),
       fromNodeKey = fromNodeKey ?? GlobalKey(),
       toNodeKey = toNodeKey ?? GlobalKey(),
       position = position ?? Offset.zero,
       departureDatetime =
           departureDatetime ??
           (cardType == CardType.flight
               ? DateTime(
                   DateTime.now().year,
                   DateTime.now().month,
                   DateTime.now().day,
                   12,
                   0,
                 )
               : cardType == CardType.accommodation
               ? DateTime(
                   DateTime.now().year,
                   DateTime.now().month,
                   DateTime.now().day,
                   14,
                   0,
                 )
               : null),
       arrivalDatetime =
           arrivalDatetime ??
           (cardType == CardType.flight
               ? DateTime(
                   DateTime.now().year,
                   DateTime.now().month,
                   DateTime.now().day,
                   12,
                   0,
                 )
               : cardType == CardType.accommodation
               ? DateTime(
                   DateTime.now().year,
                   DateTime.now().month,
                   DateTime.now().day,
                   10,
                   0,
                 )
               : null),
       departureLocation = departureLocation ?? '',
       arrivalLocation = arrivalLocation ?? '',
       url = url ?? '',
       transportIconIndex = transportIconIndex ?? 0,
       isInteractive = isInteractive ?? true,
       price = price ?? 0.0,
       icon = _getIcon(cardType ?? CardType.blank),
       title = title ?? _getTitle(cardType ?? CardType.blank),
       color = color ?? _getColor(cardType ?? CardType.blank),
       borderColor = borderColor ?? Colors.white;

  // Dependent properties
  static Widget _getIcon(CardType type) {
    switch (type) {
      case CardType.blank:
        return blankIcon();
      case CardType.flight:
        return flightIcon();
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
      case CardType.flight:
        return 'Flight';
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
      case CardType.flight:
        return const Color.fromRGBO(33, 150, 243, 0.9); // Bright Blue
      case CardType.accommodation:
        return const Color.fromARGB(230, 221, 70, 24); // Red-Orange
      case CardType.transportation:
        return const Color.fromRGBO(46, 125, 50, 0.9); // Forest Green
    }
  }

  CardProvider copyWith({
    String? id,
    CardType? cardType,
    Offset? position,
    Widget? icon,
    DateTime? departureDatetime,
    DateTime? arrivalDatetime,
    String? title,
    String? departureLocation,
    String? arrivalLocation,
    String? url,
    double? price,
    Color? color,
    int? transportIconIndex,
    GlobalKey? fromNodeKey,
    GlobalKey? toNodeKey,
    bool? isInteractive,
  }) {
    return CardProvider(
      id: id ?? this.id,
      cardType: cardType ?? this.cardType,
      position: position ?? this.position,
      departureDatetime: departureDatetime ?? this.departureDatetime,
      arrivalDatetime: arrivalDatetime ?? this.arrivalDatetime,
      title: title ?? this.title,
      departureLocation: departureLocation ?? this.departureLocation,
      arrivalLocation: arrivalLocation ?? this.arrivalLocation,
      url: url ?? this.url,
      price: price ?? this.price,
      color: color ?? this.color,
      transportIconIndex: transportIconIndex ?? this.transportIconIndex,
      fromNodeKey: fromNodeKey,
      toNodeKey: toNodeKey,
      isInteractive: isInteractive ?? this.isInteractive,
    );
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
      departureDatetime?.hour ?? 0,
      departureDatetime?.minute ?? 0,
    );
    notifyListeners();
  }

  void setDepartureTime(TimeOfDay time) {
    departureDatetime = DateTime(
      departureDatetime?.year ?? 0,
      departureDatetime?.month ?? 0,
      departureDatetime?.day ?? 0,
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
      arrivalDatetime?.hour ?? 0,
      arrivalDatetime?.minute ?? 0,
    );
    notifyListeners();
  }

  void setArrivalTime(TimeOfDay time) {
    arrivalDatetime = DateTime(
      arrivalDatetime?.year ?? 0,
      arrivalDatetime?.month ?? 0,
      arrivalDatetime?.day ?? 0,
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
    'departureDatetime': departureDatetime?.toIso8601String(),
    'arrivalDatetime': arrivalDatetime?.toIso8601String(),
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
  Duration get flightDuration =>
      arrivalDatetime?.difference(departureDatetime ?? DateTime.now()) ??
      Duration.zero;

  TimeOfDay get departureTime => TimeOfDay(
    hour: departureDatetime?.hour ?? 0,
    minute: departureDatetime?.minute ?? 0,
  );

  int get departureHour => departureDatetime?.hour ?? 0;

  int get departureMinute => departureDatetime?.minute ?? 0;

  TimeOfDay get arrivalTime => TimeOfDay(
    hour: arrivalDatetime?.hour ?? 0,
    minute: arrivalDatetime?.minute ?? 0,
  );

  int get arrivalHour => arrivalDatetime?.hour ?? 0;

  int get arrivalMinute => arrivalDatetime?.minute ?? 0;
}
