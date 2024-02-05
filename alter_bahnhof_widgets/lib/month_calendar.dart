// import 'dart:io';
// import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:settings/settings.dart';
import 'package:settings/color_scheme.dart';
// import 'package:http/http.dart';
import 'package:model/calendar.dart';

class MonthCalendar extends StatelessWidget {
  DateTime month = DateTime.now();
  MonthCalendar({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 400,
      child: FutureBuilder<Map<String, dynamic>>(
          future: getCalendarBasics(month),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.blue, strokeWidth: 5));
            }
            if (snapshot.connectionState == ConnectionState.done) {
              List<DataColumn> header = [];
              List<DataRow> rows = [];
              List weekList = snapshot.data!['weekList'];

              header.add(const DataColumn(
                label: Text('KW'),
                numeric: true,
              ));

              for (int i = 0; i < settings['weekDays'].length; i++) {
                header.add(DataColumn(
                    label: Text(settings['weekDays'][i]), numeric: true));
              }
              List<DataCell> weekRow = [];
              Map<String, dynamic> dayData = {};
              int dayNo = 0;
              DateTime dayAsDateTime = DateTime.now();
              Color fontColor = Colors.black;
              Color background = Colors.white;
              FontWeight fontWeight = FontWeight.normal;

              for (var week in weekList) {
                weekRow = [];
                weekRow.add(DataCell(Text(
                  week['weekNo'].toString(),
                  style: const TextStyle(
                      fontFamily: 'Arvo',
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                      color: Colors.black),
                )));
                for (int day = 0; day < week['weekDays'].length; day++) {
                  dayData = week['weekDays'][day];

                  // Formatting table
                  //              background  font       font
                  //              color       color      style  hover
                  //  header      dark grey   black      normal KW: Kalenderwoche, weekday name
                  //  Mo-Sa       grey        black      bold   -
                  //  So          grey        black      bold   -
                  //  normal day  white       grey       normal -
                  //  today       white       blue       normal -
                  //  holiday     lightGrey   black      normal Name of holiday
                  //  booked      green       white      normal Name (requestedOn/confirmedOn): type \n comment
                  //  requested   lightGreen  white      normal Name (requestedOn): type \n comment
                  //  booked and
                  //  today       green       blue       normal <see booked>
                  //  requested
                  //  and today   lightGreen  blue       normal <see requested>
                  //  holiday and
                  //  booked      grey        green      normal Holidayname \n Name (requestedOn/confirmedOn): type \n comment
                  //  holiday and
                  //  requested   grey        lightgreen normal Holidayname Name (requestedOn): type \n comment
                  dayAsDateTime = DateTime.parse(dayData['date']);
                  dayNo = dayAsDateTime.day;
                  background = Colors.white;
                  fontWeight = FontWeight.normal;
                  fontColor = Colors.black;

                  // Today
                  if (dayAsDateTime.isAtSameMomentAs(DateTime.now())) {
                    background = Colors.white;
                    fontColor = Colors.blue;
                    fontWeight = FontWeight.normal;
                  }
                  // Booking status
                  if (dayData['bookingStatus'] == 'booked') {
                    background = colorScheme['primary'];
                    fontColor = Colors.white;
                    fontWeight = FontWeight.normal;
                  }

                  if (dayData['bookingStatus'] == 'requested') {
                    background = colorScheme['primaryLight'];
                    fontColor = Colors.white;
                    fontWeight = FontWeight.normal;
                  }
                  // Weekend
                  if (['Sa', 'So'].contains(dayData['weekDay'])) {
                    background = colorScheme['greyLight'];
                    fontColor = Colors.black;
                    fontWeight = FontWeight.normal;
                  }

                  weekRow.add(DataCell(Container(
                    color: background,
                    child: Text(
                      dayNo.toString(),
                      style: TextStyle(
                        fontFamily: "Arvo",
                        fontWeight: fontWeight,
                        fontSize: 20,
                        color: fontColor,
                      ),
                    ),
                  )));
                }
                rows.add(DataRow(cells: weekRow));
              }

              return DataTable(
                  columns: header,
                  rows: rows,
                  columnSpacing: 3,
                  dividerThickness: 1,
                  headingRowColor:
                      MaterialStatePropertyAll(colorScheme['primary']),
                  headingTextStyle: const TextStyle(
                      fontFamily: 'Arvo',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                  border: TableBorder.all(
                      color: colorScheme['greyLight'], width: 1));
            } else {
              return const Center(
                  child: Text('Something went wrong!',
                      style: TextStyle(
                          fontFamily: 'Arvo',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.red)));
            }
          }),
    );
  }
}
