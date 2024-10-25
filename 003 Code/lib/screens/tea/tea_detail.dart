import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testproject/screens/tea/herbaltea_card.dart';
import 'package:testproject/screens/tea/potpourri_card.dart';
import 'package:testproject/screens/tea/tea_screen.dart';

class TeaDetailScreen extends StatefulWidget {
  final Map<String, String> herb;
  final Function resetIndexCallback;
  final VoidCallback? goBackToFirstScreen;


  const TeaDetailScreen({super.key, required this.herb, required this.resetIndexCallback, this.goBackToFirstScreen});

  @override
  _TeaDetailScreenState createState() => _TeaDetailScreenState();
}

class _TeaDetailScreenState extends State<TeaDetailScreen> {
  int _selectedSegmentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 12.0,
            bottom: 12.0,
            left: 29.0,
            right: 29.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.herb['title']!,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(width: 10),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(30),
                    borderColor: Color(0xFF4F378B),
                    selectedBorderColor: Color(0xFF4F378B),
                    color: Colors.black,
                    constraints: BoxConstraints(minHeight: 35.0),
                    isSelected: [
                      _selectedSegmentIndex == 0,
                      _selectedSegmentIndex == 1,
                    ],
                    onPressed: (int index) {
                      setState(() {
                        _selectedSegmentIndex = index;
                      });
                    },
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('허브차'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('포푸리'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5),

              Padding(
                padding: EdgeInsets.only(
                  left: 5.0,
                  right: 5.0,
                ),
                child: Text(
                  widget.herb['titleContent']!,
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF414141)
                  ),
                ),
              ),

              // Toggle 버튼에 따라 다른 카드 보이게 하기
              SizedBox(height: 20),
              _selectedSegmentIndex == 0
                  ? HerbalTeaCard(
                    teaImage: widget.herb['teaImage']!,
                    teaContent: widget.herb['teaContent']!,
                  )
                  : PotpourriCard(
                    potpourriImage: widget.herb['potpourriImage']!,
                    potpourriContent: widget.herb['potpourriContent']!,
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.goBackToFirstScreen?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffa997d5),
                  //   minimumSize: Size(250, 35),
                  elevation: 6, //
                  shadowColor: Colors.black, // 그림자 색상
                ),
                child: Text(
                  '첫 화면으로',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
