import 'package:flutter/material.dart';
import 'package:alter_bahnhof_widgets/calendar_grid.dart';

void main() {
  runApp(const AlterBahnhofApp());
}

Function(Map<String, dynamic>) onDayClicked(data) {
  print("Click: $data");
  return ((p0) => {});
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
          startMonth: '2024-02-01',
          callback: (Map) => onDayClicked(Map),
        ));
  }
}
