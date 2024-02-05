import 'package:flutter/material.dart';
import 'package:settings/settings.dart';
import 'package:settings/color_scheme.dart';
import 'package:settings/text_styles.dart';
import 'package:model/calendar.dart';

class MonthCalendar extends StatelessWidget {
  DateTime month = DateTime.now();
  MonthCalendar({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 200,
      child: FutureBuilder<Map<String, dynamic>>(
          future: getCalendarBasics(month),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.blue, strokeWidth: 5));
            }
            if (snapshot.connectionState == ConnectionState.done) {
              List weekList = snapshot.data!['weekList'];
              Row header = Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[]);
              List<Row> weekRows = [];

              header.children.add(Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                height: settings['dayBoxHeight'],
                width: settings['dayBoyWidth'],
                color: colorScheme['primary'],
                child: Text('KW',
                    textAlign: TextAlign.center,
                    style: textStyles['calendarHeader']),
              ));

              for (int i = 0; i < settings['weekDays'].length; i++) {
                header.children.add(Container(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  height: settings['dayBoxHeight'],
                  width: settings['dayBoyWidth'],
                  color: colorScheme['primary'],
                  child: Text(settings['weekDays'][i],
                      textAlign: TextAlign.center,
                      style: textStyles['calendarHeader']),
                ));
              }
              weekRows.add(header);

              Map<String, dynamic> dayData = {};
              int dayNo = 0;
              DateTime dayAsDateTime = DateTime.now();
              Color fontColor = Colors.black;
              Color background = Colors.white;
              FontWeight fontWeight = FontWeight.normal;

              for (var week in weekList) {
                Row weekRow = Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[]);
                weekRow.children.add(Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    height: settings['dayBoxHeight'],
                    width: settings['dayBoyWidth'],
                    color: colorScheme['greySuperLight'],
                    child: Text(
                      week['weekNo'].toString(),
                      textAlign: TextAlign.center,
                      style: textStyles['weekNo'],
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
                    background = colorScheme['primary']!;
                    fontColor = Colors.white;
                    fontWeight = FontWeight.normal;
                  }

                  if (dayData['bookingStatus'] == 'requested') {
                    background = colorScheme['primaryLight']!;
                    fontColor = Colors.white;
                    fontWeight = FontWeight.normal;
                  }
                  // Weekend
                  if (['Sa', 'So'].contains(dayData['weekDay'])) {
                    background = colorScheme['greyLight']!;
                    fontColor = Colors.black;
                    fontWeight = FontWeight.normal;
                  }

                  weekRow.children.add(Container(
                    padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
                    height: settings['dayBoxHeight'],
                    width: settings['dayBoyWidth'],
                    color: background,
                    child: Text(
                      dayNo.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Arvo",
                        fontWeight: fontWeight,
                        fontSize: 20,
                        color: fontColor,
                      ),
                    ),
                  ));
                }
                weekRows.add(weekRow);
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: weekRows,
              );
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
