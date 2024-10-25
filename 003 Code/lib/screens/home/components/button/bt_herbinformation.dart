import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testproject/screens/home/components/dialog_info.dart';
import 'package:testproject/screens/home/components/dialog_plus.dart';


class IconButtonExample2 extends StatefulWidget {
  //const IconButtonExample2({super.key});

  final String selectedValue; // 선택한 값을 받을 변수 추가
  IconButtonExample2({required this.selectedValue});

  _IconButtonExample2State createState() => _IconButtonExample2State();
}

class _IconButtonExample2State extends State<IconButtonExample2> {

  String selectedValuePrefs = "value";
  List<String> selectedValues2Prefs = [];

  @override
  void initState() {
    super.initState();
    _loadSavedValue();
  }

  _loadSavedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

  //   selectedValuePrefs = prefs.getString('SelectedValue') ?? '';
  //   selectedValues2Prefs = prefs.getStringList('SelectedValues2') ?? [];
  // }
    // setState로 감싸서 상태 업데이트
    setState(() {
      selectedValuePrefs = prefs.getString('SelectedValue') ?? '';
      selectedValues2Prefs = prefs.getStringList('SelectedValues2') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
            children: [
              Ink(
                decoration: const ShapeDecoration(
                color: Color(0xFFFFFFFF),
                shape: CircleBorder(),
              ),
                child: GestureDetector(
                  onTap: () {
                    // _loadSavedValue를 호출하여 값이 바뀌면 UI도 즉시 업데이트
                    _loadSavedValue();

                    showDialog(
                      barrierColor: Colors.black.withOpacity(0.4),
                      context: context,
                      builder: (context) {
                    return InfoBtnDialog(
                        selectedValue: selectedValuePrefs,
                        selectedValues2: selectedValues2Prefs,);
                    //return InfoBtnDialog();
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/image/book_icon.png', // 이미지 경로 설정
                      width: 40, // 이미지 너비
                      height: 40, // 이미지 높이
                    ),
                  ),
                ),
            ),

          const Text('허브 정보',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF504C56)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
