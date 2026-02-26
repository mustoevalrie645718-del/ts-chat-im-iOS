import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';

typedef _CallBack = void Function(DateTime selectIndex, DateTime selectStr);

class CaledatSelect extends StatefulWidget {
  _CallBack? callback;

  CaledatSelect({this.callback});

  @override
  _CaledatSelectState createState() => _CaledatSelectState();
}

class _CaledatSelectState extends State<CaledatSelect> {
  DateTime forcetime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: "en_US",
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: forcetime,
      onDaySelected: (selectedDay, focusedDay) {
        forcetime = selectedDay;
        widget.callback!(selectedDay, focusedDay);
        setState(() {});
      },
    );
  }
}
