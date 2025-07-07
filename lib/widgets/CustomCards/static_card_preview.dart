import 'package:flutter/material.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/classes/app_settings.dart';

class StaticCardPreview extends StatelessWidget {
  final CardProvider cardProvider;
  const StaticCardPreview({super.key, required this.cardProvider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: cardProvider.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: AppSettings.cardWidth,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(width: 40, child: cardProvider.icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cardProvider.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (cardProvider.departureLocation.isNotEmpty)
              Text(
                'From: ${cardProvider.departureLocation}',
                style: const TextStyle(color: Colors.white70),
              ),
            if (cardProvider.arrivalLocation.isNotEmpty)
              Text(
                'To: ${cardProvider.arrivalLocation}',
                style: const TextStyle(color: Colors.white70),
              ),
            if (cardProvider.price > 0)
              Text(
                'Price: €${cardProvider.price}',
                style: const TextStyle(color: Colors.white70),
              ),
            if (cardProvider.url.isNotEmpty)
              Text(
                cardProvider.url,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
