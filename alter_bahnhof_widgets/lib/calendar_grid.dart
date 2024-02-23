import 'package:flutter/material.dart';
import 'package:alter_bahnhof_widgets/month_calendar.dart';

class CalendarGrid extends StatelessWidget {
  int columns = 2;
  String startMonth = '';
  int numberOfMonths = 6;
  Function(Map<String, dynamic>) callback;
  CalendarGrid(
      {super.key,
      this.columns = 2,
      this.startMonth = '',
      this.numberOfMonths = 12,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    int year = int.parse(startMonth.substring(0, 4));
    int month = int.parse(startMonth.substring(5, 7));
    return GridView.count(
      childAspectRatio: 1.8,
      crossAxisCount: columns,
      shrinkWrap: true,
      children: List.generate(
          numberOfMonths,
          (index) => MonthCalendar(
                month: DateTime(year, month + index, 1),
                managementView: true,
                callback: callback,
              )),
    );
  }
}
