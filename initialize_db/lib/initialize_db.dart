import 'package:mongo_dart/mongo_dart.dart';
import 'package:settings/settings.dart';

Future<bool> initializeAlterBahnhof() async {
  try {
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

    DbCollection reservedDays =
        db.collection(settings['reservedDaysCollection']);
    await reservedDays.remove(null);
    print('Collection ${reservedDays.fullName()} gelöscht.');

    reservedDays = db.collection(settings['reservedDaysCollection']);
    reservedDays.insert(
        {'blockedDay': DateTime.now(), 'comment': 'Initialization performed.'});
    print('Collection ${reservedDays.fullName()} neu erstellt.');

    DbCollection bookings = db.collection(settings['bookingsCollection']);
    await bookings.remove(null);
    print('Collection ${bookings.fullName()} gelöscht.\n');

    // bookings = db.collection(settings['bookingsCollection']);
    // bookings.createIndex(
    //   keys: {'requestedOn': 1, 'eMail': 1, 'startDate': 1, 'lastName': 1},
    //   unique: true,
    // );
    // bookings.createIndex(
    //   keys: {'requestedOn': 1, 'startDate': 1, 'endDate': 1},
    //   unique: false,
    // );
    // print('Indexe für Collection ${bookings.fullName()} neu erstellt.');

    reservedDays.createIndex(
      keys: {'blockedDay': 1},
      unique: true,
    );
    print('Index für Collection ${reservedDays.fullName()} neu erstellt.');
    await db.close();
  } catch (e) {
    return false;
  }
  return true;
}

void main(List<String> arguments) async {
  initializeAlterBahnhof();
}
