import 'package:flutter/material.dart';
import 'utility/category_route.dart';
import 'utility/timer.dart';
import 'package:flutter/cupertino.dart';

void main() {
  final timerService = TimerService();
  runApp(TimerServiceProvider(service: timerService, child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ACROB",
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.grey[600],
            ),
        // This colors the [InputOutlineBorder] when it is selected
        primaryColor: Colors.grey[500],
        textSelectionTheme:
            TextSelectionThemeData(selectionHandleColor: Colors.pink),
        // textSelectionHandleColor: Colors.pink,
      ),
      home: CategoryRoute(),
    );
  }
}
