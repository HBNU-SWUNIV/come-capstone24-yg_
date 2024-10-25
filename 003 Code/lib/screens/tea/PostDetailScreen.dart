import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  final Map<dynamic, dynamic> post;

  PostDetailScreen({required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // title: Text('북마크',
        // style: TextStyle(fontWeight: FontWeight.bold),),
        // iconTheme: IconThemeData(color: Colors.black), // AppBar 아이콘 색상 설정
        // leading: TextButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   child: Text(
        //     '북마크 화면으로',
        //   ),
        // ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(22.0),
            child: Container(
              width: 490, // 카드 너비 설정
              child: Card(
                elevation: 4.0,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                post['title'],
                                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (post['imageUrl'] != null)
                        Container(
                          width: double.infinity,
                          //height: 190, // 이미지 높이 설정
                          child: Image.network(
                            post['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 16.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          post['content'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF484848),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
