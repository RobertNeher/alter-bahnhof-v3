import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:intl/intl.dart';
import 'package:settings/settings.dart';
import 'package:http/http.dart' as http;

dynamic alterBahnhofEncode(dynamic item) {
  if (item is DateTime) {
    return item.toIso8601String();
  }
  if (item is ObjectId) {
    return item.toString();
  }
  return item;
}

int isoWeekNumber(DateTime date) {
  int daysToAdd = DateTime.thursday - date.weekday;
  DateTime thursdayDate = daysToAdd > 0
      ? date.add(Duration(days: daysToAdd))
      : date.subtract(Duration(days: daysToAdd.abs()));
  int dayOfYearThursday = dayOfYear(thursdayDate);
  return 1 + ((dayOfYearThursday - 1) / 7).floor();
}

int dayOfYear(DateTime date) {
  return date.difference(DateTime(date.year, 1, 1)).inDays;
}

String getWeekday(DateTime date) {
  // TODO: Add locale!
  String weekday = DateFormat('E').format(date).substring(0, 2);
  // TODO Remove stuff below and add
  // return DateFormat('E', 'de_DE').format(date)
  // instead
  if (weekday == 'Mo') {
    return 'Mo';
  }
  if (weekday == 'Tu') {
    return 'Di';
  }
  if (weekday == 'We') {
    return 'Mi';
  }
  if (weekday == 'Th') {
    return 'Do';
  }
  if (weekday == 'Fr') {
    return 'Fr';
  }
  if (weekday == 'Sa') {
    return 'Sa';
  }
  if (weekday == 'Su') {
    return 'So';
  }
  return '';
}

Future<List<Map<String, dynamic>>> getHolidays(month) async {
  DateFormat df = DateFormat(settings['alterBahnhofDateFormat']);
  List<Map<String, dynamic>> holidays = [];
  DateTime firstDay = DateTime(month.year, month.month, 1);
  DateTime lastDay = DateTime(month.year, month.month + 1, 0);

  Uri uri = Uri.https('openholidaysapi.org', 'PublicHolidays', {
    'countryIsoCode': 'DE',
    'languageIsoCode': 'DE',
    'subdivisionCode': 'DE-BW',
    'validFrom': df.format(firstDay),
    'validTo': df.format(lastDay),
  });

  http.Response response = await http.get(uri,
      headers: {HttpHeaders.acceptEncodingHeader: 'application/json'});
  List holidayList = json.decode(response.body);

  if (response.statusCode == 200) {
    for (var holiday in holidayList) {
      holidays.add({
        'date': df.parse(holiday['startDate']),
        'name': holiday['name'][0]['text']
      });
    }
  }
  return holidays;
}
