import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart';
import 'package:settings/settings.dart';

class User {
  String _lastName = '';
  String _firstName = '';
  String _userID = '';
  String _password = '';

  User(String userID, String firstName, String lastName, String password) {
    _userID = userID;
    _lastName = lastName;
    _firstName = firstName;
    _password = password;
  }

  User fromJson(Map<String, dynamic> json) {
    return User(
      json['lastName'],
      json['firstName'],
      json['userID'],
      json['password'],
    );
  }

  Map<String, dynamic> toJson(User user) {
    return {
      'lastName': user._lastName,
      'firstName': user._firstName,
      'userID': user._userID,
      'password': user._password,
    };
  }

  String get password {
    return _password;
  }

  String fullName() {
    return '$_firstName $_lastName';
  }
}

Future<bool> checkLogon(String userID, String password) async {
  Uri uri = Uri.http(
      '${settings['alterBahnhofHost']}:${settings['alterBahnhofPort']}',
      'users/userID=$userID');
  http.Response response = await http.get(uri);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonUser = jsonDecode(response.body);
    String encryptedPassword = jsonUser['password'];

    return (encryptString(password) == encryptedPassword);
  }
  return false;
}

String encryptString(String text) {
  final key = Key.fromUtf8(settings['alterBahnhofEncryptionKey']);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));

  final encrypted = encrypter.encrypt(text, iv: iv);

  return (encrypted.base64);
}

String decryptString(text) {
  final key = Key.fromLength(32);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));

  final encrypted = encrypter.encrypt(text, iv: iv);
  final decrypted = encrypter.decrypt(encrypted, iv: iv);

  print(decrypted);

  return (decrypted);
}
