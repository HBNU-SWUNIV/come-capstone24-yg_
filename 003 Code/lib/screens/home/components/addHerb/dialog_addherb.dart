import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testproject/screens/home/components/addHerb/dialog_addherb2.dart';

class HerbAddDialog extends StatefulWidget {
  final Function(List<String>) onConfirm;
  HerbAddDialog({required this.onConfirm});

  _HerbAddDialogState createState() => _HerbAddDialogState();
}

class _HerbAddDialogState extends State<HerbAddDialog> {
  final _valueList = ['라벤더', '레몬 밤', '로즈마리', '세이지', '스위트 바질', '애플민트', '케모마일', '페퍼민트'];
  String? _selectedValue;
  List<String> selectedValues2 = [];
  bool selected2 = false;

  String selectedValue = "value";
  int _selectCount = 2; // 선택 횟수를 추적하는 변수

  @override
  void initState() {
    super.initState();
    _loadSelectedValues();
  }

  // SharedPreferences에 각 허브 이름별 카운트를 저장
  Future<int> _getNextCount(String herb) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt('$herb-count') ?? 0;
    count++; // 카운트 증가
    await prefs.setInt('$herb-count', count); // 증가된 카운트를 저장
    return count;
  }

  _saveCheckStatus(int selectCount, bool selected2, List<String> selectedValues) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'SelectedValues$selectCount'; // 동적으로 키 생성
    await prefs.setBool('Selected2', selected2);
    await prefs.setStringList(key, selectedValues);
    await prefs.setStringList('SelectedValues2', selectedValues2);
  }

  Future<void> _loadSelectedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedValues = prefs.getStringList('SelectedValues2');
    if (storedValues != null) {
      setState(() {
        selectedValues2 = List.from(storedValues);
      });
    }
  }
//
//   _saveCheckStatus(List<String> selectedValues2) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     //await prefs.setBool('Selected2', selected2);
//     await prefs.setStringList('SelectedValues2', selectedValues2);
//   }

  void _addSelectedValue(String newValue) {
    if (selectedValues2.length < 5) {
      setState(() {
        selectedValues2.add(newValue);
      });
      _saveCheckStatus(_selectCount, selected2, selectedValues2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('최대 5개의 허브만 추가할 수 있습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "기르는 허브는 무엇인가요? 🌿",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 17,
            color: Color(0xFF2b2b2b),
            fontWeight: FontWeight.bold
        ),
      ),

      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox( // SizedBox로 감싸서 너비를 조절
                width: 200,
                child: DropdownButtonFormField<String>(
                  value: _selectedValue,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: _selectedValue == null ? '선택하기' : null,
                    labelStyle: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2b2b2b),
                    ),
                  ),
                  items: _valueList.map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedValue = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          child: Text("취소"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("확인",),
          onPressed: _selectedValue == null
              ? null
              : () async {

            // 선택된 허브 이름에 대한 카운트를 가져와서 1 증가
            int count = await _getNextCount(_selectedValue!);

            // 선택된 이름 뒤에 카운트를 추가하여 최종 이름 생성
            String finalSelectedValue = '$_selectedValue($count)';

            // 상태 업데이트 및 _addSelectedValue 함수 호출
            _addSelectedValue(finalSelectedValue);

            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}