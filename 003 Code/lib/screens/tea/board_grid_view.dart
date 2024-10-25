import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:testproject/screens/tea/board_card.dart';
import 'package:testproject/screens/tea/board_detail.dart';
import 'package:testproject/screens/tea/dialog_board.dart';
import 'package:testproject/screens/tea/dialog_board.dart';

class BoardGridView extends StatefulWidget {
  final Function(Map<String, dynamic>) onBoardSelected; // 콜백 함수 추가

  const BoardGridView({Key? key, required this.onBoardSelected}) : super(key: key);

  @override
  _BoardGridViewState createState() => _BoardGridViewState();
}

class _BoardGridViewState extends State<BoardGridView> {
  List<Map<dynamic, dynamic>> postsList = [];


  @override
  void initState() {
    super.initState();
    DatabaseReference _database = FirebaseDatabase.instance.reference().child('posts');
    _database.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final List<Map<dynamic, dynamic>> loadedPosts = [];
      data.forEach((key, value) {
        loadedPosts.add(value as Map<dynamic, dynamic>);
      });
      setState(() {
        postsList = loadedPosts;
      });
    });
  }

  void _showDialog(String title, String content, String herbType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BoardDialog(
          title: title,
          content : content,
          herbType: herbType,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,

        body: GridView.builder(
          padding: EdgeInsets.all(22.0),
          itemCount: postsList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1 / 1.4,
            crossAxisSpacing: 15,
            mainAxisSpacing: 20,
          ),
          //itemBuilder: (ctx, i) => GridTile(
          itemBuilder: (ctx, i) {
            final post = postsList[i]; // 새로 추가
            return GridTile(
                child: GestureDetector(
                onTap: () {
                  //_showDialog(postsList[i]['title'], postsList[i]['content'], postsList[i]['herbType']);

                  widget.onBoardSelected({
                    'title': post['title'] ?? 'No Title',
                    'content': post['content'] ?? 'No Content',
                    'herbType': post['herbType'] ?? 'No Herb Type',
                    'imageUrl': post['imageUrl'] ?? '',
                    'userId': post['userId'] ?? '',
                    'postId': post['postId'] ?? '',
                  });
                },

                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFCAC4D0), width: 1), // 테두리 색상과 두께 설정
                      borderRadius: BorderRadius.circular(10), // 모서리를 둥글게 설정
                    ),
                    child: Card(
                      margin: EdgeInsets.zero,
                      elevation: 0, //그림자
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10), // 이미지 위 모서리 둥글게 설정
                              topRight: Radius.circular(10), // 이미지 위 모서리 둥글게 설정
                            ),
                            child: AspectRatio(
                              aspectRatio: 15.5 / 13.0,
                              child: postsList[i]['imageUrl'] != null
                                  ? Image.network(
                                postsList[i]['imageUrl'],
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                color: Colors.grey, // 기본 배경색
                                child: Center(child: Text('No Image')),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,  // 자식 위젯에 맞게 크기 축소
                              children: [
                                AutoSizeText(
                                  postsList[i]['title'] ?? 'No Title',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,  // 텍스트가 넘칠 때 생략표시
                                ),
                                SizedBox(height: 2),
                                AutoSizeText(
                                  postsList[i]['herbType'] ?? 'No Herb Type',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF49454F),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,  // 텍스트가 넘칠 때 생략표시
                                ),
                              ],
                            ),
                          ),


                        ],
                      ),
                    ),
                  ),

              ),
            );
          },
        ),
    );
  }
}