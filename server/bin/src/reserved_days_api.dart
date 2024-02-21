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

    // .../check?yyyy-MM-dd&managementView=[Y|N]
    router.get('/check', (Request request) async {
      DateFormat df = DateFormat(settings['alterBahnhofDateFormat']);
      Map<String, dynamic> parameters = request.url.queryParameters;
      bool managementView = false;

      if (parameters['managementView'] ==
          null) if (parameters['managementView'] != null) {
        managementView =
            parameters['managementView'].toUpperCase().substring(0, 1) == 'Y';
      } else {
        managementView = false;
      }
      String day = parameters['day'];

      var result = await reservedDaysCollection.findOne(where
        ..eq('blockedDay',
            DateFormat(settings['alterBahnhofDateFormat']).parse(day)));
      return Response.ok(jsonEncode(result), headers: responseHeaders);
    });

    router.get('/<something|.*>', (Request request, String something) async {
      return Response.ok(
          jsonEncode('This is the Reserved Days service of Alter Bahnhof'),
          headers: responseHeaders);
    });
    return router;
  }
}
