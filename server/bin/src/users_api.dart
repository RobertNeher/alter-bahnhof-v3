import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UsersApi {
  DbCollection usersCollection;

  UsersApi({required DbCollection this.usersCollection});

  Router get router {
    const Map<String, String> responseHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
    };

    final router = Router();

    router.get('/size', (Request request) async {
      int size = await usersCollection.count();
      return Response.ok(jsonEncode({'size': size.toString()}),
          headers: responseHeaders);
    });
    router.get('/all', (Request request) async {
      List<Map<String, dynamic>> allUsers = [];

      await usersCollection.find().forEach((user) {
        allUsers.add({
          '_id': user['_id'].toString(),
          'userID': user['userID'],
          'name': user['name'],
          'email': user['eMail'],
          'password': '<disclosed>'
        });
      });

      return Response.ok(jsonEncode(allUsers), headers: responseHeaders);
    });

    router.get('/id=<id|[0-9A-Fa-f]+>', (Request request, String id) async {
      Map<String, dynamic> result = {};
      ObjectId oid = ObjectId.fromHexString(id);

      result = (await usersCollection.findOne({'_id': oid}))!;

      return Response.ok(jsonEncode(result), headers: responseHeaders);
    });

    router.get('/userID=<userID|[0-9A-Za-z]+>', (Request request) async {
      Map<String, dynamic> result = {};

      result = (await usersCollection
          .findOne({'userID': request.params['userID']}))!;

      return Response.ok(jsonEncode(result), headers: responseHeaders);
    });

    router.get('/<something|.*>', (Request request, String something) async {
      return Response.ok(
          jsonEncode('This is the Users service of Alter Bahnhof'),
          headers: responseHeaders);
    });

    ////////////////// POST //////////////////////
    router.post('/add=', (Request request) async {
      WriteResult result;
      final Map<String, dynamic> data =
          jsonDecode(await request.readAsString());
      result = await usersCollection.insertOne(data);

      return Response.ok(result.toString(), headers: responseHeaders);
    });

    ////////////////// PUT //////////////////////
    router.put('/', (Request request, String rawData) async {
      WriteResult? result;
      Map<String, dynamic> data = jsonDecode(rawData);
      final ObjectId oid = ObjectId.fromHexString(data['id']);

      result = await usersCollection.updateOne({'_id': oid}, data);

      return Response.ok(result.toString(), headers: responseHeaders);
    });

    ////////////////// DELETE //////////////////////
    router.delete('/<id|[0-9A-Fa-f]+>', (Request request, String id) async {
      WriteResult result;
      final ObjectId oid = ObjectId.fromHexString(id);

      result = await usersCollection.deleteOne({'_id': oid});

      return Response.ok('Entry with id "$id" has been deleted');
    });

    return router;
  }
}
