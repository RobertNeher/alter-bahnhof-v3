import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:settings/settings.dart';
import 'package:settings/color_scheme.dart';
import 'package:settings/text_styles.dart';
import 'package:model/calendar.dart';
import 'package:utils/utils.dart';

class MonthCalendar extends StatelessWidget {
  final DateTime month;
  final bool managementView;
  final Function(Map<String, dynamic>) callback;
  const MonthCalendar(
      {super.key,
      required this.month,
      required this.managementView,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    // DateFormat df = DateFormat(settings['alterBahnhofDateFormat']);

    return Card(
        child: Container(
            child: FutureBuilder<Map<String, dynamic>>(
                future: getCalendarBasics(month, managementView),
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
                    weekNo.children.add(Container(
                        constraints:
                            BoxConstraints(maxWidth: settings['dayBoxWidth']),
                        margin: const EdgeInsets.all(1),
                        height: settings['dayBoxHeight'],
                        width: settings['dayBoxWidth'],
                        color: colorScheme['secondary'],
                        child: Tooltip(
                          message: 'Kalenderwoche',
                          child: Text('KW',
                              textAlign: TextAlign.center,
                              style: textStyles['calendarHeader']),
                        )));

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
                        color: colorScheme['secondary'],
                        child: Text(settings['weekDays'][i],
                            textAlign: TextAlign.center,
                            style: textStyles['calendarHeader']),
                      ));

                      // weekDay of week
                      // Formatting table
                      //              background  font       font
                      //              color       color      style  hover
                      //  header      secondary   white      bold   KW: Kalenderwoche, weekday name
                      //  normal day  white       grey       normal -
                      //  today       white       blue       normal -
                      //  reserved    lightRed    grey       normal 'Reserved'
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
                      //  "outside"
                      //  day         grey        darkGrey   normal -
                      for (int week = 0; week < weekList.length; week++) {
                        bool noCallback = false;
                        Map<String, dynamic> day =
                            weekList[week]['weekDays'][i];
                        Color fontColor = Colors.black;
                        double fontSize = 20;
                        FontWeight fontWeight = FontWeight.normal;
                        Color backgroundColor = colorScheme['none']!;
                        FontStyle fontStyle = FontStyle.normal;
                        String toolTip = '';
                        String dayText =
                            DateTime.parse(day['date']).day.toString();

                        if (DateTime.parse(day['date'])
                            .isBefore(DateTime.now())) {
                          Color fontColor = Color.fromARGB(255, 255, 54, 54);
                          double fontSize = 20;
                          FontWeight fontWeight = FontWeight.normal;
                          Color backgroundColor =
                              Color.fromARGB(255, 109, 97, 97);
                          FontStyle fontStyle = FontStyle.normal;
                        } else {
                          // booked state
                          if (day['bookingStatus'].contains('booked')) {
                            noCallback = true;
                            backgroundColor = colorScheme['primary']!;

                            if (isSameDay(
                                DateTime.now(), DateTime.parse(day['date']))) {
                              fontColor = Colors.blue;
                            } else {
                              fontColor = Colors.white;
                            }
                            toolTip = managementView
                                ? '${day["booking"]["firstName"]} ${day["booking"]["lastName"]}\n' +
                                    'Kontaktdaten (Mobil/E-Mail): ${day["booking"]["phone"]}/${day["booking"]["email"] ??= ''}\n' +
                                    'Angefragt am: ${DateFormat('dd. MMMM yyyy').format(DateTime.parse(day["booking"]["requestedOn"]))}\n' +
                                    'Bestätigt am: ' +
                                    (day["booking"]["confirmedOn"] != null
                                        ? dateFormatyyyy_MM_dd2ddMMMMyyyy(
                                            day["booking"]["confirmedOn"])
                                        : "unbestätigt") +
                                    '\n' +
                                    'Bemerkung:\n' +
                                    day["booking"]["comment"]
                                : '';
                          }

                          if (day['bookingStatus'].contains('requested')) {
                            noCallback = true;
                            backgroundColor = colorScheme['primaryLight']!;

                            toolTip = managementView
                                ? '${day["booking"]["firstName"]} ${day["booking"]["lastName"]}\n' +
                                    'Kontaktdaten (Mobil/E-Mail): ${day["booking"]["phone"]}/${day["booking"]["email"] ??= ''}\n' +
                                    'Angefragt am: ${DateFormat('dd. MMMM yyyy').format(DateTime.parse(day["booking"]["requestedOn"]))}\n' +
                                    'Bemerkung:\n' +
                                    day["booking"]["comment"]
                                : '';
                          }

                          if (day['holiday'].isNotEmpty) {
                            if (!day['bookingStatus'].contains('today')) {
                              backgroundColor = colorScheme['secondaryLight']!;
                              fontStyle = FontStyle.italic;
                              fontSize = 20;
                              fontWeight = FontWeight.normal;
                              toolTip = day['holiday'];
                            }
                          }
                        }
                        if (DateTime.parse(day['date']).month != month.month) {
                          backgroundColor =
                              const Color.fromARGB(255, 224, 224, 224);
                          fontColor = colorScheme['grey']!;
                          fontStyle = FontStyle.italic;
                        }

                        if (day['bookingStatus'].contains('today')) {
                          fontColor = Colors.blue;
                          toolTip = 'Heute' +
                              (toolTip.isNotEmpty ? '\n\n' + toolTip : '');
                        }

                        if (day['bookingStatus'].contains('reserved')) {
                          noCallback = true;
                          fontColor = Colors.black;
                          backgroundColor = colorScheme['redLight']!;
                          toolTip = 'Reserviert';
                        }

                        weekDays.last.children.add(InkWell(
                            onLongPress:
                                noCallback ? null : () => callback(day),
                            child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 0, 10, 0),
                                alignment: Alignment.centerRight,
                                margin: const EdgeInsets.all(1),
                                height: settings['dayBoxHeight'],
                                width: settings['dayBoxWidth'],
                                color: backgroundColor,
                                child: Tooltip(
                                    message: toolTip,
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(maxWidth: 250),
                                      child: Text(dayText,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              fontFamily: 'Arvo',
                                              fontWeight: fontWeight,
                                              fontStyle: fontStyle,
                                              fontSize: fontSize,
                                              color: fontColor)),
                                    )))));
                        backgroundColor = colorScheme['none']!;
                      }
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            height: 35,
                            width: 200,
                            color: colorScheme['secondary'],
                            child: Text(snapshot.data!['month'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontFamily: 'Arvo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.white))),
                        SizedBox(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: weekDays,
                        )),
                      ],
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
                })));
  }
}
