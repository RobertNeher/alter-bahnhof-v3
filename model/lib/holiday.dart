import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:settings/settings.dart';

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
        'date': df.parse(holiday['startDate'], true),
        'name': holiday['name'][0]['text']
      });
    }
  }
  return holidays;
}
