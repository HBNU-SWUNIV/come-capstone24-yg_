import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testproject/screens/medical/components/dis_card.dart';
import 'package:testproject/screens/tea/herbaltea_card.dart';
import 'package:testproject/screens/tea/potpourri_card.dart';
import 'package:testproject/screens/tea/tea_screen.dart';

class DisDetailScreen extends StatefulWidget {
  final Map<String, String> disease;
  final Function resetIndexCallback;
  final VoidCallback? goBackToFirstScreen;

  const DisDetailScreen({super.key, required this.disease, required this.resetIndexCallback, this.goBackToFirstScreen});

  @override
  _DisDetailScreenState createState() => _DisDetailScreenState();
}

class _DisDetailScreenState extends State<DisDetailScreen> {

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
                    widget.disease['title']!,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 5),

              Padding(
                padding: EdgeInsets.only(
                  left: 5.0,
                  right: 5.0,
                ),
                child: Text(
                  widget.disease['titleContent']!,
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF414141)
                  ),
                ),
              ),
              SizedBox(height: 20),

              DisCard(DImage: widget.disease['DImage']!,
                  SolContent: widget.disease['SolContent']!),

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
