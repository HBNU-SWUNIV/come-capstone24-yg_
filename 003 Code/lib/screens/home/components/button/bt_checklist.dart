import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testproject/screens/home/components/dialog_checklist.dart';


class IconButtonExample1 extends StatefulWidget {
  final String selectedValue; // 선택한 값을 받을 변수 추가
  final VoidCallback? onConfirmed;

  IconButtonExample1({required this.selectedValue, required this.onConfirmed});

  _IconButtonExample1State createState() => _IconButtonExample1State();
}

class _IconButtonExample1State extends State<IconButtonExample1> {

  String selectedValuePrefs = "value";
  List<String> selectedValues2Prefs = [];

  @override
  void initState() {
    super.initState();
    _loadSavedValue();
  }

  _loadSavedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      selectedValuePrefs = prefs.getString('SelectedValue') ?? '';
    selectedValues2Prefs = prefs.getStringList('SelectedValues2') ?? [];
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Ink(
              decoration: const ShapeDecoration(
                color: Colors.white, // 그라데이션 색상 설정
                shape: CircleBorder(),
              ),
              child: GestureDetector(
                onTap: () {
                  _loadSavedValue();
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.4),
                    builder: (context) {
                      // return CKListBtnDialog(selectedValue: widget.selectedValue);
                      return CKListBtnDialog(
                        selectedValue: selectedValuePrefs,
                        //initialRepotCheck: false,);
                          initialCheckStates: {'repotCheckBox': false, 'pruneCheckBox': false,},
                        selectedValues2: selectedValues2Prefs,
                        onConfirmed: (){
                          // HomeScreen의 _handleCheckConfirmed 메소드 호출
                          if (widget.onConfirmed != null) {
                            widget.onConfirmed!();
                          }
                        },
                          );
                      //},
                    },
                  );
                },
                child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/image/checklist_icon.png', // 이미지 경로 설정
                  width: 40, // 이미지 너비
                  height: 40, // 이미지 높이
                ),
              ),
              ),
            ),

        const Text(
          '체크리스트',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF504C56)
          ),
        ),
    ],
      ),
    );
  }
}
