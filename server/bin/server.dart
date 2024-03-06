import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:settings/settings.dart';

import 'src/bookings_api.dart';
import 'src/reserved_days_api.dart';
import 'src/users_api.dart';

Future main() async {
  const Map<String, String> corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
    // 'Access-Control-Allow-Headers': '*',
  };
  final Router alterBahnhof = Router();

  Response? _options(Request request) => (request.method == 'OPTIONS')
      ? Response.ok(null, headers: corsHeaders)
      : null;
  Response _cors(Response response) => response.change(headers: corsHeaders);
  final _fixCORS =
      createMiddleware(requestHandler: _options, responseHandler: _cors);

  alterBahnhof.get('/', (Request request) async {
    return Response.ok(
      'This is the REST Service of Alter Bahnhof',
      headers: {
        'Content-Type': 'application/json',
        ...corsHeaders,
      },
    );
  });

  // SecurityContext getSecurityContext() {
  //   // Bind with a secure HTTPS connection
  //   final chain = Platform.script
  //       .resolve('${settings['certicatePath']}/AlterBahnhofCert.pem')
  //       .toFilePath();
  //   final key = Platform.script
  //       .resolve('${settings['certicatePath']}/AlterBahnhofKey.pem')
  //       .toFilePath();

  //   return SecurityContext()
  //     ..useCertificateChain(chain)
  //     ..usePrivateKey(key, password: settings['alterBahnhofEncryptionKey']);
  // }

  Db db = Db('${settings['mongoDBServerURI']}/${settings['mongoDatabase']}');
  await db.open();
  DbCollection bookings = db.collection(settings['bookingsCollection']);
  DbCollection reservedDays = db.collection(settings['reservedDaysCollection']);
  DbCollection users = db.collection(settings['usersCollection']);
  // Uint8List certificateChain =
  //     await File('./certificates/AlterBahnhofCert.pem').readAsBytes();
  // String privateKey =
  //     await File('./certificates/AlterBahnhofKey.pem').readAsString();

  alterBahnhof.mount(
      '/bookings/', BookingsApi(bookingsCollection: bookings).router);
  alterBahnhof.mount('/reservedDays/',
      ReservedDaysApi(reservedDaysCollection: reservedDays).router);
  alterBahnhof.mount('/users/', UsersApi(usersCollection: users).router);

  // final handler = const Pipeline()
  //     .addMiddleware(_fixCORS)
  //     .addMiddleware(logRequests())
  //     .addHandler(alterBahnhof);

  alterBahnhof.all(
      '/<ignored|.*>',
      (Request request) => Response.ok(
          'This is the REST service of Alter Bahnhof (endpoint unknown)'));

  // final server = await HttpServer.bindSecure(InternetAddress.anyIPv4,
  //     settings['alterBahnhofPort'], getSecurityContext());
  // const Pipeline()
  //     .addMiddleware(logRequests())
  //     .addHandler(proxyHandler("http://")),
  // InternetAddress.anyIPv4,
  // 443,
  // securityContext: SecurityContext()
  //   ..useCertificateChainBytes(certificateChain)
  //   ..usePrivateKeyBytes(utf8.encode(privateKey)),
  // alterBahnhof,
  // settings['alterBahnhofHost'],
  // settings['alterBahnhofPort']);
  final handler = const Pipeline()
      .addMiddleware(_fixCORS)
      .addMiddleware(logRequests())
      .addHandler(alterBahnhof);

  ////////////////// THE UNKNOWN STUFF////////////////////
  alterBahnhof.all(
      '/<ignored|.*>',
      (Request request) =>
          Response.ok('This is the Alter Bahnhof API service'));

  final server = await io.serve(
      alterBahnhof, settings['alterBahnhofHost'], settings['alterBahnhofPort']);
  print(
      'Server listening on ${settings['alterBahnhofHost']}:${settings['alterBahnhofPort']}');
}
