import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:settings/settings.dart';

class ReservedDay {
  String _id = '';
  DateTime? _blockedDay;
  String _comment = '';

  ReservedDay({String id = '', DateTime? blockedDay, String comment = ''}) {
    _id = id;
    _blockedDay = blockedDay;
    _comment = comment;
  }

  ReservedDay.fromJson(Map<String, dynamic> json) {
    DateFormat df = DateFormat(settings['alterBahnhofDateFormat']);
    String id = json['id'].substring(10); // Extracting the id
    id = id.substring(0, id.length - 2);

    if (json['blockedDay'] != null) {
      _blockedDay = df.parse(json['blockedDay']);
    }
    _comment = json['comment'].toString();
  }

  Map<String, dynamic> toJson(ReservedDay day) {
    return {
      'id': day._id,
      'blockedDay': day._blockedDay,
      'comment': day._comment,
    };
  }

  @override
  String toString() {
    return 'Id: $_id,\nblockedDay: ${DateFormat(settings["alterBahnhofDateFormat"]).format(_blockedDay!)},\ncomment: $_comment';
  }
}

Future<List<ReservedDay>> fetchReservedDays(
    {String startDate = '',
    String endDate = '',
    bool managementView = false}) async {
  List<ReservedDay> reservedDays = [];
  Map<String, dynamic> params = {
    'startDate': startDate,
    'endDate': endDate,
    'managementView': managementView ? 'Y' : 'N',
  };

  Uri uri = Uri.http(
      '${settings['alterBahnhofHost']}:${settings['alterBahnhofPort']}',
      'reservedDays/all',
      params);
  http.Response response = await http.get(uri);

  if (response.statusCode == 200) {
    List daysRaw = jsonDecode(response.body);
    for (Map<String, dynamic> day in daysRaw) {
      reservedDays.add(ReservedDay.fromJson(day));
    }
    return reservedDays;
  }
  return [];
}
