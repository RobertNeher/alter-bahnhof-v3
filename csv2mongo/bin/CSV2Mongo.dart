import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:csv/csv.dart';
import 'package:initialize_db/initialize_db.dart';
import 'package:settings/settings.dart';

void main(List<String> args) async {
  // bool init = await initializeAlterBahnhof();
  // if (!init) {
  //   print(
  //       'DB initialization did not end up successfully:\nCheck MongoDB database access');
  //   return;
  // }
  initializeAlterBahnhof();
  File file = File(args[0]);

  if (!file.existsSync() || args[0].isEmpty) {
    print('Given file is missing or does not exist');
    exit(-1);
  }
  Db db = Db('${settings["mongoDBServerURI"]}/${settings["mongoDatabase"]}');
  await db.open();
  DbCollection bookings = db.collection(settings['bookingStatusCollection']);
  print('Collection ${bookings.fullName()} neu erstellt.');

  Stream<List> inputStream = file.openRead();

  Map<String, dynamic> json = {};
  bool skip = false;
  int count = 0;
  String colStatus = '';
  DateFormat df = DateFormat('dd.MM.yyyy');

  final csvTable = await inputStream
      .transform(utf8.decoder)
      .transform(CsvToListConverter())
      .toList();

  for (final element in csvTable) {
    // Skip header line
    if (count == 0) {
      count++;
      continue;
    }

    DateTime requestDate = df.parse(element[0], true);
    DateTime startDate = df.parse(element[1], true);
    DateTime endDate = df.parse(element[2], true);

    colStatus = element[16];

    switch (colStatus) {
      // errorprone CalendarApp export keeps cancelled status empty (fields are shifted right)
      case '':
        colStatus = 'cancelled';
        skip = false;
        break;
      case 'angefragt':
        colStatus = 'requested';
        skip = false;
        break;
      case 'bestätigt':
        colStatus = 'booked';
        skip = false;
        break;
      case 'storniert':
        colStatus = 'cancelled';
        skip = false;
        break;
      default:
        colStatus = '-';
        skip = false;
        break;
    }
    if (!skip) {
      String name, lastName, firstName;
      String city, zipCode, type, comment;
      List<String> temp;

      // Last, first name
      name = element[3];
      temp = name.split(' ');
      if (temp.length == 2) {
        lastName = temp[1];
        firstName = temp[0];
      } else {
        lastName = name;
        firstName = '';
      }

      // City, Zip Code
      city = element[12].toString();
      temp = city.split(' ');
      if (temp.length >= 2) {
        if (temp[0].length >= 6) {
          temp[0] = temp[0].substring(0, 5);
        }
        zipCode = temp[0];
        city = temp[1];
      } else {
        zipCode = temp[0];
        city = '';
      }

      // calculate event type from comment
      comment = element[7].toString();
      comment = comment.toLowerCase();
      if (comment.contains('hochzeit')) {
        type = 'wedding';
      } else if (comment.contains('geburtstag')) {
        type = 'anniversary';
      } else {
        type = 'misc';
      }

      json = {
        // '_id': ObjectId(),
        'requestedOn': requestDate,
        'confirmedOn': '',
        'startDate': startDate,
        'endDate': endDate,
        'lastName': lastName,
        'firstName': firstName,
        'eMail': element[4],
        'phone': (element[5] is int) ? element[5].toString() : element[5],
        'street': element[11],
        'city': city,
        'zipCode': zipCode,
        'country': element[13],
        'status': colStatus,
        'quoteNo': '',
        'invoiceNo': '',
        'eventType': type,
        'comment': element[7],
        'guestCount': element[8],
        'newsletter': false,
        'TuCAccepted': colStatus == 'booked',
      };
    }
    count++;
    skip = false;

    await bookings.insert(json);
  }
  await db.close();
  exit(0);
}
