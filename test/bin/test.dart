import 'package:model/calendar.dart';

void main(List<String> args) async {
  Map<String, dynamic> data = await getCalendarBasics(DateTime(2024, 1, 1));
  print(data);
}
