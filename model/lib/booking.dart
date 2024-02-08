import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:settings/settings.dart';

class Booking {
  String id = '';
  late DateTime requestedOn;
  late DateTime confirmedOn;
  late DateTime startDate;
  late DateTime endDate;
  String lastName = '';
  String firstName = '';
  String eMail = '';
  String phone = '';
  String street = '';
  String city = '';
  String zipCode = '';
  String country = 'Deutschland';
  String status = '';
  String eventType = '';
  int guestCount = 1;
  String comment = '';
  bool newsletter = false;
  bool TaCAccepted = false;
  String quoteNo = '';
  late DateTime quoteConfirmedOn;
  String? invoiceNo = '';

  Booking({
    String id = '',
    DateTime? requestedOn,
    DateTime? confirmedOn,
    DateTime? startDate,
    DateTime? endDate,
    String lastName = '',
    String firstName = '',
    String eMail = '',
    String phone = '',
    String street = '',
    String city = '',
    String zipCode = '',
    String country = '',
    String status = '',
    String eventType = '',
    int guestCount = 0,
    String comment = '',
    bool newsletter = false,
    bool TaCAccepted = false,
    String quoteNo = '',
    DateTime? quoteConfirmedOn,
    String invoiceNo = '',
  }) {
    id = id;
    requestedOn = requestedOn!.toUtc();
    confirmedOn = confirmedOn != null ? confirmedOn.toUtc() : null;
    startDate = startDate!.toUtc();
    endDate = endDate!.toUtc();
    lastName = lastName;
    firstName = firstName;
    eMail = eMail;
    phone = phone;
    street = street;
    city = city;
    zipCode = zipCode;
    country = country;
    status = status;
    eventType = eventType;
    guestCount = guestCount;
    comment = comment;
    newsletter = newsletter;
    TaCAccepted = TaCAccepted;
    quoteNo = quoteNo;
    quoteConfirmedOn =
        quoteConfirmedOn != null ? quoteConfirmedOn.toUtc() : null;
    invoiceNo = invoiceNo;
  }

  Booking.fromJson(Map<String, dynamic> json) {
    DateFormat df = DateFormat(settings['alterBahnhofDateFormat']);
    id = json['_id'].toString();
    requestedOn = df.parse(json['requestedOn']).toUtc();

    if (json['confirmedOn'] != null) {
      confirmedOn = df.parse(json['confirmedOn']).toUtc();
    }
    startDate = df.parse(json['startDate']).toUtc();
    endDate = df.parse(json['endDate']).toUtc();
    lastName = json['lastName'].toString();
    firstName = json['firstName'].toString();
    eMail = json['eMail'].toString();
    phone = json['phone'].toString();
    street = json['street'].toString();
    city = json['city'].toString();
    zipCode = json['zipCode'].toString();
    country = json['country'].toString();
    status = json['status'].toString();
    eventType = json['eventType'];
    guestCount = json['guestCount'];
    comment = json['comment'].toString();
    newsletter = json['newsletter'] ??= false;
    TaCAccepted = json['TaCAccepted'] ??= false;
    quoteNo = json['quoteNo'].toString();

    if (json['quoteConfirmedOn'] != null) {
      quoteConfirmedOn = json['quoteConfirmedOn'].toUtc();
    }
    invoiceNo = json['invoiceNo'].toString();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'requestedOn': requestedOn,
        'confirmedOn': confirmedOn,
        'startDate': startDate,
        'endDate': endDate,
        'lastName': lastName,
        'firstName': firstName,
        'eMail': eMail,
        'phone': phone,
        'street': street,
        'city': city,
        'zipCode': zipCode,
        'country': country,
        'status': status,
        'eventType': eventType,
        'guestCount': guestCount,
        'comment': comment,
        'newsletter': newsletter,
        'TuCAccepted': TaCAccepted,
        'quoteNo': quoteNo,
        'quoteConfirmedOn': quoteConfirmedOn,
        'invoiceNo': invoiceNo,
      };
}

Future<List<Booking>> fetchBookings(List<String> statusFilter,
    {String? dateFilter}) async {
  List<Booking> bookings = <Booking>[];
  http.Response response;

  // If filter is null, make sure all dates are passed
  dateFilter ??= settings['alterBahnhofStartDate'];

  //  Getting event bookings first
  Uri uri = Uri.http(
      '${settings["alterBahnhofHost"]}:${settings["alterBahnhofPort"]}',
      '/bookings/requestedAfter=$dateFilter');
  response = await http
      .get(uri, headers: {HttpHeaders.acceptHeader: 'application/json'});

  if (response.statusCode == 200) {
    var values = jsonDecode(response.body);
    values.forEach((booking) {
      Booking item = Booking.fromJson(booking);

      if (statusFilter.contains(item.status)) {
        bookings.add(item);
      }
    });
  }
  return bookings;
}

Future<List<Booking>> fetchBlockedDays(
    {String? startDate, String? endDate}) async {
  List<Booking> blockedDays = <Booking>[];
  http.Response response;

  startDate ??= settings['alterBahnhofStartDate'];

  //  Getting event bookings first
  Uri uri = Uri.http(
      '${settings["alterBahnhofHost"]}:${settings["alterBahnhofPort"]}',
      '/bookings/blockedDays',
      {'from': startDate, 'to': endDate});

  response = await http
      .get(uri, headers: {HttpHeaders.acceptHeader: 'application/json'});

  if (response.statusCode == 200) {
    var values = jsonDecode(response.body);
    values.forEach((blockedDay) {
      Booking item = Booking.fromJson(blockedDay);
      blockedDays.add(item);
    });
  }
  return blockedDays;
}

Future<String> deleteBooking(String id) async {
  http.Response response;

  //  Getting event bookings first
  Uri uri = Uri.http(
      '${settings["alterBahnhofHost"]}:${settings["alterBahnhofPort"]}',
      '/bookings/delete=$id');
  response = await http
      .get(uri, headers: {HttpHeaders.acceptHeader: 'application/json'});

  if (response.statusCode == 200) {
    return 'Item deleted';
  } else {
    return jsonDecode(response.body);
  }
}
