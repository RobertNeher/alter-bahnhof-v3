import 'dart:convert';

import 'package:intl/intl.dart';
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
