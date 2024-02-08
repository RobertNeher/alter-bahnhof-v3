import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:settings/settings.dart';

Future<Map<String, dynamic>> getCalendarBasics(DateTime month) async {
  http.Response response;
  // Getting event bookings first
  Uri uri = Uri.http(
      '${settings["alterBahnhofHost"]}:${settings["alterBahnhofPort"]}',
      '/bookings/daysOfMonth', {
    'month': DateFormat(settings['alterBahnhofDateFormat']).format(month),
  });

  response = await http
      .get(uri, headers: {HttpHeaders.acceptHeader: 'application/json'});

  if (response.statusCode == 200) {
    return json.decode(response.body) as Map<String, dynamic>;
  }
  return {};
}
