import 'package:flutter/material.dart';
import 'package:alter_bahnhof_widgets/month_calendar.dart';

void main() {
  runApp(const AlterBahnhofApp());
}

class AlterBahnhofApp extends StatelessWidget {
  const AlterBahnhofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: GridView.count(
          childAspectRatio: 1.8,
          crossAxisCount: 3,
          children: List.generate(
              12,
              (index) => MonthCalendar(
                    month: DateTime(2024, 1 + index, 1),
                    managementView: true,
                  )),
          shrinkWrap: true,
        )));
  }
}
