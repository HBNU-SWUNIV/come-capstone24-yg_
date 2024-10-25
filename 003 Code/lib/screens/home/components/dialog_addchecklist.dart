import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCKListBtnDialog extends StatefulWidget {

  final Function(Map<String, bool>) onCheckBoxStatesChanged;

  AddCKListBtnDialog({required this.onCheckBoxStatesChanged});

  _AddCKListBtnDialogState createState() => _AddCKListBtnDialogState();
}
class _AddCKListBtnDialogState extends State<AddCKListBtnDialog> {
  bool repotCheckBox = false; // 분갈이하기 초기값
  bool pruneCheckBox = false; // 가지치기 초기값
  bool nutritionCheckBox = false; // 영양 관리 초기값
  bool harvestCheckBox = false; // 수확하기 초기값

  DateTime now = DateTime.now();

  void initState() {
    super.initState();
    _loadCheckStatus();
  }

  _loadCheckStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = DateFormat('yyyy-MM-dd').format(now);

    setState(() {
      repotCheckBox = prefs.getBool('repotCheckedBox') ?? false;
      pruneCheckBox = prefs.getBool('pruneCheckedBox') ?? false;
      nutritionCheckBox = prefs.getBool('nutritionCheckedBox') ?? false;
      harvestCheckBox = prefs.getBool('harvestCheckedBox') ?? false;
    });
  }

  _saveCheckStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = DateFormat('yyyy-MM-dd').format(now);

    await prefs.setBool('repotCheckedBox', repotCheckBox);
    await prefs.setBool('pruneCheckedBox', pruneCheckBox);
    await prefs.setBool('nutritionCheckedBox', nutritionCheckBox);
    await prefs.setBool('harvestCheckedBox', harvestCheckBox);
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.65,
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
                      // if (daysSinceLastCheck >= 4 || daysSinceLastCheck == 0)
                      //   CheckboxListTile(
                      //     title: Text('물 주기'),
                      //     value: waterCheck,
                      //     onChanged: (val) {
                      //       setState(() {
                      //         waterCheck = val!;
                      //         _saveCheckStatus(waterCheck);
                      //       });
                      //     },
                      //   ),

                        CheckboxListTile(
                          title: Text('분갈이하기'),
                          value: repotCheckBox,
                          onChanged: (val) {
                            setState(() {
                              repotCheckBox = val!;
                              _saveCheckStatus(repotCheckBox);
                            });
                          },
                        ),
                      CheckboxListTile(
                        title: Text('가지치기'),
                        value: pruneCheckBox,
                        onChanged: (val) {
                          setState(() {
                            pruneCheckBox = val!;
                            _saveCheckStatus(pruneCheckBox);
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('영양 관리'),
                        value: nutritionCheckBox,
                        onChanged: (val) {
                          setState(() {
                            nutritionCheckBox = val!;
                            _saveCheckStatus(nutritionCheckBox);
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('수확하기'),
                        value: harvestCheckBox,
                        onChanged: (val) {
                          setState(() {
                            harvestCheckBox = val!;
                            _saveCheckStatus(harvestCheckBox);
                          });
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
                        widget.onCheckBoxStatesChanged({
                          'repotCheckBox': repotCheckBox,
                          'pruneCheckBox': pruneCheckBox,
                          'nutritionCheckBox': nutritionCheckBox,
                          'harvestCheckBox': harvestCheckBox
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