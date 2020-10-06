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
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
