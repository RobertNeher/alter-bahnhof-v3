import 'package:flutter/material.dart';
import 'package:alter_bahnhof_widgets/month_calendar.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: MonthCalendar(month: DateTime(2024, 1, 1)),
        ),
      ),
    );
  }
}
