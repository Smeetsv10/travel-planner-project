import 'package:flutter/material.dart';
import 'package:travel_scheduler/widgets/CustomCards/custom_card_field.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomCardUrlField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String)? onSubmitted;
  final ScrollController? scrollController;

  const CustomCardUrlField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onSubmitted,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCardField(
      label: "Url",
      iconWidget: InkWell(
        onTap: () async {
          final urlText = controller.text.trim();
          if (urlText.isNotEmpty) {
            final uri = Uri.tryParse(urlText);
            if (uri != null && await canLaunchUrl(uri)) {
              if (!context.mounted) return;
              await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
            } else {
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Invalid URL')));
            }
          }
        },
        child: const Icon(Icons.link, color: Colors.white),
      ),
      controller: controller,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      scrollController: scrollController,
    );
  }
}
