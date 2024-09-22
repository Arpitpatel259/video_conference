import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'ui/Services/Functions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final Functions authMethods = Functions();
  Widget homeWidget = await authMethods.checkIfAlreadyLogin();
  runApp(MyApp(homeWidget: homeWidget));
}

class MyApp extends StatelessWidget {
  final Widget homeWidget;

  const MyApp({super.key, required this.homeWidget});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swan Pair',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: homeWidget,
    );
  }
}
