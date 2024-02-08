import 'package:flutter/material.dart';
import 'package:alter_bahnhof_widgets/month_calendar.dart';

void main() {
  runApp(const AlterBahnhofApp());
}

class AlterBahnhofApp extends StatelessWidget {
  const AlterBahnhofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // localizationsDelegates: [
      //   AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      // ],
      // supportedLocales: [
      //   const Locale('de', ''), // German, no country code
      //   const Locale('en', ''), // English, no country code
      //   const Locale('fr', ''), // French, no country code
      // ],
      home: Scaffold(body: MonthCalendar(month: DateTime(2024, 4, 1))),
    );
  }
}
