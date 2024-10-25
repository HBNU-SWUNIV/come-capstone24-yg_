import 'package:flutter/material.dart';
import 'package:testproject/screens/calendar/calendar_screen.dart';
import 'package:testproject/screens/home/home_screen.dart';
import 'package:testproject/screens/medical/medical_screen.dart';
import 'package:testproject/screens/menu/drawer.dart';
import 'package:testproject/screens/tea/tea_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 1;

  late Function _resetTeaScreenIndex;
  late Function _resetDisScreenIndex;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return '캘린더';
      case 1:
        return '홈';
      case 2:
        return '병 진단';
      case 3:
        return '허브 활용 방법';
      default:
        return '';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,

        title: Text(
          _getTitle(_counter),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

      ),
      drawer: AppDrawer(),

      body: IndexedStack(
        index: _counter,

        children: [
          CalendarScreen(),
          HomeScreen(),
          MedicalScreen(resetIndexCallback: (Function resetIndex) {
            _resetDisScreenIndex = resetIndex;
         }),
          //),
          TeaScreen(resetIndexCallback: (Function resetIndex) {
          _resetTeaScreenIndex = resetIndex;
          }),
        ],
      ),




      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              //currentPageIndex = index;
              _counter = index;
              if (index == 3) {
                _resetTeaScreenIndex(); // TeaScreen 인덱스 초기화
              }
              if (index == 2) {
                _resetDisScreenIndex(); // DisScreen 인덱스 초기화
              }
            });
          },
          selectedIndex: _counter,
          destinations: const [

            NavigationDestination(
                icon: Icon(Icons.calendar_month),
                label: '캘린더'
            ),

            NavigationDestination(
                icon: Icon(Icons.home),
                label: '홈'
            ),

            NavigationDestination(
                icon: Icon(Icons.medical_services),
                label: '병 진단'
            ),

            NavigationDestination(
                icon: Icon(Icons.icecream_rounded),
                label: '활용 방법'
            ),
          ]),
    );
  }
}
