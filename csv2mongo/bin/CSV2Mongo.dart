import 'dart:convert';
import 'dart:io';
import 'package:settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';

void main(List<String> args) async {
  File file = File(args[0]);

  if (!file.existsSync() || args[0].isEmpty) {
    print('Given file is missing or does not exist');
    exit(-1);
  }

  Db db = Db('${settings["mongoDBServerURI"]}/${settings["mongoDatabase"]}');
  await db.open();

  DbCollection users = await db.collection(settings['usersCollection']);
  await users.remove(null);
  print('Collection ${users.fullName()} gelöscht.');

  users = db.collection(settings['usersCollection']);
  await users.insert({
    'userID': 'admin',
    'name': 'Administrator',
    'email': 'hallo@seminarhaus-im-bahnhof.de',
    'password': 'admin',
  });
  print('Collection ${users.fullName()} neu erstellt.');

  DbCollection eventType = db.collection(settings['eventTypeCollection']);
  await eventType.remove(null);
  print('Collection ${eventType.fullName()} gelöscht.');

  eventType = db.collection(settings['eventTypeCollection']);

  eventType.insert({'id': 'wedding', 'type': 'Hochzeit'});
  eventType.insert({'id': 'anniversary', 'type': 'Jubiläum'});
  eventType.insert({'id': 'birth', 'type': 'Geburt'});
  eventType.insert({'id': 'funeral', 'type': 'Begräbnis'});
  eventType.insert({'id': 'training', 'type': 'Schulung'});
  eventType.insert({'id': 'seminar', 'type': 'Seminar'});
  eventType.insert({'id': 'coaching', 'type': 'Coaching'});
  eventType.insert({'id': 'misc', 'type': 'Sonstiges'});
  print('Collection ${eventType.fullName()} neu erstellt.');

  DbCollection bookingStatus =
      db.collection(settings['bookingStatusCollection']);
  await bookingStatus.remove(null);
  print('Collection ${bookingStatus.fullName()} gelöscht.');

  bookingStatus = db.collection(settings['bookingStatusCollection']);
  bookingStatus.insert({'id': 'requested', 'status': 'Angefragt'});
  bookingStatus.insert({'id': 'booked', 'status': 'Gebucht'});
  bookingStatus.insert({'id': 'invoiced', 'status': 'Rechnung\ngestellt'});
  bookingStatus.insert({'id': 'payed', 'status': 'Zahlung\neingegangen'});
  bookingStatus.insert({'id': 'cancelled', 'status': 'Storno'});
  bookingStatus.insert({'id': 'rejected', 'status': 'Abgelehnt'});
  print('Collection ${bookingStatus.fullName()} neu erstellt.');

  DbCollection bookings = db.collection(settings['bookingsCollection']);
  await bookings.remove(null);
  print('Collection ${bookings.fullName()} gelöscht.\n');

  bookings = db.collection(settings['bookingsCollection']);

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
  print('Collection ${bookings.fullName()} neu erstellt.');
  bookings.createIndex(
    keys: {'requestedOn': 1, 'eMail': 1, 'startDate': 1, 'lastName': 1},
    unique: true,
  );
  bookings.createIndex(
    keys: {'requestedOn': 1, 'startDate': 1, 'endDate': 1},
    unique: true,
  );
  print('Indexe für Collection ${bookings.fullName()} neu erstellt.');
  await db.close();
  exit(0);
}
