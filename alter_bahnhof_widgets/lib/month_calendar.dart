import 'package:flutter/material.dart';
import 'package:settings/settings.dart';
import 'package:settings/color_scheme.dart';
import 'package:settings/text_styles.dart';
import 'package:model/calendar.dart';
import 'package:utils/utils.dart';

class MonthCalendar extends StatelessWidget {
  DateTime month = DateTime.now();
  MonthCalendar({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 500,
        height: 300,
        child: FutureBuilder<Map<String, dynamic>>(
            future: getCalendarBasics(month),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.blue, strokeWidth: 5));
              } else if (snapshot.connectionState == ConnectionState.done) {
                List weekList = snapshot.data!['weekList'];
                List<Column> weekDays = <Column>[];
                weekDays.add(Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[],
                ));
                // week number column
                Column weekNo = Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[],
                );
                //    header weekNo
                // TextStyle weekNoStyle = textStyles['calendarHeader']!;
                // weekNoStyle.fontStyle = FontStyle.italic;
                weekNo.children.add(Container(
                  constraints:
                      BoxConstraints(maxWidth: settings['dayBoxWidth']),
                  margin: const EdgeInsets.all(1),
                  height: settings['dayBoxHeight'],
                  width: settings['dayBoxWidth'],
                  color: colorScheme['primary'],
                  child: Text('KW',
                      textAlign: TextAlign.center,
                      style: textStyles['calendarHeader']),
                ));

                //    weekNos
                for (int i = 0; i < weekList.length; i++) {
                  weekNo.children.add(Container(
                      constraints:
                          BoxConstraints(maxWidth: settings['dayBoxWidth']),
                      padding: const EdgeInsets.fromLTRB(5, 0, 15, 0),
                      margin: const EdgeInsets.all(1),
                      height: settings['dayBoxHeight'],
                      width: settings['dayBoxWidth'],
                      color: colorScheme['greySuperLight'],
                      child: Text(
                        weekList[i]['weekNo'].toString(),
                        textAlign: TextAlign.right,
                        style: textStyles['weekNo'],
                      )));
                }
                weekDays.add(weekNo);

                for (int i = 0; i < settings['weekDays'].length; i++) {
                  weekDays.add(Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[]));

                  // header
                  weekDays.last.children.add(Container(
                    constraints:
                        BoxConstraints(maxWidth: settings['dayBoxWidth']),
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    margin: const EdgeInsets.all(1),
                    height: settings['dayBoxHeight'],
                    width: settings['dayBoxWidth'],
                    color: colorScheme['primary'],
                    child: Text(settings['weekDays'][i],
                        textAlign: TextAlign.center,
                        style: textStyles['calendarHeader']),
                  ));

                  // weekDay of week
                  // Formatting table
                  //              background  font       font
                  //              color       color      style  hover
                  //  header      primary     white      normal KW: Kalenderwoche, weekday name
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
                  for (int week = 0; week < weekList.length; week++) {
                    Map<String, dynamic> day = weekList[week]['weekDays'][i];
                    Color fontColor = Colors.black;
                    FontWeight fontWeight = FontWeight.normal;
                    Color backgroundColor = Colors.white;

                    if (day['bookingStatus'] == 'booked') {
                      fontWeight = FontWeight.normal;
                      backgroundColor = colorScheme['primaryLight']!;

                      if (isSameDay(
                          DateTime.now(), DateTime.parse(day['date']))) {
                        fontColor = Colors.blue;
                      } else {
                        fontColor = Colors.white;
                      }
                    }

                    if (day['bookingStatus'] == 'requested') {
                      fontWeight = FontWeight.normal;
                      backgroundColor = colorScheme['primary']!;

                      if (isSameDay(
                          DateTime.now(), DateTime.parse(day['date']))) {
                        fontColor = Colors.blue;
                      } else {
                        fontColor = Colors.white;
                      }
                    }
                    weekDays.last.children.add(Container(
                      padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
                      alignment: Alignment.centerRight,
                      margin: const EdgeInsets.all(1),
                      height: settings['dayBoxHeight'],
                      width: settings['dayBoxWidth'],
                      color: backgroundColor,
                      child: Text(DateTime.parse(day['date']).day.toString(),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontFamily: 'Arvo',
                              fontWeight: fontWeight,
                              fontSize: 20,
                              color: fontColor)),
                    ));
                  }
                }
                return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.only(bottom: 3),
                        height: 40,
                        // width: 150,
                        color: Colors.black38,
                        child: Text(snapshot.data!['month'],
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontFamily: 'Arvo',
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.white)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: weekDays,
                      ),
                    ]);
              } else {
                return const Center(
                    child: Text('Something went wrong!',
                        style: TextStyle(
                            // fontFamily: 'Railway',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.red)));
              }
            }));
  }
}
