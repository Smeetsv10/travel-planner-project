import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_scheduler/classes/card_list_provider.dart';
import 'package:travel_scheduler/widgets/background_widget.dart';

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
          const BackgroundGridWidget(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                ...cardChains.map(
                  (chain) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var cardProvider in chain)
                          cardListProvider.buildCardFromProvider(
                            cardProvider.copyWith(
                              fromNodeKey: null,
                              toNodeKey: null,
                              // add any other interactive fields you want to nullify
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (cardChains.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No chains found.',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
