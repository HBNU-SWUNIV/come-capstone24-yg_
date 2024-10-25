// 허브 복수 등록 시, 할 일 추가 다이얼로그
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCKListBtnDialog2 extends StatefulWidget {

  final Function(Map<String, bool>) onCheckBoxStatesChanged;
  //final Map<String, bool> initialCheckStates;
  final String value;

  AddCKListBtnDialog2({
    required this.onCheckBoxStatesChanged,
    //required this.initialCheckStates,
    required this.value,
  });

  _AddCKListBtnDialog2State createState() => _AddCKListBtnDialog2State();
}

class _AddCKListBtnDialog2State extends State<AddCKListBtnDialog2> {
  late Map<String, bool> repotChecksBox = {}; // 분갈이하기 초기 값
  late Map<String, bool> pruneChecksBox = {}; // 가지치기 초기 값
  late Map<String, bool> nutritionChecksBox = {}; // 영양관리 초기 값
  late Map<String, bool> harvestChecksBox = {}; // 수확하기 초기 값

  DateTime now = DateTime.now();

  void initState() {
    super.initState();
    _loadCheckStatus();
  }

    _loadCheckStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = DateFormat('yyyy-MM-dd').format(DateTime.now());

    setState(() {
      // 저장된 상태를 불러와서 각 체크박스 상태에 반영
      String? repotChecksBoxString = prefs.getString('$key repotCheckedBox2');
      String? pruneChecksBoxString = prefs.getString('$key pruneCheckedBox2');
      String? nutritionChecksBoxString = prefs.getString('$key nutritionCheckedBox2');
      String? harvestChecksBoxString = prefs.getString('$key harvestCheckedBox2');

      if (repotChecksBoxString != null) {
        repotChecksBox = Map<String, bool>.from(json.decode(repotChecksBoxString));
      }

      if (pruneChecksBoxString != null) {
        pruneChecksBox = Map<String, bool>.from(json.decode(pruneChecksBoxString));
      }

      if (nutritionChecksBoxString != null) {
        nutritionChecksBox = Map<String, bool>.from(json.decode(nutritionChecksBoxString));
      }

      if (harvestChecksBoxString != null) {
        harvestChecksBox = Map<String, bool>.from(json.decode(harvestChecksBoxString));
      }
    });
  }

  void _saveCheckStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = DateFormat('yyyy-MM-dd').format(DateTime.now());

    String repotChecksBoxString = json.encode(repotChecksBox);
    String pruneChecksBoxString = json.encode(pruneChecksBox);
    String nutritionChecksBoxString = json.encode(nutritionChecksBox);
    String harvestChecksBoxString = json.encode(harvestChecksBox);
    await prefs.setString('$key repotCheckedBox2', repotChecksBoxString);
    await prefs.setString('$key pruneCheckedBox2', pruneChecksBoxString);
    await prefs.setString('$key nutritionCheckedBox2', nutritionChecksBoxString);
    await prefs.setString('$key harvestCheckedBox2', harvestChecksBoxString);
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.65,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFCEEFC).withOpacity(0.95),
              Color(0xFFD3C9E3).withOpacity(0.95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 24.0, bottom: 16.0, left: 16.0, right: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👇 비정기적으로 할 일을 추가해요',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2B32),
                  ),
                ),
                SizedBox(height: 16.0),
                Column(
                  children: [
                    CheckboxListTile(
                      title: Text('분갈이하기'),
                      value: repotChecksBox[widget.value] ?? false,
                      onChanged: (val) {
                        setState(() {
                          repotChecksBox[widget.value] = val!;
                          // if (repotChecksBox[widget.value] == false) {
                          //   // repotChecks가 null이 아닐 경우 false로 설정
                          //   if (repotChecks.containsKey(widget.value)) {
                          //     repotChecks[widget.value] = false;
                          //   }
                          // }
                        });
                        _saveCheckStatus();
                      },
                    ),
                    CheckboxListTile(
                      title: Text('가지치기'),
                      value: pruneChecksBox[widget.value] ?? false,
                      onChanged: (val) {
                        setState(() {
                          pruneChecksBox[widget.value] = val!;
                        });
                        _saveCheckStatus();
                      },
                    ),
                    CheckboxListTile(
                      title: Text('영양 관리'),
                      value: nutritionChecksBox[widget.value] ?? false,
                      onChanged: (val) {
                        setState(() {
                          nutritionChecksBox[widget.value] = val!;
                        });
                        _saveCheckStatus();
                      },
                    ),
                    CheckboxListTile(
                      title: Text('수확하기'),
                      value: harvestChecksBox[widget.value] ?? false,
                      onChanged: (val) {
                        setState(() {
                          harvestChecksBox[widget.value] = val!;
                        });
                        _saveCheckStatus();
                      },
                    ),
                  ],
                ),

                SizedBox(height: 16.0),
                ButtonBar(
                  children: [
                    TextButton(
                      child: Text(
                        "취소",
                        style: TextStyle(
                          color: Color(0xFF2E2B32),
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),

                    TextButton(
                      child: Text(
                        "추가",
                        style: TextStyle(
                          color: Color(0xFF2E2B32),
                        ),
                      ),
                      onPressed: () {
                        print('Final repotChecksBox value: $repotChecksBox');
                        print('Final pruneChecksBox value: $pruneChecksBox');

                        // 각각의 상태를 분리해서 전달
                        widget.onCheckBoxStatesChanged({
                          'repot': repotChecksBox[widget.value] ?? false,
                          'prune': pruneChecksBox[widget.value] ?? false,
                          'nutrition' : nutritionChecksBox[widget.value] ?? false,
                          'harvest' : harvestChecksBox[widget.value] ?? false,
                        });

                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
