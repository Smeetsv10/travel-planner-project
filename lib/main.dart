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
        home: Homepage(),
      ),
    ),
  );
}
