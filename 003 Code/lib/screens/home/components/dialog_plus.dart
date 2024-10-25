import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testproject/screens/home/components/dialog_plus2.dart';

class PlusBtnDialog extends StatefulWidget {
  // const NewSheetDialog({super.key}); // const 는 생성자를 상수 생성자로 만들려고 하는 시도 / 그러나 여기서 생성자는 기본 생성자이므로 사용할 수 없음
  final Function(String) onConfirm;

  PlusBtnDialog({required this.onConfirm});

  _PlusBtnDialogState createState() => _PlusBtnDialogState();
}

class _PlusBtnDialogState extends State<PlusBtnDialog> {
  final _valueList = ['라벤더', '레몬 밤', '로즈마리', '세이지', '스위트 바질', '애플민트', '케모마일', '페퍼민트'];
  String? _selectedValue;
  //bool selected = false;
  //String selectedValue = "value";


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
                    //contentPadding: EdgeInsets.symmetric(vertical: 12),
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
          child: Text("다음",),
          onPressed: _selectedValue == null
              ? null
              : () {
            Navigator.of(context).pop();

            showDialog(
              context: context,
              barrierColor: Colors.black.withOpacity(0.8),
              barrierDismissible: false,
              builder: (BuildContext context) {
                return PlusBtnDialog2(
                  selectedValue: _selectedValue!,
                  onConfirm: widget.onConfirm,);
              },
            );
          },
        ),
      ],
    );
  }
}