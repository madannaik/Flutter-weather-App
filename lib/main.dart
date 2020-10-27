import 'package:animated_splash/animated_splash.dart';
import 'package:flutter/material.dart';

import 'widgets/body.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(canvasColor: Colors.transparent),
      home: AnimatedSplash(
        imagePath: 'images/icons.jpg',
        home: MyHomePage(),
        duration: 3000,
        type: AnimatedSplashType.StaticDuration,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
