import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  //const Calendar({Key? key}) : super(key: key);

  final Function(DateTime, DateTime) onDaySelected;
  final DateTime selectedDate;

  Calendar({
    required this.onDaySelected,
    required this.selectedDate
  });

  _CalendarState createState() => _CalendarState();
  }

  class _CalendarState extends State<Calendar> {

    @override
    Widget build(BuildContext context) {

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [Color(0xFFFBF2FA), Color(0xFFECE8F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        //margin: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: TableCalendar(
          onDaySelected: (selectedDay, focusedDay) {
            widget.onDaySelected(selectedDay, focusedDay);
            print('Selected day : $selectedDay');
          },
          selectedDayPredicate: (date) =>
          date.year == widget.selectedDate.year &&
              date.month == widget.selectedDate.month &&
              date.day == widget.selectedDate.day,
          firstDay: DateTime.utc(2010, 01, 01),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: widget.selectedDate,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: Colors.black,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Colors.black,
            ),
          ),



          calendarStyle: CalendarStyle(
            isTodayHighlighted: true,
            selectedDecoration: BoxDecoration(
              color: Color(0xFF6750A4),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.orange,
                width: 2.0,
              ),
            ),
            markerDecoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            outsideDaysVisible: false,
            cellMargin: EdgeInsets.all(1),
            defaultTextStyle: TextStyle(
              fontSize: 16,
            )
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontSize: 16,
              color: Colors.black,
              //fontWeight: FontWeight.bold,
            ),
            weekendStyle: TextStyle(
              fontSize: 16,
              color: Color(0xFFC44D4D),
              //fontWeight: FontWeight.bold,
            ),
            dowTextFormatter: (date, locale) {
              switch (date.weekday) {
                case DateTime.monday:
                  return 'M';
                case DateTime.tuesday:
                  return 'T';
                case DateTime.wednesday:
                  return 'W';
                case DateTime.thursday:
                  return 'T';
                case DateTime.friday:
                  return 'F';
                case DateTime.saturday:
                  return 'S';
                case DateTime.sunday:
                  return 'S';
                default:
                  return '';
              }
            },
          ),
          startingDayOfWeek: StartingDayOfWeek.sunday,
          calendarBuilders: CalendarBuilders(
            selectedBuilder: (context, date, _) {
              return Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF6750A4),
                    shape: BoxShape.circle,
                  ),
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
            todayBuilder: (context, date, _) {
              return Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all( // 테두리를 파란색으로 설정
                      color: Color(0xFF6750A4),
                      width: 2.0,
                    ),
                  ),
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: Color(0xFF6750A4),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }