import 'package:flutter/material.dart';
import 'package:testproject/screens/home/components/dialog_plus.dart'; // 사용할 대화 상자 파일 가져오기

class PlusButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 55),
      child: Center(
        child: IconButton(
          icon: Icon(
            Icons.add_circle,
            color: Color(0xFBE0DCE3),
            size: 55,
          ),
          onPressed: () {
            showDialog(
              context: context,
              barrierColor: Colors.black.withOpacity(0.7),
              barrierDismissible: false,
              builder: (context) =>
                  PlusBtnDialog(
                    onConfirm: (String selectedValue) {
                      // 수정된 부분
                    },
                  ),
              );
            },
        ),
      ),
    );
  }
}
