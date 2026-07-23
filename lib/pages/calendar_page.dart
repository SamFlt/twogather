import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final DateTime _today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      
      calendarFormat: .month,
      startingDayOfWeek: .monday,
      calendarStyle: CalendarStyle(

        isTodayHighlighted: false,
        selectedDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: .circular(5)
        ),
        todayDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: .circular(5)
        ),
        markerDecoration:  BoxDecoration(
          shape: BoxShape.rectangle,
          color: Theme.of(context).colorScheme.primary,
          borderRadius: .circular(5)
        ),
        defaultDecoration:  BoxDecoration(
          shape: BoxShape.rectangle,
          color: Theme.of(context).colorScheme.surface,
          borderRadius: .circular(5)
        ),
        disabledDecoration:  BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: .circular(5)
        ),
        weekendDecoration:  BoxDecoration(
          shape: BoxShape.rectangle,
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: .circular(5)
        ),

      ),
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay,
      enabledDayPredicate: (day) => !day.isBefore(_today),
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
    );
  }
}
