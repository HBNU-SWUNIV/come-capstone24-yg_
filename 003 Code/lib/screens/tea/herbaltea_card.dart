import 'package:flutter/material.dart';

class HerbalTeaCard extends StatelessWidget {
  final String teaImage;
  final String teaContent;

  const HerbalTeaCard({
    super.key,
    required this.teaImage,
    required this.teaContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 490,
      child: Card(
        elevation: 0,
        color: Colors.transparent, // 카드의 배경 색을 투명으로 설정하여 그라데이션을 보이도록
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF7ECFB), Color(0xFFFDCBF1)], // 시작 색과 끝 색 지정
            ),
            border: Border.all(
              color: Color(0xFFCAC4D0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.emoji_food_beverage_outlined,
                      size: 38,
                      color: Colors.black,
                    ), // 원하는 아이콘 추가
                    SizedBox(width: 8),
                    // 아이콘과 텍스트 사이의 간격
                    Text(
                      '허브차',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Image.asset(
                teaImage,
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  teaContent,
                  style: TextStyle(
                    fontSize: 16,
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
