import 'dart:io';

import 'package:model/user.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:settings/settings.dart';

void main(List<String> args) async {
  Map<String, dynamic> user;
  DbCollection userDb;
  Map<String, dynamic>? result;

  if (args.length != 4) {
    print('usage: add_user <user_id> <full name> <email address> <password>');
    exit(-1);
  }
  Db db = Db(settings['mongoDBServerURI'] + '/' + settings['mongoDatabase']);
  await db.open();
  userDb = db.collection(settings['usersCollection']);

  result = await userDb
      .findOne(where.eq('email', 'hallo@seminarhaus-im-bahnhof.de'));

  if (result == null) {
    user = {
      'userID': 'admin',
      'name': 'Administrator',
      'email': 'hallo@seminarhaus-im-bahnhof.de',
      'password': encryptString('admin')
    };
    userDb.insertOne(user);
    print('Initial "admin" record added!');
  }
  user = {
    'userID': args[0],
    'name': args[1],
    'email': args[2],
    'password': encryptString(args[3])
  };
  userDb.insertOne(user);
  print('User "${args[0]}" added!');

  exit(0);
}
