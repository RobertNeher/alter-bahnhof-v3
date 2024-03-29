import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:settings/settings.dart';

// const default_date = DateFormat(settings['alterBahnhofDateFormat'])
//     .parse(settings['alterBahnhofStartDate']);

class Booking {
  String id = '';
  late DateTime requestedOn;
  DateTime? confirmedOn;
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
    String invoiceNo = '',
  }) {
    id = id;
    requestedOn = requestedOn;
    confirmedOn = confirmedOn;
    startDate = startDate;
    endDate = endDate;
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
    invoiceNo = invoiceNo;
  }

  Booking.fromJson(Map<String, dynamic> json) {
    DateFormat df = DateFormat(settings['alterBahnhofDateFormat']);
    String id = json['id'].substring(10); // Extracting the id
    id = id.substring(0, id.length - 2);

    requestedOn = df.parse(json['requestedOn']);

    if (confirmedOn != null) {
      json['confirmedOn'] = df.parse(json['confirmedOn']);
    }
    startDate = df.parse(json['startDate']);
    endDate = df.parse(json['endDate']);
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

Future<Map<String, dynamic>>? fetchBookingDetail({String? id}) async {
  http.Response response;

  Uri uri = Uri.http(
      '${settings["alterBahnhofHost"]}:${settings["alterBahnhofPort"]}',
      '/bookings/id=$id');

  response = await http
      .get(uri, headers: {HttpHeaders.acceptHeader: 'application/json'});

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    return {};
  }
}

Future<List<Booking>> fetchBlockedDays(
    {String? startDate, String? endDate, bool managementView = false}) async {
  List<Booking> blockedDays = <Booking>[];
  http.Response response;

  startDate ??= settings['alterBahnhofStartDate'];

  //  Getting event bookings first
  Uri uri = Uri.http(
      '${settings["alterBahnhofHost"]}:${settings["alterBahnhofPort"]}',
      '/bookings/blockedDays', {
    'startDate': startDate,
    'endDate': endDate,
    'managementView': managementView ? 'y' : 'n'
  });

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
