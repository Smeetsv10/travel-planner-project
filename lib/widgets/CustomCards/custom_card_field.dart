import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomCardField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget? iconWidget;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onSubmitted;
  final ScrollController? scrollController;

  // Date/time support
  final DateTime? dateTime;
  final void Function(DateTime)? onDatePicked;
  final void Function(TimeOfDay)? onTimePicked;
  final BoxDecoration? borderDecoration;
  final TextStyle? labelStyle;
  final TextStyle? dateTimeStyle;

  const CustomCardField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.iconWidget,
    this.keyboardType,
    this.inputFormatters,
    this.onSubmitted,
    this.scrollController,
    this.dateTime,
    this.onDatePicked,
    this.onTimePicked,
    this.borderDecoration,
    this.labelStyle,
    this.dateTimeStyle,
  });

  String _formatDate(DateTime dt) =>
      "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
  String _formatTime(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}"; // 24-hour format

  @override
  Widget build(BuildContext context) {
    if (controller != null && focusNode != null) {
      focusNode!.addListener(() {
        if (focusNode!.hasFocus) {
          controller!.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller!.text.length,
          );
        }
      });
    }

    final bool isDateTimeField =
        dateTime != null && onDatePicked != null && onTimePicked != null;
    final _border =
        borderDecoration ??
        BoxDecoration(
          border: Border.all(color: Colors.white38, width: 1),
          borderRadius: BorderRadius.circular(4),
        );
    final _label = labelStyle ?? const TextStyle(color: Colors.white70);
    final _dtStyle =
        dateTimeStyle ?? const TextStyle(color: Colors.white54, fontSize: 14);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      width: 303,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (iconWidget != null) ...[iconWidget!, const SizedBox(width: 8)],
          SizedBox(width: 40, child: Text(label, style: _label)),
          const SizedBox(width: 5),
          if (controller != null && focusNode != null) ...[
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                scrollController: scrollController,
                onSubmitted: onSubmitted,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.left,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
              ),
            ),
          ],
          if (isDateTimeField && dateTime != null) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: dateTime!,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) onDatePicked!(picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: _border,
                child: Text(_formatDate(dateTime!), style: _dtStyle),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(dateTime!),
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                );
                if (picked != null) onTimePicked!(picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: _border,
                child: Text(_formatTime(dateTime!), style: _dtStyle),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
