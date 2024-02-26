import 'package:flutter/material.dart';
import 'package:settings/settings.dart';
import 'package:settings/color_scheme.dart';

class Legend extends StatelessWidget {
  bool horizontal = false;
  double spacing = 3;
  Legend({super.key, this.horizontal = false, this.spacing = 3});

  @override
  Widget build(BuildContext context) {
    List<Widget> legendItems = [
      Row(children: [
        Container(
            width: settings['dayBoxWidth'] / 2,
            height: settings['dayBoxHeight'] / 2,
            decoration: BoxDecoration(
              color: colorScheme['none'],
              border: Border.all(color: Colors.black, width: 1),
            )),
        const SizedBox(width: 2),
        const Text(
          'frei',
          style: TextStyle(
              fontFamily: "Arvo",
              fontWeight: FontWeight.normal,
              fontSize: 20,
              color: Colors.black),
        )
      ]),
      SizedBox(width: spacing),
      Row(children: [
        Container(
          color: colorScheme['primary'],
          width: settings['dayBoxWidth'] / 2,
          height: settings['dayBoxHeight'] / 2,
        ),
        const SizedBox(width: 2),
        const Text(
          'gebucht',
          style: TextStyle(
              fontFamily: "Arvo",
              fontWeight: FontWeight.normal,
              fontSize: 20,
              color: Colors.black),
        )
      ]),
      SizedBox(width: spacing),
      Row(children: [
        Container(
          color: colorScheme['primaryLight'],
          width: settings['dayBoxWidth'] / 2,
          height: settings['dayBoxHeight'] / 2,
        ),
        const SizedBox(width: 5),
        const Text(
          'angefragt',
          style: TextStyle(
              fontFamily: "Arvo",
              fontWeight: FontWeight.normal,
              fontSize: 20,
              color: Colors.black),
        )
      ]),
      SizedBox(width: spacing),
      Row(children: [
        Container(
          color: colorScheme['redLight'],
          width: settings['dayBoxWidth'] / 2,
          height: settings['dayBoxHeight'] / 2,
        ),
        const SizedBox(width: 5),
        const Text(
          'reserviert',
          style: TextStyle(
              fontFamily: "Arvo",
              fontWeight: FontWeight.normal,
              fontSize: 20,
              color: Colors.black),
        )
      ])
    ];
    return horizontal
        ? Row(children: legendItems)
        : Column(children: legendItems);
  }
}
