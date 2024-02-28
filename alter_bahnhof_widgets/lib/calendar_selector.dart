import 'package:alter_bahnhof_widgets/legend.dart';
import 'package:flutter/material.dart';
import 'package:alter_bahnhof_widgets/calendar_grid.dart';
import 'package:intl/intl.dart';
import 'package:settings/color_scheme.dart' as scheme;
import 'package:settings/settings.dart';

class CalendarSelector extends StatefulWidget {
  @override
  State<CalendarSelector> createState() => _CalendarSelectorState();
}

class _CalendarSelectorState extends State<CalendarSelector> {
  _CalendarSelectorState();

  DateTime selectedMonth = DateTime.now();
  TextEditingController monthTextController =
      TextEditingController(text: 'Month YYYY');
  final DateTime actualMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  List<int> yearSpan = [];
  // int selectedYear = 2024;
  String monthYear = '';

  @override
  void initState() {
    selectedMonth = actualMonth;
    monthTextController.text =
        DateFormat(settings['alterBahnhofMonthDateFormat']).format(actualMonth);

    yearSpan = List.generate((settings['bookingYearSpan'] as int) + 1,
        (int index) => actualMonth.year + index,
        growable: true);
    // selectedYear = yearSpan.elementAt(0);
    monthYear = DateFormat(settings['alterBahnhofMonthDateFormat'])
        .format(selectedMonth);
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);

    monthTextController.text = monthYear;

    // print('$monthYear $selectedMonth');
  }

  @override
  void dispose() {
    super.dispose();
    monthTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double iconScale = 1.25;
    int selectedYear = yearSpan.elementAt(0);

    return MaterialApp(
        home: Scaffold(
            body: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      tooltip: 'Voriger Monat',
                      onPressed: () {
                        setState(() {
                          selectedMonth = DateTime(
                              selectedMonth.year, selectedMonth.month - 1, 1);
                          if (selectedMonth.isBefore(DateTime(
                              actualMonth.year, actualMonth.month, 0))) {
                            selectedMonth = actualMonth;
                          }
                        });
                      },
                      icon: Image.asset('images/arrow_left.png',
                          scale: iconScale)),
                  Container(
                    // width: 200,
                    color: scheme.colorScheme['primary'],
                    child: DropdownButton<int>(
                      value: selectedYear,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedYear = newValue!;
                          print(newValue);
                          selectedMonth =
                              DateTime(newValue, selectedMonth.month, 1);

                          if (selectedMonth.isAfter(DateTime(
                              actualMonth.year + (settings['bookingYearSpan'])
                                  as int,
                              actualMonth.month,
                              0))) {
                            selectedMonth = actualMonth;
                          }

                          monthYear = DateFormat(
                                  settings['alterBahnhofMonthDateFormat'])
                              .format(selectedMonth);
                          monthTextController.text = monthYear;
                        });
                      },
                      items: yearSpan.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Container(
                              color: scheme.colorScheme['primary'],
                              child: Text(
                                  '${DateFormat(" MMMM").format(selectedMonth)} $value',
                                  style: const TextStyle(
                                    fontFamily: "Arvo",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.white,
                                  ))),
                        );
                      }).toList(),
                    ),
                  ),
                  IconButton(
                      tooltip: 'Nächster Monat',
                      onPressed: () {
                        setState(() {
                          selectedMonth = DateTime(
                              selectedMonth.year, selectedMonth.month + 1, 1);
                          print(
                              '$selectedMonth: ${DateTime(actualMonth.year + (settings['bookingYearSpan']) as int, actualMonth.month, 0)}');
                          if (selectedMonth.isAfter(DateTime(
                              actualMonth.year + (settings['bookingYearSpan'])
                                  as int,
                              actualMonth.month,
                              0))) {
                            print(
                                'Yep:${DateTime(actualMonth.year + (settings['bookingYearSpan']) as int, actualMonth.month, 0)}');
                            selectedMonth = DateTime(
                                actualMonth.year + (settings['bookingYearSpan'])
                                    as int,
                                actualMonth.month,
                                1);
                          }
                        });
                      },
                      icon: Image.asset('images/arrow_right.png',
                          scale: iconScale)),
                ]),
            bottomSheet: SizedBox(
                height: 30,
                width: 500,
                child: Legend(
                  horizontal: true,
                ))));
  }
}
