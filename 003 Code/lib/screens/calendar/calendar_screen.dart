import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:testproject/screens/calendar/components/calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final now = DateTime.now();
  bool syncButtonVisible = true; // 동기화 버튼 가시성

  bool waterCheck = false;
  bool LuvCheck = false;
  bool ventilationCheck = false;

  bool repotCheck = false; // 분갈이하기 초기값
  bool pruneCheck = false; // 가지치기 초기값
  bool nutritionCheck = false; // 영양 관리 초기값
  bool harvestCheck = false; // 수확하기 초기값

  late Map<String, bool> waterChecks;
  late Map<String, bool> LuvChecks;
  late Map<String, bool> ventilationChecks;
  late Map<String, bool> repotChecks;

  String selectedValuePrefs = "식물 미등록";
  List<String> selectedValues2 = [];

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/calendar.events'],
  );

  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _trySilentSignIn(); // 자동 로그인 시도
    _loadSavedValue();

    waterChecks = {for (var value in selectedValues2) value: false};
    LuvChecks = {for (var value in selectedValues2) value: false};
    ventilationChecks = {for (var value in selectedValues2) value: false};

    repotChecks = {for (var value in selectedValues2) value: false};
  }

  void _trySilentSignIn() async {
    try {
      await _googleSignIn.signInSilently(); // 자동 로그인 시도
    } catch (error) {
      print('자동 로그인이 실패했습니다: $error');
    }
  }

  _loadSavedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = DateFormat('yyyy-MM-dd').format(selectedDate);
    print(key);

    setState(() {
      LuvCheck = prefs.getBool('$key LUVChecked') ?? false;
      waterCheck = prefs.getBool('$key waterChecked') ?? false;
      ventilationCheck = prefs.getBool('$key ventilationChecked') ?? false;

      repotCheck = prefs.getBool('$key repotChecked') ?? false;
      pruneCheck = prefs.getBool('$key pruneChecked') ?? false;
      nutritionCheck = prefs.getBool('$key nutritionChecked') ?? false;
      harvestCheck = prefs.getBool('$key harvestChecked') ?? false;

      selectedValuePrefs = prefs.getString('SelectedValue') ?? '';
      selectedValues2 = prefs.getStringList('SelectedValues2') ?? [];

      waterChecks = _loadChecks(prefs, '$key waterChecked2');
      LuvChecks = _loadChecks(prefs, '$key LuvChecked2');
      ventilationChecks = _loadChecks(prefs, '$key ventilationChecked2');
      repotChecks = _loadChecks(prefs, '$key repotChecked2');

      syncButtonVisible = prefs.getBool('$key syncButtonVisible') ?? true;

      String? waterChecksString = prefs.getString('$key waterChecked2');
      if (waterChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(waterChecksString);
        waterChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        waterChecks = {for (var value in selectedValues2) value: false};
      }

      String? LuvChecksString = prefs.getString('$key LuvChecked2');
      if (LuvChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(LuvChecksString);
        LuvChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        LuvChecks = {for (var value in selectedValues2) value: false};
      }

      String? ventilationChecksString = prefs.getString('$key ventilationChecked2');
      if (ventilationChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(ventilationChecksString);
        ventilationChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        ventilationChecks = {for (var value in selectedValues2) value: false};
      }

      String? repotChecksString = prefs.getString('$key repotChecked2');
      if (repotChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(repotChecksString);
        repotChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        repotChecks = {for (var value in selectedValues2) value: false};
      }
    });
  }

  Map<String, bool> _loadChecks(SharedPreferences prefs, String key) {
    String? checksString = prefs.getString(key);
    if (checksString != null) {
      Map<String, dynamic> jsonMap = json.decode(checksString);
      return jsonMap.map((key, value) => MapEntry(key, value as bool));
    } else {
      return {for (var value in selectedValues2) value: false};
    }
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      this.selectedDate = selectedDate;
      _loadSavedValue();
    });
  }

  Future<void> _addEventToCalendar(String herb, int cnt, String summary, String description) async {
    if (_currentUser == null) return;

    try {
      final authHeaders = await _currentUser!.authHeaders;
      final client = GoogleHttpClient(authHeaders);
      final calendarApi = calendar.CalendarApi(client);

      final event = calendar.Event(
        // id: 'event-$selectedDate-$cnt-id',
        summary: summary,
        description: description,
        start: calendar.EventDateTime(
          dateTime: selectedDate,  // 사용자가 선택한 날짜로 설정
          timeZone: 'GMT+09:00',
        ),
        end: calendar.EventDateTime(
          dateTime: selectedDate.add(Duration(hours: 1)),  // 1시간 후로 종료 시간 설정
          timeZone: 'GMT+09:00',
        ),
      );

      await calendarApi.events.insert(event, 'primary');
      print('Event added to Google Calendar');
    } catch (error) {
      print('Error adding event: $error');
    }
  }

  Future<void> _checkAndSyncChecklist() async {
    if (_currentUser == null) {
      await _googleSignIn.signIn(); // 로그인 시도
      if (_currentUser == null) {
        // 로그인 실패 또는 취소 시 사용자에게 알림
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('로그인 필요'),
            content: Text('Google 계정에 로그인해야 동기화할 수 있습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('확인'),
              ),
            ],
          ),
        );
        return; // 동기화 중단
      }
    }

    // 로그인 성공 후 체크리스트 동기화
    if (waterCheck) {
      await _addEventToCalendar(selectedValuePrefs, 1, '물을 줬어요', '$selectedValuePrefs에 물을 준 날입니다.');
    }
    if (ventilationCheck) {
      await _addEventToCalendar(selectedValuePrefs, 2, '환기했어요', '$selectedValuePrefs 환기한 날입니다.');
    }
    if (repotCheck) {
      await _addEventToCalendar(selectedValuePrefs, 3, '분갈이했어요', '$selectedValuePrefs 분갈이한 날입니다.');
    }
    if (pruneCheck) {
      await _addEventToCalendar(selectedValuePrefs, 4, '가지치기했어요', '$selectedValuePrefs 가지치기한 날입니다.');
    }
    if (nutritionCheck) {
      await _addEventToCalendar(selectedValuePrefs, 5, '영양 관리했어요', '$selectedValuePrefs 영양을 준 날입니다.');
    }
    if (harvestCheck) {
      await _addEventToCalendar(selectedValuePrefs, 6, '수확했어요', '$selectedValuePrefs 수확한 날입니다.');
    }

    // 두 번째 등록 허브
    if(selectedValues2.isNotEmpty && waterChecks[selectedValues2[0]] == true)
      await _addEventToCalendar(selectedValues2[0], 7, '물을 줬어요', '${selectedValues2[0]}에 물을 준 날입니다.');
    if(selectedValues2.isNotEmpty && ventilationChecks[selectedValues2[0]] == true)
      await _addEventToCalendar(selectedValues2[0], 8, '환기했어요', '${selectedValues2[0]} 환기한 날입니다.');
    if(selectedValues2.isNotEmpty && repotChecks[selectedValues2[0]] == true)
      await _addEventToCalendar(selectedValues2[0], 9, '분갈이했어요', '${selectedValues2[0]} 분갈이한 날입니다.');

    // 세 번째 등록 허브
    if(selectedValues2.length > 1 && waterChecks[selectedValues2[1]] == true)
      await _addEventToCalendar(selectedValues2[1], 7, '물을 줬어요', '${selectedValues2[1]}에 물을 준 날입니다.');
    if(selectedValues2.length > 1 && ventilationChecks[selectedValues2[1]] == true)
      await _addEventToCalendar(selectedValues2[1], 8, '환기했어요', '${selectedValues2[1]} 환기한 날입니다.');
    if(selectedValues2.length > 1 && repotChecks[selectedValues2[1]] == true)
      await _addEventToCalendar(selectedValues2[1], 9, '분갈이했어요', '${selectedValues2[1]} 분갈이한 날입니다.');

    // 네 번째 등록 허브
    if(selectedValues2.length > 2 && waterChecks[selectedValues2[2]] == true)
      await _addEventToCalendar(selectedValues2[2], 7, '물을 줬어요', '${selectedValues2[2]}에 물을 준 날입니다.');
    if(selectedValues2.length > 2 && ventilationChecks[selectedValues2[2]] == true)
      await _addEventToCalendar(selectedValues2[2], 8, '환기했어요', '${selectedValues2[2]} 환기한 날입니다.');
    if(selectedValues2.length > 2 && repotChecks[selectedValues2[2]] == true)
      await _addEventToCalendar(selectedValues2[2], 9, '분갈이했어요', '${selectedValues2[2]} 분갈이한 날입니다.');

    // 다섯 번째 등록 허브
    if(selectedValues2.length > 3 && waterChecks[selectedValues2[3]] == true)
      await _addEventToCalendar(selectedValues2[3], 7, '물을 줬어요', '${selectedValues2[3]}에 물을 준 날입니다.');
    if(selectedValues2.length > 3 && ventilationChecks[selectedValues2[3]] == true)
      await _addEventToCalendar(selectedValues2[3], 8, '환기했어요', '${selectedValues2[3]} 환기한 날입니다.');
    if(selectedValues2.length > 3 && repotChecks[selectedValues2[3]] == true)
      await _addEventToCalendar(selectedValues2[3], 9, '분갈이했어요', '${selectedValues2[3]} 분갈이한 날입니다.');

    // 동기화 후 버튼 감추기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = DateFormat('yyyy-MM-dd').format(selectedDate);
    await prefs.setBool('$key syncButtonVisible', false);

    setState(() {
      syncButtonVisible = false; // 버튼 숨기기
    });

  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MM월 dd일').format(selectedDate);
    bool isPastDate = selectedDate.isBefore(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(

        child:SingleChildScrollView(
        child: Column(
          children: [
            Calendar(selectedDate: selectedDate, onDaySelected: onDaySelected,),
            SizedBox(height: 2.0,),
            Row(
              children: [
                SizedBox(width: 45),
                Text(
                  '$formattedDate',
                  style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF2C2C2C)),
                      //fontWeight: FontWeight.bold,
                ),
              ],
            ),

            SizedBox(height: 17.0),


            if (selectedValues2.isNotEmpty)
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 45),
                      Text(
                        selectedValuePrefs,
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 17.0),

            if (waterCheck)
              _buildChecklistItem(Icons.water_drop, '물을 줬어요', Color(0xFF75C5F2)),
            if (ventilationCheck)
              _buildChecklistItem(Icons.air, '환기했어요', Colors.green),
            if (repotCheck)
              _buildChecklistItem(Icons.nature, '분갈이했어요', Colors.brown),
            if (pruneCheck)
              _buildChecklistItem(Icons.cut, '가지치기했어요', Colors.red),
            if (nutritionCheck)
              _buildChecklistItem(Icons.eco, '영양 관리했어요', Colors.yellow),
            if (harvestCheck)
              _buildChecklistItem(Icons.grass, '수확했어요', Colors.orange),


            // if(waterCheck == true)
            //   Column(
            //     children: [
            //     Row(
            //       children: [
            //         SizedBox(width: 40),
            //         Icon(Icons.water_drop,
            //         color: Color(0xFF75C5F2)),
            //         SizedBox(width: 10),
            //         Text(
            //           //'선택된 날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
            //           '물을 줬어요',
            //           style: TextStyle(
            //             fontSize: 16,
            //             color: Color(0xFF2B2B2B),
            //           ),
            //         ),
            //       ],
            //     ),
            //     SizedBox(height: 2),
            //     Divider(
            //       thickness: 1, // 밑줄의 두께 설정
            //       indent: 40, // 시작 부분의 간격 설정
            //       endIndent: 40, // 끝 부분의 간격 설정
            //       color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //       ),
            //       SizedBox(height: 5.0,)
            //     ],
            //   ),
            //
            // if(ventilationCheck == true)
            //   Column(
            //     children: [
            //       Row(
            //         children: [
            //           SizedBox(width: 40),
            //           Icon(Icons.wind_power,
            //             color: Color(0xFF99DA79)),
            //           SizedBox(width: 10),
            //           Text(
            //             //'선택된 날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
            //             '환기를 했어요',
            //             style: TextStyle(
            //               fontSize: 16,
            //               color: Color(0xFF2B2B2B),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 2),
            //       Divider(
            //         thickness: 1, // 밑줄의 두께 설정
            //         indent: 40, // 시작 부분의 간격 설정
            //         endIndent: 40, // 끝 부분의 간격 설정
            //         color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //       ),
            //       SizedBox(height: 5.0,)
            //     ],
            //   ),
            //
            // if(repotCheck == true)
            //   Column(
            //     children: [
            //       Row(
            //         children: [
            //           SizedBox(width: 40),
            //           Icon(Icons.grass,
            //               color: Color(0xFFA88E82)),
            //           SizedBox(width: 10),
            //           Text(
            //             '분갈이를 했어요',
            //             style: TextStyle(
            //               fontSize: 16,
            //               color: Color(0xFF2B2B2B),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 2),
            //       Divider(
            //         thickness: 1, // 밑줄의 두께 설정
            //         indent: 40, // 시작 부분의 간격 설정
            //         endIndent: 40, // 끝 부분의 간격 설정
            //         color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //       ),
            //       SizedBox(height: 5.0,)
            //     ],
            //   ),
            //
            // if(pruneCheck == true)
            //   Column(
            //     children: [
            //       Row(
            //         children: [
            //           SizedBox(width: 40),
            //           Icon(Icons.content_cut,
            //               color: Color(0xFFF27575)),
            //           SizedBox(width: 10),
            //           Text(
            //             '가지치기를 했어요',
            //             style: TextStyle(
            //               fontSize: 16,
            //               color: Color(0xFF2B2B2B),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 2),
            //       Divider(
            //         thickness: 1, // 밑줄의 두께 설정
            //         indent: 40, // 시작 부분의 간격 설정
            //         endIndent: 40, // 끝 부분의 간격 설정
            //         color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //       ),
            //       SizedBox(height: 5.0,)
            //     ],
            //   ),
            //
            // if(nutritionCheck == true)
            //   Column(
            //     children: [
            //       Row(
            //         children: [
            //           SizedBox(width: 40),
            //           Icon(Icons.add_reaction,
            //               color: Color(0xFFF2C675)),
            //           SizedBox(width: 10),
            //           Text(
            //             '영양관리를 했어요',
            //               style: TextStyle(
            //               fontSize: 16,
            //               color: Color(0xFF2B2B2B),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 2),
            //       Divider(
            //         thickness: 1, // 밑줄의 두께 설정
            //         indent: 40, // 시작 부분의 간격 설정
            //         endIndent: 40, // 끝 부분의 간격 설정
            //         color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //       ),
            //       SizedBox(height: 5.0,)
            //     ],
            //   ),
            //
            // if(harvestCheck == true)
            //   Column(
            //     children: [
            //       Row(
            //         children: [
            //           SizedBox(width: 40),
            //           Icon(Icons.compost,
            //               color: Color(0xFFD3B6E0)),
            //           SizedBox(width: 10),
            //           Text(
            //             '수확을 했어요',
            //             style: TextStyle(
            //               fontSize: 16,
            //               color: Color(0xFF2B2B2B),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 2),
            //       Divider(
            //         thickness: 1, // 밑줄의 두께 설정
            //         indent: 40, // 시작 부분의 간격 설정
            //         endIndent: 40, // 끝 부분의 간격 설정
            //         color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //       ),
            //       SizedBox(height: 5.0,)
            //     ],
            //   ),

            SizedBox(height: 12.0,),

            // 두 번째 등록 허브
            if (selectedValues2.isNotEmpty)
            Row(
              children: [
                SizedBox(width: 45),
                Text(
                  '${selectedValues2[0]}',
                  style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF2C2C2C)),
                ),
              ],
            ),

            SizedBox(height: 12.0,),

            // if(selectedValues2.isNotEmpty && waterChecks[selectedValues2[0]] == true)
            //   Column(
            //     children: [
            //       Row(
            //         children: [
            //           SizedBox(width: 40),
            //           Icon(Icons.water_drop,
            //               color: Color(0xFF75C5F2)),
            //           SizedBox(width: 10),
            //           Text(
            //             //'선택된 날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
            //             '물을 줬어요',
            //             style: TextStyle(
            //               fontSize: 16,
            //               color: Color(0xFF2B2B2B),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 2),
            //       Divider(
            //         thickness: 1, // 밑줄의 두께 설정
            //         indent: 40, // 시작 부분의 간격 설정
            //         endIndent: 40, // 끝 부분의 간격 설정
            //         color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //       ),
            //       SizedBox(height: 5.0,)
            //     ],
            //   ),
            // if(selectedValues2.isNotEmpty && ventilationChecks[selectedValues2[0]] == true)
            //   Column(
            //     children: [
            //       Row(
            //         children: [
            //           SizedBox(width: 40),
            //           Icon(Icons.wind_power,
            //               color: Color(0xFF99DA79)),
            //           SizedBox(width: 10),
            //           Text(
            //             //'선택된 날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
            //             '환기를 했어요',
            //             style: TextStyle(
            //               fontSize: 16,
            //               color: Color(0xFF2B2B2B),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 2),
            //       Divider(
            //         thickness: 1, // 밑줄의 두께 설정
            //         indent: 40, // 시작 부분의 간격 설정
            //         endIndent: 40, // 끝 부분의 간격 설정
            //         color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //       ),
            //       SizedBox(height: 5.0,)
            //     ],
            //   ),
            //
            // if(selectedValues2.isNotEmpty && repotChecks[selectedValues2[0]] == true)
            //   Column(
            //     children: [
            //       Row(
            //         children: [
            //           SizedBox(width: 40),
            //           Icon(Icons.grass,
            //               color: Color(0xFFA88E82)),
            //           SizedBox(width: 10),
            //           Text(
            //             '분갈이를 했어요',
            //             style: TextStyle(
            //               fontSize: 16,
            //               color: Color(0xFF2B2B2B),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 2),
            //       Divider(
            //         thickness: 1, // 밑줄의 두께 설정
            //         indent: 40, // 시작 부분의 간격 설정
            //         endIndent: 40, // 끝 부분의 간격 설정
            //         color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //       ),
            //       SizedBox(height: 5.0,)
            //     ],
            //   ),
            if(selectedValues2.isNotEmpty && waterChecks[selectedValues2[0]] == true)
              _buildChecklistItem(Icons.water_drop, '물을 줬어요', Color(0xFF75C5F2)),
            if(selectedValues2.isNotEmpty && ventilationChecks[selectedValues2[0]] == true)
              _buildChecklistItem(Icons.air, '환기했어요', Colors.green),
            if(selectedValues2.isNotEmpty && repotChecks[selectedValues2[0]] == true)
              _buildChecklistItem(Icons.nature, '분갈이했어요', Colors.brown),

            SizedBox(height: 12.0,),


            // 세 번째 등록 허브
            if (selectedValues2.length > 1)
              Row(
                children: [
                  SizedBox(width: 45),
                  Text(
                    '${selectedValues2[1]}',
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF2C2C2C)),
                  ),
                ],
              ),

            SizedBox(height: 12.0,),

            // if(selectedValues2.length > 1)
            //   if(waterChecks[selectedValues2[1]] == true)
            //     Column(
            //     children: [
            //       Row(
            //         children: [
            //           SizedBox(width: 40),
            //           Icon(Icons.water_drop,
            //               color: Color(0xFF75C5F2)),
            //           SizedBox(width: 10),
            //           Text(
            //             //'선택된 날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
            //             '물을 줬어요',
            //             style: TextStyle(
            //               fontSize: 16,
            //               color: Color(0xFF2B2B2B),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 2),
            //       Divider(
            //         thickness: 1, // 밑줄의 두께 설정
            //         indent: 40, // 시작 부분의 간격 설정
            //         endIndent: 40, // 끝 부분의 간격 설정
            //         color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //       ),
            //       SizedBox(height: 5.0,)
            //     ],
            //   ),
            // if(selectedValues2.length > 1)
            //   if(ventilationChecks[selectedValues2[1]] == true)
            //     Column(
            //     children: [
            //       Row(
            //         children: [
            //           SizedBox(width: 40),
            //           Icon(Icons.wind_power,
            //               color: Color(0xFF99DA79)),
            //           SizedBox(width: 10),
            //           Text(
            //             //'선택된 날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
            //             '환기를 했어요',
            //             style: TextStyle(
            //               fontSize: 16,
            //               color: Color(0xFF2B2B2B),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 2),
            //       Divider(
            //         thickness: 1, // 밑줄의 두께 설정
            //         indent: 40, // 시작 부분의 간격 설정
            //         endIndent: 40, // 끝 부분의 간격 설정
            //         color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //       ),
            //       SizedBox(height: 5.0,)
            //     ],
            //   ),
            //
            // if(selectedValues2.length > 1)
            //   if(repotChecks[selectedValues2[1]] == true)
            //   Column(
            //     children: [
            //       Row(
            //         children: [
            //           SizedBox(width: 40),
            //           Icon(Icons.grass,
            //               color: Color(0xFFA88E82)),
            //           SizedBox(width: 10),
            //           Text(
            //             '분갈이를 했어요',
            //             style: TextStyle(
            //               fontSize: 16,
            //               color: Color(0xFF2B2B2B),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 2),
            //       Divider(
            //         thickness: 1, // 밑줄의 두께 설정
            //         indent: 40, // 시작 부분의 간격 설정
            //         endIndent: 40, // 끝 부분의 간격 설정
            //         color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //       ),
            //       SizedBox(height: 5.0,)
            //     ],
            //   ),
            if(selectedValues2.length > 1 && waterChecks[selectedValues2[1]] == true)
              _buildChecklistItem(Icons.water_drop, '물을 줬어요', Color(0xFF75C5F2)),
            if(selectedValues2.length > 1 && ventilationChecks[selectedValues2[1]] == true)
              _buildChecklistItem(Icons.air, '환기했어요', Colors.green),
            if(selectedValues2.length > 1 && repotChecks[selectedValues2[1]] == true)
              _buildChecklistItem(Icons.nature, '분갈이했어요', Colors.brown),

            SizedBox(height: 12.0,),


            // 네 번째 등록 허브
            if (selectedValues2.length > 2)
              Row(
                children: [
                  SizedBox(width: 45),
                  Text(
                    '${selectedValues2[2]}',
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF2C2C2C)),
                  ),
                ],
              ),

            SizedBox(height: 12.0,),

            // if(selectedValues2.length > 2)
            //   if(waterChecks[selectedValues2[2]] == true)
            //     Column(
            //       children: [
            //         Row(
            //           children: [
            //             SizedBox(width: 40),
            //             Icon(Icons.water_drop,
            //                 color: Color(0xFF75C5F2)),
            //             SizedBox(width: 10),
            //             Text(
            //               //'선택된 날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
            //               '물을 줬어요',
            //               style: TextStyle(
            //                 fontSize: 16,
            //                 color: Color(0xFF2B2B2B),
            //               ),
            //             ),
            //           ],
            //         ),
            //         SizedBox(height: 2),
            //         Divider(
            //           thickness: 1, // 밑줄의 두께 설정
            //           indent: 40, // 시작 부분의 간격 설정
            //           endIndent: 40, // 끝 부분의 간격 설정
            //           color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //         ),
            //         SizedBox(height: 5.0,)
            //       ],
            //     ),
            // if(selectedValues2.length > 2)
            //   if(ventilationChecks[selectedValues2[2]] == true)
            //     Column(
            //       children: [
            //         Row(
            //           children: [
            //             SizedBox(width: 40),
            //             Icon(Icons.wind_power,
            //                 color: Color(0xFF99DA79)),
            //             SizedBox(width: 10),
            //             Text(
            //               //'선택된 날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
            //               '환기를 했어요',
            //               style: TextStyle(
            //                 fontSize: 16,
            //                 color: Color(0xFF2B2B2B),
            //               ),
            //             ),
            //           ],
            //         ),
            //         SizedBox(height: 2),
            //         Divider(
            //           thickness: 1, // 밑줄의 두께 설정
            //           indent: 40, // 시작 부분의 간격 설정
            //           endIndent: 40, // 끝 부분의 간격 설정
            //           color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //         ),
            //         SizedBox(height: 5.0,)
            //       ],
            //     ),
            // if(selectedValues2.length > 2)
            //   if(repotChecks[selectedValues2[2]] == true)
            //     Column(
            //       children: [
            //         Row(
            //           children: [
            //             SizedBox(width: 40),
            //             Icon(Icons.grass,
            //                 color: Color(0xFFA88E82)),
            //             SizedBox(width: 10),
            //             Text(
            //               '분갈이를 했어요',
            //               style: TextStyle(
            //                 fontSize: 16,
            //                 color: Color(0xFF2B2B2B),
            //               ),
            //             ),
            //           ],
            //         ),
            //         SizedBox(height: 2),
            //         Divider(
            //           thickness: 1, // 밑줄의 두께 설정
            //           indent: 40, // 시작 부분의 간격 설정
            //           endIndent: 40, // 끝 부분의 간격 설정
            //           color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //         ),
            //         SizedBox(height: 5.0,)
            //       ],
            //     ),

            if(selectedValues2.length > 2 && waterChecks[selectedValues2[2]] == true)
              _buildChecklistItem(Icons.water_drop, '물을 줬어요', Color(0xFF75C5F2)),
            if(selectedValues2.length > 2 && ventilationChecks[selectedValues2[2]] == true)
              _buildChecklistItem(Icons.air, '환기했어요', Colors.green),
            if(selectedValues2.length > 2 && repotChecks[selectedValues2[2]] == true)
              _buildChecklistItem(Icons.nature, '분갈이했어요', Colors.brown),

              SizedBox(height: 12.0,),

              if(selectedValues2.length > 3 && waterChecks[selectedValues2[3]] == true)
                _buildChecklistItem(Icons.water_drop, '물을 줬어요', Color(0xFF75C5F2)),
              if(selectedValues2.length > 3 && ventilationChecks[selectedValues2[3]] == true)
                _buildChecklistItem(Icons.air, '환기했어요', Colors.green),
              if(selectedValues2.length > 3 && repotChecks[selectedValues2[3]] == true)
                _buildChecklistItem(Icons.nature, '분갈이했어요', Colors.brown),

              SizedBox(height: 12.0,),

            // if(selectedValues2.length > 3)
            //   if(waterChecks[selectedValues2[3]] == true)
            //     Column(
            //       children: [
            //         Row(
            //           children: [
            //             SizedBox(width: 40),
            //             Icon(Icons.water_drop,
            //                 color: Color(0xFF75C5F2)),
            //             SizedBox(width: 10),
            //             Text(
            //               //'선택된 날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
            //               '물을 줬어요',
            //               style: TextStyle(
            //                 fontSize: 16,
            //                 color: Color(0xFF2B2B2B),
            //               ),
            //             ),
            //           ],
            //         ),
            //         SizedBox(height: 2),
            //         Divider(
            //           thickness: 1, // 밑줄의 두께 설정
            //           indent: 40, // 시작 부분의 간격 설정
            //           endIndent: 40, // 끝 부분의 간격 설정
            //           color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //         ),
            //         SizedBox(height: 5.0,)
            //       ],
            //     ),
            // if(selectedValues2.length > 3)
            //   if(ventilationChecks[selectedValues2[3]] == true)
            //     Column(
            //       children: [
            //         Row(
            //           children: [
            //             SizedBox(width: 40),
            //             Icon(Icons.wind_power,
            //                 color: Color(0xFF99DA79)),
            //             SizedBox(width: 10),
            //             Text(
            //               //'선택된 날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
            //               '환기를 했어요',
            //               style: TextStyle(
            //                 fontSize: 16,
            //                 color: Color(0xFF2B2B2B),
            //               ),
            //             ),
            //           ],
            //         ),
            //         SizedBox(height: 2),
            //         Divider(
            //           thickness: 1, // 밑줄의 두께 설정
            //           indent: 40, // 시작 부분의 간격 설정
            //           endIndent: 40, // 끝 부분의 간격 설정
            //           color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //         ),
            //         SizedBox(height: 5.0,)
            //       ],
            //     ),
            // if(selectedValues2.length > 3)
            //   if(repotChecks[selectedValues2[3]] == true)
            //     Column(
            //       children: [
            //         Row(
            //           children: [
            //             SizedBox(width: 40),
            //             Icon(Icons.grass,
            //                 color: Color(0xFFA88E82)),
            //             SizedBox(width: 10),
            //             Text(
            //               '분갈이를 했어요',
            //               style: TextStyle(
            //                 fontSize: 16,
            //                 color: Color(0xFF2B2B2B),
            //               ),
            //             ),
            //           ],
            //         ),
            //         SizedBox(height: 2),
            //         Divider(
            //           thickness: 1, // 밑줄의 두께 설정
            //           indent: 40, // 시작 부분의 간격 설정
            //           endIndent: 40, // 끝 부분의 간격 설정
            //           color: Color(0x8FABABAB), // 밑줄의 색상 설정
            //         ),
            //         SizedBox(height: 5.0,)
            //       ],
            //     ),

            if(selectedValues2.length > 3 && waterChecks[selectedValues2[3]] == true)
              _buildChecklistItem(Icons.water_drop, '물을 줬어요', Color(0xFF75C5F2)),
            if(selectedValues2.length > 3 && ventilationChecks[selectedValues2[3]] == true)
              _buildChecklistItem(Icons.air, '환기했어요', Colors.green),
            if(selectedValues2.length > 3 && repotChecks[selectedValues2[3]] == true)
              _buildChecklistItem(Icons.nature, '분갈이했어요', Colors.brown),

            SizedBox(height: 12.0,),

            // 지난 날짜에만 버튼이 보이고, 버튼이 숨김 상태가 아닌 경우에만 생성
            if (isPastDate && syncButtonVisible)
              ElevatedButton(
                onPressed: _checkAndSyncChecklist,
                child: Text('Google Calendar와 동기화'),
              ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(IconData icon, String text, Color color) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 40),
            Icon(icon, color: color),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(fontSize: 16, color: Color(0xFF2B2B2B)),
            ),
          ],
        ),
        SizedBox(height: 2),
        Divider(
          thickness: 1,
          indent: 40,
          endIndent: 40,
          color: Color(0x8FABABAB),
        ),
        SizedBox(height: 5.0),
      ],
    );
  }
}

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() {
    _client.close();
  }
}
