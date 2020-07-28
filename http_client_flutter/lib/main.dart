import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mainscreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((__) {
    runApp(MaterialApp(
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    ));
  });
}
