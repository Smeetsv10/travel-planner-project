import 'package:flutter/material.dart';

Future<TimeOfDay?> showTimePickerDialog({
  required BuildContext context,
  required DateTime initialDateTime,
}) async {
  final initialTime = TimeOfDay(
    hour: initialDateTime.hour,
    minute: initialDateTime.minute,
  );

  return await showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      );
    },
    initialEntryMode: TimePickerEntryMode.dial,
  );
}
