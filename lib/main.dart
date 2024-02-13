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
            body: MonthCalendar(
          month: DateTime(2024, 2, 1),
          managementView: false,
        )));

    // GridView.count(
    //     crossAxisCount: 3,
    //     children: List.generate(
    //         1,
    //         (index) => MonthCalendar(
    //             month: DateTime(
    //                 2024, DateTime.now().month + index, 1),
    //               managementView: false,
    //             )))));
  }
}
