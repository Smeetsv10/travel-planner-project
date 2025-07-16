import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_scheduler/classes/card_list_provider.dart';

class CardChainsPage extends StatelessWidget {
  const CardChainsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cardChains = context.read<CardListProvider>().cardChainList;
    final cardListProvider = context.read<CardListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Card Chains'),
        backgroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          // const BackgroundGridWidget(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < cardChains.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 60,
                              child: Align(
                                alignment: Alignment.center,
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    'Option ${i + 1}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            for (var cardProvider in cardChains[i])
                              cardListProvider.buildCardFromProvider(
                                cardProvider.copyWith(
                                  fromNodeKey: null,
                                  toNodeKey: null,
                                  isInteractive: false,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (i != cardChains.length - 1)
                      const Divider(
                        color: Colors.white24,
                        thickness: 1,
                        height: 24,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
