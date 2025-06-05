import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_scheduler/classes/card_list_provider.dart';
import 'package:travel_scheduler/widgets/background_widget.dart';
import 'package:travel_scheduler/widgets/homepage_floatingactionbuttons.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TransformationController _transformationController =
      TransformationController();
  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 10,
        constrained: true,
        child: Consumer<CardListProvider>(
          builder: (context, cardListProvider, _) {
            return Stack(
              children: [
                const BackgroundGridWidget(),
                ...cardListProvider.buildAllCards(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: HomePageFloatingActionButtons(
        transformationController: _transformationController,
      ),
    );
  }
}
