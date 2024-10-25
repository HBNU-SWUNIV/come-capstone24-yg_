import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class BoardDialog extends StatefulWidget {
  // const NewSheetDialog({super.key}); // const 는 생성자를 상수 생성자로 만들려고 하는 시도 / 그러나 여기서 생성자는 기본 생성자이므로 사용할 수 없음

  final String title;
  final String content;
  final String herbType;

  BoardDialog({required this.title, required this.content, required this.herbType});

  _BoardDialogState createState() => _BoardDialogState();
}

class _BoardDialogState extends State<BoardDialog> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFCEEFC).withOpacity(0.95),
              Color(0xFFD3C9E3).withOpacity(0.95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  widget.content,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}