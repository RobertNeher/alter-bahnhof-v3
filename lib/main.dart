import 'package:alter_bahnhof_widgets/calendar_selector.dart';
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
      home: CalendarSelector(),
    );
  }
}
