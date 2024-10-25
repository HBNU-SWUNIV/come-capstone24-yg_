import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testproject/screens/home/components/dialog_addchecklist.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
// import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:testproject/screens/calendar/calendar_screen.dart';

import 'dialog_addchecklist2.dart';


class CKListBtnDialog extends StatefulWidget {
  final String selectedValue; // selectedValue 매개변수 정의
  final Map<String, bool> initialCheckStates;
  final List<String> selectedValues2;
  final VoidCallback? onConfirmed; // onConfirmed 매개변수 추가

  CKListBtnDialog({
    required this.selectedValue,
    required this.initialCheckStates,
    required this.selectedValues2,
    this.onConfirmed, // 초기화
  });

  _CKListBtnDialogState createState() => _CKListBtnDialogState();
}

class _CKListBtnDialogState extends State<CKListBtnDialog> {
  //final now = new DateTime.now();
  //DateTime now = DateTime(2024, 5, 18);
  DateTime now = DateTime.now();

  //DateTime now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 19, 59);
  String formattedDate = DateFormat('MM월 dd일').format(DateTime.now());
  bool LuvCheck = false; // 애정주기 초기값
  bool waterCheck = false; // 물 주기 초기값
  bool ventilationCheck = false; // 환기하기 초기값
  DateTime? lastCheckedDate;

  bool repotCheck = false; // 분갈이하기 초기값
  bool pruneCheck = false; // 가지치기 초기값
  bool nutritionCheck = false; // 영양 관리 초기값
  bool harvestCheck = false; // 수확하기 초기값

  bool repotCheckBox = false;
  bool pruneCheckBox = false;
  bool nutritionCheckBox = false;
  bool harvestCheckBox = false;

  late Map<String, bool> waterChecks;
  late Map<String, bool> LuvChecks;
  late Map<String, bool> ventilationChecks;

  late Map<String, bool> repotChecks;
  late Map<String, bool> repotChecksBox = {};
  late Map<String, bool> pruneChecks;
  late Map<String, bool> pruneChecksBox = {};
  late Map<String, bool> nutritionChecks;
  late Map<String, bool> nutritionChecksBox = {};
  late Map<String, bool> harvestChecks;
  late Map<String, bool> harvestChecksBox = {};


  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final PageController _pageController = PageController(); // 페이지 수평 스와이프

  // 여기서부터
  void initState() {
    super.initState();
    _loadCheckStatus();

    repotCheckBox = widget.initialCheckStates['repotCheckBox'] ?? false;
    pruneCheckBox = widget.initialCheckStates['pruneCheckBox'] ?? false;
    nutritionCheckBox = widget.initialCheckStates['nutritionCheckBox'] ?? false;
    harvestCheckBox = widget.initialCheckStates['harvestCheckBox'] ?? false;

    waterChecks = {for (var value in widget.selectedValues2) value: false};
    LuvChecks = {for (var value in widget.selectedValues2) value: false};
    ventilationChecks = {for (var value in widget.selectedValues2) value: false};

    repotChecks = {for (var value in widget.selectedValues2) value: false};
    repotChecksBox = {for (var value in widget.selectedValues2) value: false};
    pruneChecks = {for (var value in widget.selectedValues2) value: false};
    pruneChecksBox = {for (var value in widget.selectedValues2) value: false};
    nutritionChecks = {for (var value in widget.selectedValues2) value: false};
    nutritionChecksBox = {for (var value in widget.selectedValues2) value: false};
    harvestChecks = {for (var value in widget.selectedValues2) value: false};
    harvestChecksBox = {for (var value in widget.selectedValues2) value: false};

    _init();

    print('Initial repotChecksBox: $repotChecksBox');
  }

  // 알림 관련
  Future<void> configureTime() async {
    tz.initializeTimeZones();
    //final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    final String? timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
  }

  // 알림 관련
  Future<void> initializeNoti() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 알림 관련
  Future<void> _MessageSetting({
    required int hour,
    required int minutes,
    required message,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '물 주기 알림',
      message,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'chaneel name',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
          styleInformation: BigTextStyleInformation(message),
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _init() async {
    await configureTime();
    await initializeNoti();
  }

  _loadCheckStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = DateFormat('yyyy-MM-dd').format(now);

    setState(() {
      LuvCheck = prefs.getBool('$key LUVChecked') ?? false;
      waterCheck = prefs.getBool('$key waterChecked') ?? false;
      ventilationCheck = prefs.getBool('$key ventilationChecked') ?? false;
      lastCheckedDate = DateTime.tryParse(prefs.getString('lastCheckedDate') ?? '');

      repotCheck = prefs.getBool('$key repotChecked') ?? false;
      pruneCheck = prefs.getBool('$key pruneChecked') ?? false;
      nutritionCheck = prefs.getBool('$key nutritionChecked') ?? false;
      harvestCheck = prefs.getBool('$key harvestChecked') ?? false;

      repotCheckBox = prefs.getBool('repotCheckedBox') ?? false;
      pruneCheckBox = prefs.getBool('pruneCheckedBox') ?? false;
      nutritionCheckBox = prefs.getBool('nutritionCheckedBox') ?? false;
      harvestCheckBox = prefs.getBool('harvestCheckedBox') ?? false;

      String? waterChecksString = prefs.getString('$key waterChecked2');
      if (waterChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(waterChecksString);
        waterChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        waterChecks = {for (var value in widget.selectedValues2) value: false};
      }

      String? LuvChecksString = prefs.getString('$key LuvChecked2');
      if (LuvChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(LuvChecksString);
        LuvChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        LuvChecks = {for (var value in widget.selectedValues2) value: false};
      }

      String? ventilationChecksString = prefs.getString('$key ventilationChecked2');
      if (ventilationChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(ventilationChecksString);
        ventilationChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        ventilationChecks = {for (var value in widget.selectedValues2) value: false};
      }

      String? repotChecksString = prefs.getString('$key repotChecked2');
      if (repotChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(repotChecksString);
        repotChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        repotChecks = {for (var value in widget.selectedValues2) value: false};
      }

      String? repotChecksBoxString = prefs.getString('$key repotCheckedBox2');
      if (repotChecksBoxString != null) {
        Map<String, dynamic> jsonMap = json.decode(repotChecksBoxString);
        repotChecksBox = jsonMap.map((key, value) => MapEntry(key, value as bool));
        print('Loaded repotChecksBox: $repotChecksBox');
      } else {
        repotChecksBox = {for (var value in widget.selectedValues2) value: false};
      }

      String? pruneChecksString = prefs.getString('$key pruneChecked2');
      if (pruneChecksString != null) {
      Map<String, dynamic> jsonMap = json.decode(pruneChecksString);
      pruneChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        pruneChecks = {for (var value in widget.selectedValues2) value: false};
      }

      String? pruneChecksBoxString = prefs.getString('$key pruneCheckedBox2');
      if (pruneChecksBoxString != null) {
      Map<String, dynamic> jsonMap = json.decode(pruneChecksBoxString);
      pruneChecksBox = jsonMap.map((key, value) => MapEntry(key, value as bool));
      print('Loaded pruneChecksBox: $pruneChecksBox');
      } else {
        pruneChecksBox = {for (var value in widget.selectedValues2) value: false};
      }

      String? nutritionChecksString = prefs.getString('$key nutritionChecked2');
      if (nutritionChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(nutritionChecksString);
        nutritionChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        nutritionChecks = {for (var value in widget.selectedValues2) value: false};
      }

      String? nutritionChecksBoxString = prefs.getString('$key nutritionCheckedBox2');
      if (nutritionChecksBoxString != null) {
        Map<String, dynamic> jsonMap = json.decode(nutritionChecksBoxString);
        nutritionChecksBox = jsonMap.map((key, value) => MapEntry(key, value as bool));
        print('Loaded pruneChecksBox: $nutritionChecksBox');
      } else {
        nutritionChecksBox = {for (var value in widget.selectedValues2) value: false};
      }

      String? harvestChecksString = prefs.getString('$key harvestChecked2');
      if (harvestChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(harvestChecksString);
        harvestChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        harvestChecks = {for (var value in widget.selectedValues2) value: false};
      }

      String? harvestChecksBoxString = prefs.getString('$key harvestCheckedBox2');
      if (harvestChecksBoxString != null) {
        Map<String, dynamic> jsonMap = json.decode(harvestChecksBoxString);
        harvestChecksBox = jsonMap.map((key, value) => MapEntry(key, value as bool));
        print('Loaded pruneChecksBox: $harvestChecksBox');
      } else {
        harvestChecksBox = {for (var value in widget.selectedValues2) value: false};
      }

    });
  }

  _saveCheckStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = DateFormat('yyyy-MM-dd').format(now);

    await prefs.setBool('$key LUVChecked', LuvCheck);
    await prefs.setBool('$key waterChecked', waterCheck);
    await prefs.setBool('$key ventilationChecked', ventilationCheck);
    await prefs.setString(
        'lastCheckedDate', DateFormat('yyyy-MM-dd').format(now));

    await prefs.setBool('$key repotChecked', repotCheck);
    await prefs.setBool('$key pruneChecked', pruneCheck);
    await prefs.setBool('$key nutritionChecked', nutritionCheck);
    await prefs.setBool('$key harvestChecked', harvestCheck);
  }

  void _saveChecksStatus(String checkKey, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = DateFormat('yyyy-MM-dd').format(now);
    String waterChecksString = json.encode(waterChecks);
    String LuvChecksString = json.encode(LuvChecks);
    String ventilationChecksString = json.encode(ventilationChecks);

    String repotChecksString = json.encode(repotChecks);
    String repotChecksBoxString = json.encode(repotChecksBox);
    String pruneChecksString = json.encode(pruneChecks);
    String pruneChecksBoxString = json.encode(pruneChecksBox);
    String nutritionChecksString = json.encode(nutritionChecks);
    String nutritionChecksBoxString = json.encode(nutritionChecksBox);
    String harvestChecksString = json.encode(harvestChecks);
    String harvestChecksBoxString = json.encode(harvestChecksBox);

    await prefs.setString('$key waterChecked2', waterChecksString);
    await prefs.setString('$key LuvChecked2', LuvChecksString);
    await prefs.setString('$key ventilationChecked2', ventilationChecksString);
    await prefs.setString('$key repotChecked2', repotChecksString);
    await prefs.setString('$key repotCheckedBox2', repotChecksBoxString);
    await prefs.setString('$key pruneChecked2', pruneChecksString);
    await prefs.setString('$key pruneCheckedBox2', pruneChecksBoxString);
    await prefs.setString('$key nutritionChecked2', nutritionChecksString);
    await prefs.setString('$key nutritionCheckedBox2', nutritionChecksBoxString);
    await prefs.setString('$key harvestChecked2', harvestChecksString);
    await prefs.setString('$key harvestCheckedBox2', harvestChecksBoxString);


    print('Saved repotChecksBox: $repotChecksBox');
  }

  Future<void> _onCheckConfirmed() async {

    // 확인 버튼 클릭 시 HomeScreen에 상태를 알림
    if (widget.onConfirmed != null) {
      widget.onConfirmed!();
    }
  }

  @override
  Widget build(BuildContext context) {

    //날짜가 넘어가면 체크리스트를 초기화 하는 코드
    int daysSinceLastCheck = lastCheckedDate == null ? 0 : now
        .difference(lastCheckedDate!)
        .inDays;

    if (repotCheckBox == false) {
      repotCheck = false;
      _saveCheckStatus(repotCheck);
    }

    if (pruneCheckBox == false) {
      pruneCheck = false;
      _saveCheckStatus(pruneCheck);
    }

    if (nutritionCheckBox == false) {
      nutritionCheck = false;
      _saveCheckStatus(nutritionCheck);
    }

    if (harvestCheckBox == false) {
      harvestCheck = false;
      _saveCheckStatus(harvestCheck);
    }

    List<Widget> additionalPages = _buildAdditionalPages(widget.selectedValues2);


    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery
            .of(context).size.width * 0.65,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFCEEFC).withOpacity(0.9),
              Color(0xFFD3C9E3).withOpacity(0.9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
        ),
//
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  '$formattedDate'
              ),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: [
                    _buildFirstPage(daysSinceLastCheck),
                    if (widget.selectedValues2.isNotEmpty) ...additionalPages,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstPage(int daysSinceLastCheck) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.selectedValue,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2B32),
            ),
          ),
          SizedBox(height: 16.0),
          // 체크 상태 저장하는 코드
          if (widget.selectedValue == '레몬 밤') ...[
            if (daysSinceLastCheck >= 5 || daysSinceLastCheck == 0)
              CheckboxListTile(
                title: Text('물 주기'),
                value: waterCheck,
                onChanged: (val) {
                  setState(() {
                    waterCheck = val!;
                    _saveCheckStatus(waterCheck);
                  });
                },
              ),
            CheckboxListTile(
              title: Text('환기하기'),
              value: ventilationCheck,
              onChanged: (val) {
                setState(() {
                  ventilationCheck = val!;
                  _saveCheckStatus(ventilationCheck);
                });
              },
            ),
            CheckboxListTile(
              title: Text('향기 좋다고 칭찬하기'),
              value: LuvCheck,
              onChanged: (val) {
                setState(() {
                  LuvCheck = val!;
                  _saveCheckStatus(LuvCheck);
                });
              },
            ),
            if (repotCheckBox)
              CheckboxListTile(
                title: Text('분갈이하기'),
                value: repotCheck,
                onChanged: (val) {
                  setState(() {
                    repotCheck = val!;
                    _saveCheckStatus(repotCheck);
                  });
                },
              ),
            if (pruneCheckBox)
              CheckboxListTile(
                title: Text('가지치기'),
                value: pruneCheck,
                onChanged: (val) {
                  setState(() {
                    pruneCheck = val!;
                    _saveCheckStatus(pruneCheck);
                  });
                },
              ),
            if (nutritionCheckBox)
              CheckboxListTile(
                title: Text('영양 관리'),
                value: nutritionCheck,
                onChanged: (val) {
                  setState(() {
                    nutritionCheck = val!;
                    _saveCheckStatus(nutritionCheck);
                  });
                },
              ),
            if (harvestCheckBox)
              CheckboxListTile(
                title: Text('수확하기'),
                value: harvestCheck,
                onChanged: (val) {
                  setState(() {
                    harvestCheck = val!;
                    _saveCheckStatus(harvestCheck);
                  });
                },
              ),
          ]
          else if (widget.selectedValue == '라벤더') ...[
            if (daysSinceLastCheck >= 4 || daysSinceLastCheck == 0)
              CheckboxListTile(
                title: Text('물 주기'),
                value: waterCheck,
                onChanged: (val) {
                  setState(() {
                    waterCheck = val!;
                    _saveCheckStatus(waterCheck);
                  });
                },
              ),
            CheckboxListTile(
              title: Text('환기하기'),
              value: ventilationCheck,
              onChanged: (val) {
                setState(() {
                  ventilationCheck = val!;
                  _saveCheckStatus(ventilationCheck);
                });
              },
            ),
            CheckboxListTile(
              title: Text('향기 좋다고 칭찬하기'),
              value: LuvCheck,
              onChanged: (val) {
                setState(() {
                  LuvCheck = val!;
                  _saveCheckStatus(LuvCheck);
                });
              },
            ),
            if (repotCheckBox)
              CheckboxListTile(
                title: Text('분갈이하기'),
                value: repotCheck,
                onChanged: (val) {
                  setState(() {
                    repotCheck = val!;
                    _saveCheckStatus(repotCheck);
                  });
                },
              ),
            if (pruneCheckBox)
              CheckboxListTile(
                title: Text('가지치기'),
                value: pruneCheck,
                onChanged: (val) {
                  setState(() {
                    pruneCheck = val!;
                    _saveCheckStatus(pruneCheck);
                  });
                },
              ),
            if (nutritionCheckBox)
              CheckboxListTile(
                title: Text('영양 관리'),
                value: nutritionCheck,
                onChanged: (val) {
                  setState(() {
                    nutritionCheck = val!;
                    _saveCheckStatus(nutritionCheck);
                  });
                },
              ),
            if (harvestCheckBox)
              CheckboxListTile(
                title: Text('수확하기'),
                value: harvestCheck,
                onChanged: (val) {
                  setState(() {
                    harvestCheck = val!;
                    _saveCheckStatus(harvestCheck);
                  });
                },
              ),
          ]
          else if (widget.selectedValue == '로즈마리') ...[
              if (daysSinceLastCheck >= 4 || daysSinceLastCheck == 0)
                CheckboxListTile(
                  title: Text('물 주기'),
                  value: waterCheck,
                  onChanged: (val) {
                    setState(() {
                      waterCheck = val!;
                      _saveCheckStatus(waterCheck);
                    });
                  },
                ),
              CheckboxListTile(
                title: Text('환기하기'),
                value: ventilationCheck,
                onChanged: (val) {
                  setState(() {
                    ventilationCheck = val!;
                    _saveCheckStatus(ventilationCheck);
                  });
                },
              ),
              CheckboxListTile(
                title: Text('향기 좋다고 칭찬하기'),
                value: LuvCheck,
                onChanged: (val) {
                  setState(() {
                    LuvCheck = val!;
                    _saveCheckStatus(LuvCheck);
                  });
                },
              ),
              if (repotCheckBox)
                CheckboxListTile(
                  title: Text('분갈이하기'),
                  value: repotCheck,
                  onChanged: (val) {
                    setState(() {
                      repotCheck = val!;
                      _saveCheckStatus(repotCheck);
                    });
                  },
                ),
              if (pruneCheckBox)
                CheckboxListTile(
                  title: Text('가지치기'),
                  value: pruneCheck,
                  onChanged: (val) {
                    setState(() {
                      pruneCheck = val!;
                      _saveCheckStatus(pruneCheck);
                    });
                  },
                ),
              if (nutritionCheckBox)
                CheckboxListTile(
                  title: Text('영양 관리'),
                  value: nutritionCheck,
                  onChanged: (val) {
                    setState(() {
                      nutritionCheck = val!;
                      _saveCheckStatus(nutritionCheck);
                    });
                  },
                ),
              if (harvestCheckBox)
                CheckboxListTile(
                  title: Text('수확하기'),
                  value: harvestCheck,
                  onChanged: (val) {
                    setState(() {
                      harvestCheck = val!;
                      _saveCheckStatus(harvestCheck);
                    });
                  },
                ),
            ]
            else if (widget.selectedValue == '세이지') ...[
                if (daysSinceLastCheck >= 4 || daysSinceLastCheck == 0)
                  CheckboxListTile(
                    title: Text('물 주기'),
                    value: waterCheck,
                    onChanged: (val) {
                      setState(() {
                        waterCheck = val!;
                        _saveCheckStatus(waterCheck);
                      });
                    },
                  ),
                CheckboxListTile(
                  title: Text('환기하기'),
                  value: ventilationCheck,
                  onChanged: (val) {
                    setState(() {
                      ventilationCheck = val!;
                      _saveCheckStatus(ventilationCheck);
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('향기 좋다고 칭찬하기'),
                  value: LuvCheck,
                  onChanged: (val) {
                    setState(() {
                      LuvCheck = val!;
                      _saveCheckStatus(LuvCheck);
                    });
                  },
                ),
                if (repotCheckBox)
                  CheckboxListTile(
                    title: Text('분갈이하기'),
                    value: repotCheck,
                    onChanged: (val) {
                      setState(() {
                        repotCheck = val!;
                        _saveCheckStatus(repotCheck);
                      });
                    },
                  ),
                if (pruneCheckBox)
                  CheckboxListTile(
                    title: Text('가지치기'),
                    value: pruneCheck,
                    onChanged: (val) {
                      setState(() {
                        pruneCheck = val!;
                        _saveCheckStatus(pruneCheck);
                      });
                    },
                  ),
                if (nutritionCheckBox)
                  CheckboxListTile(
                    title: Text('영양 관리'),
                    value: nutritionCheck,
                    onChanged: (val) {
                      setState(() {
                        nutritionCheck = val!;
                        _saveCheckStatus(nutritionCheck);
                      });
                    },
                  ),
                if (harvestCheckBox)
                  CheckboxListTile(
                    title: Text('수확하기'),
                    value: harvestCheck,
                    onChanged: (val) {
                      setState(() {
                        harvestCheck = val!;
                        _saveCheckStatus(harvestCheck);
                      });
                    },
                  ),
              ]
              else if (widget.selectedValue == '스위트 바질') ...[
                  if (daysSinceLastCheck >= 4 || daysSinceLastCheck == 0)
                    CheckboxListTile(
                      title: Text('물 주기'),
                      value: waterCheck,
                      onChanged: (val) {
                        setState(() {
                          waterCheck = val!;
                          _saveCheckStatus(waterCheck);
                        });
                      },
                    ),
                  CheckboxListTile(
                    title: Text('환기하기'),
                    value: ventilationCheck,
                    onChanged: (val) {
                      setState(() {
                        ventilationCheck = val!;
                        _saveCheckStatus(ventilationCheck);
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('향기 좋다고 칭찬하기'),
                    value: LuvCheck,
                    onChanged: (val) {
                      setState(() {
                        LuvCheck = val!;
                        _saveCheckStatus(LuvCheck);
                      });
                    },
                  ),
                  if (repotCheckBox)
                    CheckboxListTile(
                      title: Text('분갈이하기'),
                      value: repotCheck,
                      onChanged: (val) {
                        setState(() {
                          repotCheck = val!;
                          _saveCheckStatus(repotCheck);
                        });
                      },
                    ),
                  if (pruneCheckBox)
                    CheckboxListTile(
                      title: Text('가지치기'),
                      value: pruneCheck,
                      onChanged: (val) {
                        setState(() {
                          pruneCheck = val!;
                          _saveCheckStatus(pruneCheck);
                        });
                      },
                    ),
                  if (nutritionCheckBox)
                    CheckboxListTile(
                      title: Text('영양 관리'),
                      value: nutritionCheck,
                      onChanged: (val) {
                        setState(() {
                          nutritionCheck = val!;
                          _saveCheckStatus(nutritionCheck);
                        });
                      },
                    ),
                  if (harvestCheckBox)
                    CheckboxListTile(
                      title: Text('수확하기'),
                      value: harvestCheck,
                      onChanged: (val) {
                        setState(() {
                          harvestCheck = val!;
                          _saveCheckStatus(harvestCheck);
                        });
                      },
                    ),
                ]
                else if (widget.selectedValue == '애플민트') ...[
                    if (daysSinceLastCheck >= 4 || daysSinceLastCheck == 0)
                      CheckboxListTile(
                        title: Text('물 주기'),
                        value: waterCheck,
                        onChanged: (val) {
                          setState(() {
                            waterCheck = val!;
                            _saveCheckStatus(waterCheck);
                          });
                        },
                      ),
                    CheckboxListTile(
                      title: Text('환기하기'),
                      value: ventilationCheck,
                      onChanged: (val) {
                        setState(() {
                          ventilationCheck = val!;
                          _saveCheckStatus(ventilationCheck);
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('향기 좋다고 칭찬하기'),
                      value: LuvCheck,
                      onChanged: (val) {
                        setState(() {
                          LuvCheck = val!;
                          _saveCheckStatus(LuvCheck);
                        });
                      },
                    ),
                    if (repotCheckBox)
                      CheckboxListTile(
                        title: Text('분갈이하기'),
                        value: repotCheck,
                        onChanged: (val) {
                          setState(() {
                            repotCheck = val!;
                            _saveCheckStatus(repotCheck);
                          });
                        },
                      ),
                    if (pruneCheckBox)
                      CheckboxListTile(
                        title: Text('가지치기'),
                        value: pruneCheck,
                        onChanged: (val) {
                          setState(() {
                            pruneCheck = val!;
                            _saveCheckStatus(pruneCheck);
                          });
                        },
                      ),
                    if (nutritionCheckBox)
                      CheckboxListTile(
                        title: Text('영양 관리'),
                        value: nutritionCheck,
                        onChanged: (val) {
                          setState(() {
                            nutritionCheck = val!;
                            _saveCheckStatus(nutritionCheck);
                          });
                        },
                      ),
                    if (harvestCheckBox)
                      CheckboxListTile(
                        title: Text('수확하기'),
                        value: harvestCheck,
                        onChanged: (val) {
                          setState(() {
                            harvestCheck = val!;
                            _saveCheckStatus(harvestCheck);
                          });
                        },
                      ),
                  ]
                  else if (widget.selectedValue == '케모마일') ...[
                      if (daysSinceLastCheck >= 4 || daysSinceLastCheck == 0)
                        CheckboxListTile(
                          title: Text('물 주기'),
                          value: waterCheck,
                          onChanged: (val) {
                            setState(() {
                              waterCheck = val!;
                              _saveCheckStatus(waterCheck);
                            });
                          },
                        ),
                      CheckboxListTile(
                        title: Text('환기하기'),
                        value: ventilationCheck,
                        onChanged: (val) {
                          setState(() {
                            ventilationCheck = val!;
                            _saveCheckStatus(ventilationCheck);
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('향기 좋다고 칭찬하기'),
                        value: LuvCheck,
                        onChanged: (val) {
                          setState(() {
                            LuvCheck = val!;
                            _saveCheckStatus(LuvCheck);
                          });
                        },
                      ),
                      if (repotCheckBox)
                        CheckboxListTile(
                          title: Text('분갈이하기'),
                          value: repotCheck,
                          onChanged: (val) {
                            setState(() {
                              repotCheck = val!;
                              _saveCheckStatus(repotCheck);
                            });
                          },
                        ),
                      if (pruneCheckBox)
                        CheckboxListTile(
                          title: Text('가지치기'),
                          value: pruneCheck,
                          onChanged: (val) {
                            setState(() {
                              pruneCheck = val!;
                              _saveCheckStatus(pruneCheck);
                            });
                          },
                        ),
                      if (nutritionCheckBox)
                        CheckboxListTile(
                          title: Text('영양 관리'),
                          value: nutritionCheck,
                          onChanged: (val) {
                            setState(() {
                              nutritionCheck = val!;
                              _saveCheckStatus(nutritionCheck);
                            });
                          },
                        ),
                      if (harvestCheckBox)
                        CheckboxListTile(
                          title: Text('수확하기'),
                          value: harvestCheck,
                          onChanged: (val) {
                            setState(() {
                              harvestCheck = val!;
                              _saveCheckStatus(harvestCheck);
                            });
                          },
                        ),
                    ]
                    else if (widget.selectedValue == '페퍼민트') ...[
                        if (daysSinceLastCheck >= 4 || daysSinceLastCheck == 0)
                          CheckboxListTile(
                            title: Text('물 주기'),
                            value: waterCheck,
                            onChanged: (val) {
                              setState(() {
                                waterCheck = val!;
                                _saveCheckStatus(waterCheck);
                              });
                            },
                          ),
                        CheckboxListTile(
                          title: Text('환기하기'),
                          value: ventilationCheck,
                          onChanged: (val) {
                            setState(() {
                              ventilationCheck = val!;
                              _saveCheckStatus(ventilationCheck);
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text('향기 좋다고 칭찬하기'),
                          value: LuvCheck,
                          onChanged: (val) {
                            setState(() {
                              LuvCheck = val!;
                              _saveCheckStatus(LuvCheck);
                            });
                          },
                        ),
                        if (repotCheckBox)
                          CheckboxListTile(
                            title: Text('분갈이하기'),
                            value: repotCheck,
                            onChanged: (val) {
                              setState(() {
                                repotCheck = val!;
                                _saveCheckStatus(repotCheck);
                              });
                            },
                          ),
                        if (pruneCheckBox)
                          CheckboxListTile(
                            title: Text('가지치기'),
                            value: pruneCheck,
                            onChanged: (val) {
                              setState(() {
                                pruneCheck = val!;
                                _saveCheckStatus(pruneCheck);
                              });
                            },
                          ),
                        if (nutritionCheckBox)
                          CheckboxListTile(
                            title: Text('영양 관리'),
                            value: nutritionCheck,
                            onChanged: (val) {
                              setState(() {
                                nutritionCheck = val!;
                                _saveCheckStatus(nutritionCheck);
                              });
                            },
                          ),
                        if (harvestCheckBox)
                          CheckboxListTile(
                            title: Text('수확하기'),
                            value: harvestCheck,
                            onChanged: (val) {
                              setState(() {
                                harvestCheck = val!;
                                _saveCheckStatus(harvestCheck);
                              });
                            },
                          ),
                      ],

          SizedBox(height: 16.0),
          ButtonBar(
            //alignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: Text(
                  "+ 할 일 추가",
                  style: TextStyle(
                    color: Color(0xFF2E2B32),
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddCKListBtnDialog(
                        onCheckBoxStatesChanged: (Map<String,
                            bool> checkBoxStates) {
                          setState(() {
                            repotCheckBox =
                                checkBoxStates['repotCheckBox'] ?? false;
                            pruneCheckBox =
                                checkBoxStates['pruneCheckBox'] ?? false;
                            nutritionCheckBox =
                                checkBoxStates['nutritionCheckBox'] ?? false;
                            harvestCheckBox =
                                checkBoxStates['harvestCheckBox'] ?? false;
                          });
                        },
                      );
                    },
                  );
                },
              ),
              TextButton(
                child: Text(
                  "확인",
                  style: TextStyle(
                    color: Color(0xFF2E2B32),
                  ),
                ),
                onPressed: () async{
                  await _onCheckConfirmed();
                  // if (!waterCheck) {
                  //   _MessageSetting(
                  //       hour: 20, minutes: 0, message: '내 식물에게 아직 물을 주지 않았어요!');
                  // }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAdditionalPages(List<String> selectedValues) {
    if (selectedValues.isEmpty) {
      return []; // 빈 리스트를 반환하여 페이지를 추가하지 않음
    }

    return selectedValues.map((value) {
      if (repotChecksBox[value] == false) {
        repotChecks[value] = false;
        _saveChecksStatus(value, false!);
      }

      if(pruneChecksBox[value] == false) {
        pruneChecks[value] = false;
        _saveChecksStatus(value, false!);
      }

      if (nutritionChecksBox[value] == false) {
        nutritionChecks[value] = false;
        _saveChecksStatus(value, false!);
      }

      if (harvestChecksBox[value] == false) {
        harvestChecks[value] = false;
        _saveChecksStatus(value, false!);
      }

      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2B32),
                      ),
                    ),
                  SizedBox(height: 16.0,),
                //if (value == '레몬 밤') ...[
                  //if (daysSinceLastCheck >= 5 || daysSinceLastCheck == 0)
                    CheckboxListTile(
                      title: Text('물 주기'),
                      value: waterChecks[value] ?? false,
                      onChanged: (val) {
                        setState(() {
                          waterChecks[value] = val!;
                          _saveChecksStatus(value, val!);
                        });
                      },
                    ),
                  CheckboxListTile(
                    title: Text('환기하기'),
                    value: ventilationChecks[value] ?? false,
                    onChanged: (val) {
                      setState(() {
                        ventilationChecks[value] = val!;
                        _saveChecksStatus(value, val!);
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('향기 좋다고 칭찬하기'),
                    value: LuvChecks[value] ?? false,
                    onChanged: (val) {
                      setState(() {
                        LuvChecks[value] = val!;
                        _saveChecksStatus(value, val!);
                      });
                    },
                  ),
                  if (repotChecksBox[value] == true)
                    CheckboxListTile(
                      title: Text('분갈이하기'),
                      value: repotChecks[value] ?? false,
                      onChanged: (val) {
                        setState(() {
                          repotChecks[value] = val!;
                          _saveChecksStatus(value, val!);
                        });
                      },
                    ),
                if (pruneChecksBox[value] == true)
                  CheckboxListTile(
                    title: Text('가지치기'),
                    value: pruneChecks[value] ?? false,
                    onChanged: (val) {
                      setState(() {
                        pruneChecks[value] = val!;
                        _saveChecksStatus(value, val!);
                      });
                    },
                  ),
                if (nutritionChecksBox[value] == true)
                  CheckboxListTile(
                    title: Text('영양관리'),
                    value: nutritionChecks[value] ?? false,
                    onChanged: (val) {
                      setState(() {
                        nutritionChecks[value] = val!;
                        _saveChecksStatus(value, val!);
                      });
                    },
                  ),
                if (harvestChecksBox[value] == true)
                  CheckboxListTile(
                    title: Text('수확하기'),
                    value: harvestChecks[value] ?? false,
                    onChanged: (val) {
                      setState(() {
                        harvestChecks[value] = val!;
                        _saveChecksStatus(value, val!);
                      });
                    },
                  ),
                //],
                SizedBox(height: 16.0),

                ButtonBar(
                  children: [
                    TextButton(
                      child: Text(
                        "+ 할 일 추가",
                        style: TextStyle(
                          color: Color(0xFF2E2B32),
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AddCKListBtnDialog2(
                              onCheckBoxStatesChanged: (Map<String, bool> checkBoxStates) {
                                setState(() {
                                  repotChecksBox[value] = checkBoxStates['repot'] ?? false;
                                  pruneChecksBox[value] = checkBoxStates['prune'] ?? false;
                                  nutritionChecksBox[value] = checkBoxStates['nutrition'] ?? false;
                                  harvestChecksBox[value] = checkBoxStates['harvest'] ?? false;

                                  _saveChecksStatus(value, repotChecksBox[value]!);
                                  _saveChecksStatus(value, pruneChecksBox[value]!);
                                  _saveChecksStatus(value, nutritionChecksBox[value]!);
                                  _saveChecksStatus(value, harvestChecksBox[value]!);
                                });
                              },
                              // initialCheckStates: {
                              //   'repot': repotChecksBox[value] ?? false,
                              //   'prune': pruneChecksBox[value] ?? false,
                              // },
                              value: value,
                            );
                          },
                        );
                      },
                    ),
                    TextButton(
                      child: Text(
                        "확인",
                        style: TextStyle(
                          color: Color(0xFF2E2B32),
                        ),
                      ),
                      onPressed: () {
                        _onCheckConfirmed(); // '확인' 버튼 클릭 시 호출
                        Navigator.of(context).pop();
                        print('Current keys in repotChecksBox: ${repotChecksBox.keys}');
                      },
                    ),
                  ],
                ),

            ],
          ),
      );
    }).toList();
  }
}