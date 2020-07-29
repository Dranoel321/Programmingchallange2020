import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mainscreen.dart';

void main() {
  /***************************************************************************** 
   * This set of commands forces the application to be run in portrait mode,
   * after ensuring this the application is rendered.
  *************************************************************************** */
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((__) {
    runApp(MaterialApp(
      home: Scaffold(body: MainScreen()),
      debugShowCheckedModeBanner: false,
    ));
  });
  /************************************************************************** */
}
