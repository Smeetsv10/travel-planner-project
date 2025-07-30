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
  final double labelWidth;
  final DateTime? dateTime;
  final void Function(DateTime)? onDatePicked;
  final void Function(TimeOfDay)? onTimePicked;
  final BoxDecoration? borderDecoration;
  final TextStyle? labelStyle;
  final TextStyle? dateTimeStyle;
  final bool showDateField;
  final bool showTimeField;
  final bool showTextField;

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
    this.showDateField = false,
    this.showTimeField = false,
    this.showTextField = true,
    this.labelWidth = 75,
  });

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

    final border =
        borderDecoration ??
        BoxDecoration(
          border: Border.all(color: Colors.white38, width: 1),
          borderRadius: BorderRadius.circular(4),
        );
    final lbStyle = labelStyle ?? const TextStyle(color: Colors.white70);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Icon + Label compartment
          SizedBox(
            width: labelWidth,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (iconWidget != null) iconWidget!,
                if (iconWidget != null && label.isNotEmpty)
                  const SizedBox(width: 4),
                if (label.isNotEmpty)
                  Expanded(
                    child: Text(
                      label,
                      style: lbStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          // 2. Textbox compartment (expands)
          if (showTextField && controller != null && focusNode != null) ...[
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                scrollController: scrollController,
                onSubmitted: (value) {
                  onSubmitted?.call(value);
                },
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
                textInputAction: TextInputAction.next,
              ),
            ),
            SizedBox(width: 10),
          ] else
            const Expanded(child: SizedBox()),
          // 3. Optional date/time fields
          if (showDateField && dateTime != null) ...[
            CustomCardField_Date(
              dateTime: dateTime!,
              onDatePicked: onDatePicked,
              border: border,
              dateTimeStyle: dateTimeStyle,
            ),
            SizedBox(width: 10),
          ],
          if (showTimeField && dateTime != null) ...[
            CustomCardField_Time(
              dateTime: dateTime!,
              onTimePicked: onTimePicked,
              border: border,
              dateTimeStyle: dateTimeStyle,
            ),
            SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class CustomCardField_Date extends StatelessWidget {
  final DateTime dateTime;
  final void Function(DateTime)? onDatePicked;
  final BoxDecoration? border;
  final TextStyle? dateTimeStyle;

  const CustomCardField_Date({
    super.key,
    required this.dateTime,
    this.onDatePicked,
    this.border,
    this.dateTimeStyle,
  });

  String _formatDate(DateTime dt) =>
      "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";

  @override
  Widget build(BuildContext context) {
    final dtStyle =
        dateTimeStyle ?? const TextStyle(color: Colors.white54, fontSize: 14);

    return InkWell(
      onTap: () => _showDatePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white38, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(_formatDate(dateTime), style: dtStyle),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && onDatePicked != null) {
      onDatePicked!(picked);
    }
  }
}

class CustomCardField_Time extends StatelessWidget {
  final DateTime dateTime;
  final void Function(TimeOfDay)? onTimePicked;
  final BoxDecoration? border;
  final TextStyle? dateTimeStyle;

  const CustomCardField_Time({
    super.key,
    required this.dateTime,
    this.onTimePicked,
    this.border,
    this.dateTimeStyle,
  });

  String _formatTime(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final dtStyle =
        dateTimeStyle ?? const TextStyle(color: Colors.white54, fontSize: 14);

    return InkWell(
      onTap: () => _showTimePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white38, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(_formatTime(dateTime), style: dtStyle),
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dateTime),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && onTimePicked != null) {
      onTimePicked!(picked);
    }
  }
}
