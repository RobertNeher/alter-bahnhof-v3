import 'package:model/calendar.dart';

void main(List<String> args) async {
  DateTime base = DateTime(int.parse(args[0].substring(0, 4)),
      int.parse(args[0].substring(5, 7)), int.parse(args[0].substring(9, 10)));
  DateTime after = DateTime(int.parse(args[1].substring(0, 4)),
      int.parse(args[1].substring(5, 7)), int.parse(args[1].substring(9, 10)));
  print(base);
  print(after);
  print(base.isBefore(after));
  print(isAfter(base, after));
}

bool isAfter(DateTime base, DateTime after) {
  if (after.year >= base.year) return false;
  if (after.month >= base.month) return false;
  return (after.day > base.day);
}
