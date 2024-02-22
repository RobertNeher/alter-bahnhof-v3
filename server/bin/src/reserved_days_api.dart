import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:model/reserved_days.dart';
import 'package:settings/settings.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ReservedDaysApi {
  DbCollection reservedDaysCollection;

  ReservedDaysApi({required DbCollection this.reservedDaysCollection});

  Router get router {
    const Map<String, String> responseHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
    };

    final router = Router();

    router.get('/size', (Request request) async {
      int size = await reservedDaysCollection.count();
      return Response.ok(jsonEncode({'size': size.toString()}),
          headers: responseHeaders);
    });

    // .../all?startDate=yyyy-MM-dd&endDate=yyyy-MM-dd&managementView=[Y|N]
    router.get('/all', (Request request) async {
      DateFormat df = DateFormat(settings['alterBahnhofDateFormat']);
      Map<String, dynamic> parameters = request.url.queryParameters;
      bool managementView = false;

      // Default date: Starting month/year of Seminarhaus
      String start =
          parameters['startDate'] ?? settings['alterBahnhofStartDate'];
      String end = parameters['endDate'] ?? df.format(DateTime.now());

      if (parameters['managementView'] != null) {
        managementView =
            parameters['managementView'].toUpperCase().substring(0, 1) == 'Y';
      } else {
        managementView = false;
      }
      List<Map<String, dynamic>> allDates = [];
      await reservedDaysCollection
          .find(where
            ..gte('blockedDay',
                DateFormat(settings['alterBahnhofDateFormat']).parse(start))
            ..and(where.lte(
                'blockedDay',
                DateFormat(settings['alterBahnhofDateFormat'])
                    .parse(end)
                    .add(Duration(days: 1))))
            ..sortBy('blockedDay', descending: false))
          .forEach((day) {
        allDates.add({
          'id': day['_id'].toString(),
          'blockedDay': day['blockedDay'].toString(),
          'comment': managementView ? day['comment'] : '',
        });
      });

      return Response.ok(jsonEncode(allDates), headers: responseHeaders);
    });

    // .../check?day=yyyy-MM-dd
    router.get('/check', (Request request) async {
      DateFormat df = DateFormat(settings['alterBahnhofDateFormat']);
      Map<String, dynamic> parameters = request.url.queryParameters;

      String day = parameters['day'];

      var result = await reservedDaysCollection
          .find(where.gte('blockedDay', df.parse(day))
            ..and(
                where.lte('blockedDay', df.parse(day).add(Duration(days: 1)))))
          .toList();
      return Response.ok(
          jsonEncode(result.isNotEmpty ? result.length > 0 : false),
          headers: responseHeaders);
    });

    router.get('/<something|.*>', (Request request, String something) async {
      return Response.ok(
          jsonEncode('This is the Reserved Days service of Alter Bahnhof'),
          headers: responseHeaders);
    });
    return router;
  }
}
