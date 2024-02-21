import 'package:alter_bahnhof_widgets/month_calendar.dart';
import 'package:flutter/material.dart';
import 'package:alter_bahnhof_widgets/calendar_grid.dart';

void main() {
  runApp(const AlterBahnhofApp());
}

VoidCallback? Function() onDayClicked() {
  print("Click");
  return () {};
}

class AlterBahnhofApp extends StatelessWidget {
  const AlterBahnhofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CalendarGrid(
          columns: 2,
          numberOfMonths: 4,
          startMonth: '2024-03-01',
          callback: onDayClicked,
        ));
  }
}
