import 'package:flutter/material.dart';

Future<DateTime?> showDatePickerDialog({
  required BuildContext context,
  required DateTime initialDateTime,
}) async {
  return await showDatePicker(
    context: context,
    initialDate: initialDateTime,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
}
