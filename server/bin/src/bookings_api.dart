import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:settings/settings.dart';
import 'package:utils/utils.dart';
import 'package:model/booking.dart';
import 'package:model/holiday.dart';

class BookingsApi {
  DbCollection bookingsCollection;

  BookingsApi({required DbCollection this.bookingsCollection});

  Router get router {
    const Map<String, String> responseHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
    };

    final router = Router();

    ////////////////// GET //////////////////////
    router.get('/size', (Request request) async {
      int size = await bookingsCollection.count();
      return Response.ok(jsonEncode({'size': size.toString()}),
          headers: responseHeaders);
    });

    // .../id=<Hex ID> for selecting one single booking
    router.get('/id=<id|[0-9A-Fa-f]+>', (Request request, String id) async {
      Map<String, dynamic>? result = {};
      ObjectId oid = ObjectId.fromHexString(id);
      result = await bookingsCollection.findOne({'_id': oid});

      return Response.ok(json.encode(result, toEncodable: alterBahnhofEncode),
          headers: responseHeaders);
    });

    //.../daysOfMonth?month=yyyy-MM-dd
    router.get('/daysOfMonth', (Request request) async {
      DateTime firstDay, lastDay;
      DateFormat df = DateFormat(settings['alterBahnhofDateFormat']);
      List<Map<String, dynamic>> weekRow = [];
      Map<String, dynamic> parameters = request.url.queryParameters;
      DateTime requestedMonth = DateTime.utc(
          int.parse(parameters['month'].substring(0, 4)),
          int.parse(parameters['month'].substring(5, 7)),
          1);
      // Normalize month's begin to Monday of previous month
      lastDay = DateTime.utc(requestedMonth.year, requestedMonth.month, 0);
      firstDay = lastDay.weekday < 7
          ? requestedMonth.add(Duration(days: -lastDay.weekday))
          : lastDay.add(Duration(seconds: 86400));
      List<Map<String, dynamic>> holidays = await getHolidays(requestedMonth);

      // Normalize month's end to Sunday of subsequent month
      lastDay = DateTime.utc(requestedMonth.year, requestedMonth.month + 1, 0);
      lastDay = lastDay.add(Duration(days: 7 - lastDay.weekday));

      List<Booking> bookings = await fetchBlockedDays(
          startDate: df.format(firstDay), endDate: df.format(lastDay));

      List<String> dayCategories = [];
      String holidayName = isHoliday(holidays, requestedMonth);
      Booking? status;
      int dayCount = 1;
      Map<String, dynamic> monthCalendar = {
        // TODO Add locale below
        'month': DateFormat(settings['alterBahnhofMonthDateFormat'])
            .format(requestedMonth),
        'weekList': []
      };

      for (DateTime indexDay = firstDay; !indexDay.isAfter(lastDay);) {
        dayCategories = [];
        status = bookingStatus(bookings, indexDay);

        if (status != null) {
          if (status.status == 'booked') {
            dayCategories.add('booked');
          }
          if (status.status == 'requested') {
            dayCategories.add('requested');
          }
        }
        if (isSameDay(indexDay, DateTime.now())) {
          dayCategories.add('today');
        }

        holidayName = isHoliday(holidays, indexDay);

        weekRow.add({
          'bookingID': status != null ? status.id : '',
          'date': indexDay,
          'weekDay': getWeekday(indexDay),
          'bookingStatus': dayCategories.isNotEmpty ? dayCategories : 'none',
          'holiday': holidayName,
        });

        if (dayCount % 7 == 0) {
          monthCalendar['weekList'].add({
            'weekNo': isoWeekNumber(indexDay),
            'weekDays': weekRow, // should be always 7 entries per week
          });
          weekRow = [];
        }
        dayCount++;
        indexDay = indexDay.add(Duration(days: 1));
      }
      return Response.ok(
          json.encode(monthCalendar, toEncodable: alterBahnhofEncode),
          headers: responseHeaders);
    });

    //.../blockedDays?from=yyyy-MM-dd&to=yyyy-MM-dd
    router.get('/blockedDays', (Request request) async {
      String start, end;
      DateFormat df = DateFormat(settings['alterBahnhofDateFormat']);
      List<Map<String, dynamic>> blockedDays = [];
      Map<String, dynamic> parameters = request.url.queryParameters;

      // Default date: Starting month/year of Seminarhaus
      start = parameters['from'] ?? settings['alterBahnhofStartDate'];
      end = parameters['to'] ?? df.format(DateTime.now().toUtc());

      await bookingsCollection
          .find(where
            ..gte(
                'startDate',
                DateFormat(settings['alterBahnhofDateFormat'])
                    .parse(start, true))
            ..and(where.lte('endDate',
                DateFormat(settings['alterBahnhofDateFormat']).parse(end, true))
              ..and(where.oneFrom('status', [
                'requested',
                'booked',
              ])))
            ..sortBy('startDate', descending: false))
          .forEach((booking) {
        if (booking['startDate'] == booking['endDate']) {
          booking['blockedDay'] = (df.format(booking['startDate']));
          blockedDays.add({
            'id': booking['_id'].toString(),
            'requestedOn': booking['requestedOn'].toUtc(),
            'confirmedOn': booking['confirmedOn'] != null
                ? booking['confirmedOn'].toUtc()
                : null,
            'startDate': booking['startDate'].toUtc(),
            'endDate': booking['startDate'].toUtc(),
            'eventType': booking['eventType'],
            'status': booking['status'],
            'guestCount': booking['guestCount'],
          });
        }

        if (booking['endDate'].isAfter(booking['startDate'])) {
          DateTime indexDay = booking['startDate'];
          DateTime endDate = booking['endDate'].add(Duration(days: 1));
          do {
            blockedDays.add({
              'id': booking['_id'].toString(),
              'requestedOn': booking['requestedOn'].toUtc(),
              'confirmedOn': booking['confirmedOn'] != null
                  ? booking['confirmedOn'].toUtc()
                  : null,
              'startDate': indexDay.toUtc(),
              'endDate': indexDay.toUtc(),
              'eventType': booking['eventType'],
              'status': booking['status'],
              'guestCount': booking['guestCount'],
            });
            indexDay = indexDay.add(Duration(days: 1));
          } while (indexDay.isBefore(endDate));
        }
      });
      return Response.ok(
          json.encode(blockedDays, toEncodable: alterBahnhofEncode),
          headers: responseHeaders);
    });

    router.get('/all', (Request request) async {
      List<Map<String, dynamic>> allDays = [];

      await bookingsCollection
          .find(where
            ..ne('requestedOn', '')
            ..sortBy('requestedOn', descending: true))
          .forEach((booking) {
        allDays.add(booking);
      });
      return Response.ok(
          jsonEncode(json.encode(allDays, toEncodable: alterBahnhofEncode)),
          headers: responseHeaders);
    });

    // .../requestedAfter=yyyy-MM-dd including
    router.get('/requestedAfter=<requestedAfter|[0-9]{4}-[0-9]{2}-[0-9]{2}>',
        (Request request, String requestedAfter) async {
      List<Map<String, dynamic>> days = [];

      await bookingsCollection
          .find(where
            ..gte(
                'requestedOn',
                DateFormat(settings['alterBahnhofDateFormat'])
                    .parse(requestedAfter, true))
            ..sortBy('startDate', descending: false))
          .forEach((booking) {
        days.add(booking);
      });
      return Response.ok(json.encode(days, toEncodable: alterBahnhofEncode),
          headers: responseHeaders);
    });

    // get endpoint to switch requested to booked status
    router.get('/confirm=<id|[0-9A-Fa-f]+>',
        (Request request, String id) async {
      Map<String, dynamic>? result;
      ObjectId oid = ObjectId.fromHexString(id);

      if (id != '') {
        result = await bookingsCollection.findOne(where
          ..eq('status', 'requested')
          ..and(where.eq('_id', oid)..sortBy('startDate', descending: false)));

        await bookingsCollection.updateOne(
            where.eq('_id', oid)..eq('status', 'requested'),
            modify.set('status', 'booked'));

        await bookingsCollection.updateOne(
            where.eq('_id', oid), modify.set('confirmedOn', DateTime.now()));
      }
      return Response.ok(json.encode(result, toEncodable: alterBahnhofEncode),
          headers: responseHeaders);
    });

    // get endpoint to switch requested to booked status
    router.get('/cancel=<id|[0-9A-Fa-f]+>', (Request request, String id) async {
      Map<String, dynamic>? result;
      ObjectId oid = ObjectId.fromHexString(id);

      if (id != '') {
        result = await bookingsCollection.findOne(where.oneFrom('status', [
          'requested',
          'booked',
        ])
          ..and(where.eq('_id', oid)..sortBy('startDate', descending: false)));

        await bookingsCollection.updateOne(
            where.eq('_id', oid), modify.set('status', 'cancelled'));
      }
      return Response.ok(json.encode(result, toEncodable: alterBahnhofEncode),
          headers: responseHeaders);
    });

    // all other stuff
    router.get('/<something|.*>', (Request request, String something) async {
      return Response.ok(
          jsonEncode('This is the Bookings service of Alter Bahnhof'),
          headers: responseHeaders);
    });

    ////////////////// POST //////////////////////
    router.post('/', (Request request) async {
      String data = await request.readAsString();
      Map<String, dynamic> payload = jsonDecode(data);
      WriteResult? result = await bookingsCollection.insertOne(payload);
      return Response.ok(json.encode(result, toEncodable: alterBahnhofEncode),
          headers: responseHeaders);
    });

    ////////////////// PUT //////////////////////
    router.put('/', (Request request, String rawData) async {
      WriteResult? result;
      Map<String, dynamic> data = jsonDecode(rawData);
      final ObjectId oid = ObjectId.fromHexString(data['id']);

      result = await bookingsCollection.updateOne({'_id': oid}, data);

      return Response.ok(json.encode(result, toEncodable: alterBahnhofEncode),
          headers: responseHeaders);
    });

    ////////////////// DELETE //////////////////////
    router.delete('/id=<id|[0-9A-Fa-f]+>', (Request request, String id) async {
      WriteResult? result;
      final ObjectId oid = ObjectId.fromHexString(id);

      result = await bookingsCollection.deleteOne({'_id': oid});

      return Response.ok('Entry with id "$id" has been deleted');
    });

    return router;
  }
}

String isHoliday(List<Map<String, dynamic>> holidaysOfMonth, DateTime date) {
  for (Map<String, dynamic> holiday in holidaysOfMonth) {
    if (isSameDay(holiday['date'], date)) {
      return holiday['name'];
    }
  }
  return '';
}

Booking? bookingStatus(List<Booking> bookings, DateTime date) {
  for (Booking booking in bookings) {
    //Normalization of dates
    DateTime _endDate = DateTime(
        booking.endDate.year, booking.endDate.month, booking.endDate.day);
    DateTime _startDate = DateTime(
        booking.startDate.year, booking.startDate.month, booking.startDate.day);
    DateTime _date = DateTime(date.year, date.month, date.day);

    if (_date.isAfter(_endDate) || _date.isBefore(_startDate)) {
      continue;
    } else {
      return booking;
    }
  }
  return null;
}
