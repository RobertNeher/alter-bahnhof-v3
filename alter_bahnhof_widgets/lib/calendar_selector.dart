import 'package:alter_bahnhof_widgets/legend.dart';
import 'package:alter_bahnhof_widgets/month_calendar.dart';
import 'package:flutter/material.dart';
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
  TextEditingController monthTextController = TextEditingController();
  final DateTime actualMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  List<int> yearSpan = [];
  int selectedYear = 0;

  @override
  void initState() {
    selectedMonth = actualMonth;
    monthTextController.text = DateFormat('MMMM').format(actualMonth);

    yearSpan = List.generate((settings['bookingYearSpan'] as int) + 1,
        (int index) => actualMonth.year + index,
        growable: false);
    selectedYear = yearSpan.elementAt(0);
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);

    monthTextController.text = DateFormat('MMMM').format(selectedMonth);
  }

  @override
  void dispose() {
    super.dispose();
    monthTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double iconScale = 1.25;

    return MaterialApp(
        home: Scaffold(
            appBar: PreferredSize(
                preferredSize:
                    const Size.fromHeight(50.0), // here the desired height
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          tooltip: 'Voriger Monat',
                          onPressed: () {
                            setState(() {
                              selectedMonth = DateTime(selectedMonth.year,
                                  selectedMonth.month - 1, 1);

                              if (selectedMonth.isBefore(DateTime(
                                  actualMonth.year, actualMonth.month, 0))) {
                                selectedMonth = actualMonth;
                              } else {
                                if (selectedMonth.month == 12) {
                                  selectedYear--;
                                }
                              }

                              monthTextController.text =
                                  DateFormat('MMMM').format(selectedMonth);
                            });
                          },
                          icon: Image.asset('images/arrow_left.png',
                              scale: iconScale)),
                      Row(children: [
                        Container(
                          height: 30,
                          width: 175,
                          color: scheme.colorScheme['primary'],
                          child: TextField(
                              controller: monthTextController,
                              readOnly: true,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: "Arvo",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.white)),
                        ),
                        DropdownButton<int>(
                          isDense: false,
                          isExpanded: false,
                          underline: const SizedBox(),
                          elevation: 0,
                          value: selectedYear,
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedMonth =
                                  DateTime(newValue!, selectedMonth.month, 1);

                              if (selectedMonth.isAfter(DateTime(
                                  actualMonth.year +
                                      (settings['bookingYearSpan']) as int,
                                  actualMonth.month,
                                  0))) {
                                selectedMonth =
                                    DateTime(newValue, selectedMonth.month, 1);
                              }
                              selectedYear = selectedMonth.year;
                            });
                          },
                          items:
                              yearSpan.map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Container(
                                  width: 60,
                                  // padding: const EdgeInsets.all(0),
                                  height: 30,
                                  color: scheme.colorScheme['primary'],
                                  child: Text(value.toString(),
                                      style: const TextStyle(
                                        fontFamily: "Arvo",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: Colors.white,
                                      ))),
                            );
                          }).toList(),
                        ),
                      ]),
                      IconButton(
                          tooltip: 'Nächster Monat',
                          onPressed: () {
                            setState(() {
                              selectedMonth = DateTime(selectedMonth.year,
                                  selectedMonth.month + 1, 1);

                              if (selectedMonth.isAfter(DateTime(
                                  actualMonth.year +
                                      (settings['bookingYearSpan']) as int,
                                  actualMonth.month,
                                  0))) {
                                selectedMonth = DateTime(
                                    actualMonth.year +
                                        (settings['bookingYearSpan']) as int,
                                    actualMonth.month,
                                    1);
                              } else {
                                if (selectedMonth.month == 1) {
                                  selectedYear++;
                                }
                              }
                              monthTextController.text =
                                  DateFormat('MMMM').format(selectedMonth);
                            });
                          },
                          icon: Image.asset('images/arrow_right.png',
                              scale: iconScale)),
                    ])),
            bottomSheet: SizedBox(
                height: 30,
                width: 500,
                child: Legend(
                  horizontal: true,
                )),
            body: Center(
                child: MonthCalendar(
              callback: onDayClicked,
              managementView: true,
              month: selectedMonth,
            ))));
  }
}

Function(Map<String, dynamic>) onDayClicked(data) {
  print("Click: $data");
  return ((p0) => {});
}
