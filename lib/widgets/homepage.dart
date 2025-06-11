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
  double _currentScale = 1.0; // initial scale

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size screenSize = MediaQuery.of(context).size;
      final double canvasWidth = screenSize.width * 4;
      final double canvasHeight = screenSize.height * 4;

      final double offsetX = (canvasWidth - screenSize.width) / -2;
      final double offsetY = (canvasHeight - screenSize.height) / -2;

      // _transformationController.value = Matrix4.identity()
      //   ..translateByDouble(offsetX, offsetY, 0.0, 0.0);
      _transformationController.value = Matrix4.identity()
        ..translate(offsetX, offsetY);

      _transformationController.addListener(() {
        final newScale = _transformationController.value
            .getMaxScaleOnAxis()
            .clamp(0.5, 2.0);
        if ((newScale - _currentScale).abs() > 0.001) {
          setState(() {
            _currentScale = newScale;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 2,
            constrained: false,
            child: Consumer<CardListProvider>(
              builder: (context, cardListProvider, _) {
                return Stack(
                  children: [
                    // Background
                    Positioned.fill(child: const BackgroundGridWidget()),
                    // Cards and Connections
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 4,
                      height: MediaQuery.of(context).size.height * 4,
                      child: Stack(
                        children: [
                          ...cardListProvider.connections.map(
                            (conn) => conn.buildConnection(),
                          ),
                          ...cardListProvider.buildAllCards(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Zoom Slider - Centered at bottom
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Card(
                color: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 300,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.zoom_out),
                        Expanded(
                          child: Slider(
                            value: _currentScale,
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            label: _currentScale.toStringAsFixed(2),
                            onChanged: (newScale) {
                              final screenSize = MediaQuery.of(context).size;
                              final centerScreen = Offset(
                                screenSize.width / 2,
                                screenSize.height / 2,
                              );
                              final sceneCenterBefore =
                                  _transformationController.toScene(
                                    centerScreen,
                                  );

                              setState(() {
                                _currentScale = newScale;
                                _transformationController
                                    .value = Matrix4.identity()
                                  ..translate(centerScreen.dx, centerScreen.dy)
                                  ..scale(newScale)
                                  ..translate(
                                    -sceneCenterBefore.dx,
                                    -sceneCenterBefore.dy,
                                  );
                              });
                            },
                          ),
                        ),
                        const Icon(Icons.zoom_in),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: HomePageFloatingActionButtons(
        transformationController: _transformationController,
      ),
    );
  }
}
