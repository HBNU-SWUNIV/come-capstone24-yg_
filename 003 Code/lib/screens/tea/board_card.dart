import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BoardCard extends StatefulWidget {
  final String title;
  final String content;
  final String herbType;
  final String imageUrl;
  final String userId;
  final String postId;

  BoardCard({
    required this.title,
    required this.content,
    required this.herbType,
    required this.imageUrl, // 생성자에 이미지 URL 추가
    required this.userId, // 생성자에 userId 추가
    required this.postId,
  });

  @override
  _BoardCardState createState() => _BoardCardState();
}

class _BoardCardState extends State<BoardCard> {
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkIfBookmarked();
  }
  // 새로 추가
  Future<void> _checkIfBookmarked() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference _bookmarkRef = FirebaseDatabase.instance
          .reference()
          .child('bookmarks')
          .child(user.uid)
          .child(widget.postId);
      DataSnapshot snapshot = await _bookmarkRef.get();
      setState(() {
        isBookmarked = snapshot.exists;
      });
    }
  }
  // 새로 추가
  Future<void> _toggleBookmark() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Fluttertoast.showToast(
        msg: "로그인이 필요합니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    // 새로 추가
    DatabaseReference _bookmarkRef = FirebaseDatabase.instance
        .reference()
        .child('bookmarks')
        .child(user.uid)
        .child(widget.postId);
    // 새로 추가
    if (isBookmarked) {
      await _bookmarkRef.remove();
      Fluttertoast.showToast(
        msg: "북마크에서 제거되었습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      // 북마크 중복 확인
      DataSnapshot snapshot = await _bookmarkRef.get();
      if (snapshot.exists) {
        Fluttertoast.showToast(
          msg: "이미 북마크에 추가된 게시물입니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }
    // 새로 추가
      final bookmarkData = {
        'title': widget.title,
        'content': widget.content,
        'herbType': widget.herbType,
        'imageUrl': widget.imageUrl,
        'postId': widget.postId,
        'userId': widget.userId,
      };
      await _bookmarkRef.set(bookmarkData);
      Fluttertoast.showToast(
        msg: "북마크에 추가되었습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
    // 새로 추가
    setState(() {
      isBookmarked = !isBookmarked;
    });
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'edit':
      // 수정 동작 처리
        print('수정');
        break;
      case 'delete':
      // 삭제 동작 처리
        print('삭제');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

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
                    children: [
                      Expanded(
                        child: Baseline(
                          baseline: 22,
                          baselineType: TextBaseline.alphabetic,
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        ),
                        iconSize: 30,
                        onPressed: _toggleBookmark,
                      ),
                      if (currentUser != null && currentUser.uid == widget.userId)
                        PopupMenuButton<String>(
                          onSelected: _onMenuSelected,
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Center(
                                  child: Text(
                                    '수정',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Center(
                                  child: Text(
                                    '삭제',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFC44D4D)
                                    ),
                                  ),
                                ),
                              ),
                            ];
                          },
                          icon: Icon(Icons.more_vert),
                          iconSize: 30,
                        ),

                      if (currentUser?.uid != widget.userId)
                        PopupMenuButton<String>(
                          onSelected: _onMenuSelected,
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<String>(
                                value: 'share',
                                child: Center(
                                  child: Text(
                                      '공유',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ];
                          }
                        )
                    ],
                  ),
                ),

                SizedBox(height: 10),
                widget.imageUrl.isNotEmpty
                    ? Image.network(
                  widget.imageUrl,
                  // width: double.infinity,
                  // height: 190,
                  // fit: BoxFit.cover,
                  width: double.infinity,
                  fit: BoxFit.contain,
                )
                    : Container(
                  height: 190,
                  color: Colors.grey[200],
                  child: Center(child: Text('No Image')),
                ),


              SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF484848)
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
