
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TipBox extends StatefulWidget {
  // const NewSheetDialog({super.key}); // const 는 생성자를 상수 생성자로 만들려고 하는 시도 / 그러나 여기서 생성자는 기본 생성자이므로 사용할 수 없음

  final String selectedValue;
  TipBox({required this.selectedValue});

  _TipBoxState createState() => _TipBoxState();
}

class _TipBoxState extends State<TipBox> {

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 290,
        // 고정된 너비
        height: 68,
        // 고정된 높이
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFDAF3).withOpacity(0.6),
              Color(0xFFB8A6DE).withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.selectedValue == '라벤더')
              Expanded(
                child: Center(
                  child: Text(
                    "Tip. 장마철 습기에 주의하여 통풍에 신경 써 주세요",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              if (widget.selectedValue == '레몬 밤')
                Expanded(
                  child: Center(
                    child: Text(
                      "Tip. 죽은 잎이나 꽃이 그대로 달려 있을 때, 가지치기를 한 번 해주세요",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else // 기본 텍스트
                Expanded(
                  child: Center(
                    child: Text(
                      "Tip.\n기르는 허브를 설정하면 관련 팁을 드려요",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
