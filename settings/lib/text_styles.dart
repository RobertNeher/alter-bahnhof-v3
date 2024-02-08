import 'package:flutter/material.dart';
import 'package:settings/color_scheme.dart';

Map<String, TextStyle> textStyles = {
  'calendarHeader': TextStyle(
      fontFamily: 'Arvo',
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      fontSize: 20,
      color: Colors.white),
  'calendarData': TextStyle(
      fontFamily: 'Arvo',
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      fontSize: 20,
      color: Colors.black),
  'weekNo': TextStyle(
      fontFamily: 'Arvo',
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
      fontSize: 20,
      color: Colors.black),
  'title': TextStyle(
      fontFamily: 'Arvo',
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      fontSize: 28,
      color: colorScheme['primary'])
};
