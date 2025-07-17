import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_scheduler/classes/card_list_provider.dart';
import 'package:travel_scheduler/classes/card_provider.dart';
import 'package:travel_scheduler/widgets/clustor_button.dart';
import 'package:travel_scheduler/widgets/custom_action_button.dart';
import 'package:travel_scheduler/widgets/homepage.dart';
import 'package:travel_scheduler/classes/app_settings.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CardListProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppSettings.theme,
        home: Center(
          child: ClusterButton(
            backgroundColor: Colors.blue,
            children: [
              ClusterButton(
                axisDirection: AxisDirection.up,
                backgroundColor: Colors.purpleAccent,
                child: Icon(Icons.error),
                onPressed: () => print('Error button pressed'),
                children: [
                  ClusterButton(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.one_k),
                    onPressed: () => print('green button pressed'),
                    children: [],
                  ),
                  ClusterButton(
                    backgroundColor: Colors.greenAccent,
                    child: Icon(Icons.pool_sharp),
                    onPressed: () => print('pool button pressed'),
                    children: [],
                  ),
                ],
              ),

              ClusterButton(
                backgroundColor: Colors.purple,
                child: Icon(Icons.flight),
                onPressed: () => print('Flight button pressed'),
                children: [
                  ClusterButton(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.hotel),
                    onPressed: () => print('Accommodation button pressed'),
                    children: [],
                  ),
                  SizedBox(height: 30), // Spacing between buttons

                  ClusterButton(
                    backgroundColor: Colors.amber,
                    child: Icon(Icons.directions_car),
                    onPressed: () => print('Transportation button pressed'),
                    children: [],
                  ),
                ],
              ),
            ],
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ), //Homepage(),
      ),
    ),
  );
}
