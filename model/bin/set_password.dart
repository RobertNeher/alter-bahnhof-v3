import 'dart:io';

import 'package:model/user.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:settings/settings.dart';

void main(List<String> args) async {
  DbCollection userDb;
  Map<String, dynamic>? result;

  if (args.length != 2) {
    print('usage: set_password <user_id> <password>');
    exit(-1);
  }
  Db db = Db(settings['mongoDBServerURI'] + '/' + settings['mongoDatabase']);
  await db.open();
  userDb = db.collection(settings['usersCollection']);

  result = await userDb.findOne(where.eq('userID', args[0]));

  if (result == null) {
    print('Given user "${args[0]}" not found!');
    exit(-1);
  }
  userDb.updateOne(where.eq('userID', args[0]),
      modify.set('password', encryptString(args[1])));
  print('Password for User "${args[0]}" changed!');

  exit(0);
}
