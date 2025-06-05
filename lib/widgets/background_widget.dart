import 'package:flutter/material.dart';

class BackgroundGridWidget extends StatelessWidget {
  const BackgroundGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double interval = screenSize.width / 10;

    return SizedBox(
      height: screenSize.height,
      width: screenSize.width,
      child: GridPaper(
        color: const Color.fromARGB(100, 243, 243, 243),
        divisions: 1,
        interval: interval,
        subdivisions: 8,
      ),
    );
  }
}
