import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

String formatDate(DateTime dt) => DateFormat('dd-MMM-yyyy').format(dt);
String formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

Widget blankIcon() {
  return const Icon(Icons.note_add, color: Colors.white);
}

Widget flightIcon() {
  return const Icon(Icons.flight, color: Colors.white);
}

Widget outgoingFlightIcon() {
  return const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      RotatedBox(quarterTurns: 2, child: Icon(Icons.air, color: Colors.white)),
      RotatedBox(
        quarterTurns: 1,
        child: Icon(Icons.flight, color: Colors.white),
      ),
    ],
  );
}

Widget returnFlightIcon() {
  return const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      RotatedBox(
        quarterTurns: 3,
        child: Icon(Icons.flight, color: Colors.white),
      ),
      Icon(Icons.air, color: Colors.white),
    ],
  );
}

Widget accomodationIcon() {
  return const Icon(Icons.house, color: Colors.white);
}

Widget transportationIcon() {
  return const Icon(Icons.map_rounded, color: Colors.white);
}
