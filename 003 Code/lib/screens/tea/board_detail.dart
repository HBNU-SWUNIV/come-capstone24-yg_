import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testproject/screens/tea/board_card.dart';
import 'package:testproject/screens/tea/herbaltea_card.dart';
import 'package:testproject/screens/tea/potpourri_card.dart';
import 'package:testproject/screens/tea/tea_screen.dart';

import 'comment_screen.dart';

class BoardDetailScreen extends StatefulWidget {

  final String title;
  final String content;
  final String herbType;
  final String imageUrl;
  final String userId;
  final String postId;
  final String userName; // 추가
  final Function resetIndexCallback;
  final VoidCallback? goBackToFirstScreen;


  const BoardDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.herbType,
    required this.imageUrl,
    required this.userId,
    required this.postId,
    required this.userName, // 추가
    required this.resetIndexCallback,
    this.goBackToFirstScreen
  });


  @override
  _BoardDetailScreenState createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final DatabaseReference _commentsRef =
  FirebaseDatabase.instance.reference().child('comments');
  File? _image;
  final ImagePicker _picker = ImagePicker();

  List<Map<dynamic, dynamic>> _comments = []; // 후기 목록
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    //_currentUser = FirebaseAuth.instance.currentUser;
    _fetchComments();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
      if (_currentUser != null) {
        print("Current user ID: ${_currentUser!.uid}"); // 디버깅 로그
      }
    });
  }

  // 화면 초기화 시 후기목록 가져오기
  Future<void> _fetchComments() async {
    try {
      DataSnapshot snapshot = await _commentsRef.child(widget.postId).get();
      if (snapshot.value != null) { // null 체크 추가
        List<Map<dynamic, dynamic>> comments = [];
        (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
          comments.add({...value as Map<dynamic, dynamic>, 'key': key});
        });

        // 시간 순서대로 정렬 (최신 후기가 위로 오도록 내림차순 정렬)
        comments.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

        setState(() {
          _comments = comments; // 상태 업데이트
        });
      }
    } catch (error) {
      print("Error fetching comments: $error");
    }
  }

  // 후기 제출 코드
  void _submitComment() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Fluttertoast.showToast(
          msg: "로그인이 필요합니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      final CuserId = _currentUser!.uid; // 현재 유저 아이디

      if (_commentController.text.isNotEmpty) {
        final comment = {
          'userId': CuserId,
          'userName': widget.userName, // 추가
          'text': _commentController.text,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'likes': 0, // 초기 좋아요 수
          'likedBy': [], // 좋아요를 누른 사용자 ID 목록 추가
          'imageUrl': imageUrl, // 이미지 URL 추가
        };

        await _commentsRef.child(widget.postId).push().set(comment);
        _commentController.clear(); // 입력창 초기화
        setState(() {
          _image = null; // 이미지 초기화
        });
        Fluttertoast.showToast(
          msg: "후기 등록 완료",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        _fetchComments(); // 새로운 후기 등록 후 목록 갱신
      }
    } catch (e) {
      print('Failed to add post: $e');
      Fluttertoast.showToast(
        msg: "후기 등록 실패",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // 이미지 업로드 함수
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('comments/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  // 후기 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog(String commentKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('후기를 삭제할까요?',
          style: TextStyle(
            fontSize: 18
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                _deleteComment(commentKey); // 후기 삭제
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 후기 삭제 함수
  Future<void> _deleteComment(String commentKey) async {
    try {
      await _commentsRef.child(widget.postId).child(commentKey).remove();
      Fluttertoast.showToast(
        msg: "삭제되었습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      _fetchComments(); // 후기 목록 새로 고침
    } catch (error) {
      print("Failed to delete comment: $error");
      Fluttertoast.showToast(
        msg: "삭제 실패",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  // 좋아요 버튼 관련 함수
  void _toggleLike(String commentKey, List<dynamic> likedBy, int currentLikes) async {
    if (_currentUser == null) {
      Fluttertoast.showToast(
        msg: "로그인 후 좋아요를 누를 수 있습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    final CuserId = _currentUser!.uid; // 현재 유저 아이디

    List<dynamic> updatedLikedBy = List<dynamic>.from(likedBy);

    if (updatedLikedBy.contains(CuserId)) {
      // 이미 좋아요를 누른 경우, 좋아요 취소
      updatedLikedBy.remove(CuserId);
      currentLikes--;
    } else {
      // 좋아요를 누르지 않은 경우, 좋아요 추가
      updatedLikedBy.add(CuserId);
      currentLikes++;
    }

    try {
      // Firebase 업데이트
      await _commentsRef.child(widget.postId).child(commentKey).update({
        'likes': currentLikes,
        'likedBy': updatedLikedBy,
      });

      // 후기 목록 다시 불러오기
      await _fetchComments();
    } catch (error) {
      print('Failed to update like status: $error');
    }
  }



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
              BoardCard(
                title: widget.title,
                content: widget.content,
                herbType: widget.herbType,
                imageUrl: widget.imageUrl,
                userId: widget.userId,
                postId: widget.postId,
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

                SizedBox(height: 100), // '첫 화면으로' 버튼과 텍스트 사이의 간격
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '이 활용 방법의 ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black, // 텍스트 색상
                          ),
                        ),
                        TextSpan(
                          text: '후기',
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.black, // 텍스트 색상
                            fontWeight: FontWeight.bold, // 텍스트 굵기
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20), // '활용 방법의 후기' 텍스트와 후기 입력창 사이의 간격
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: '후기를 작성해 보세요.',
                    hintStyle: TextStyle(
                      color: Color(0xFFADABB0)
                    ),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.camera_alt_outlined),
                      onPressed: _pickImage,
                    ),
                  ),
                ),

                SizedBox(height: 10), // 후기 입력창과 '등록' 버튼 사이의 간격
                Row(
                  //mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start, // 상단 정렬
                  children: [
                    // 이미지 미리보기
                    if (_image != null) ...[
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // 이미지 'x' 버튼
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.white70, size: 15),
                                onPressed: () {
                                  setState(() {
                                    _image = null; // 이미지 제거
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    Expanded(child: Container()),
                    //SizedBox(width: 170),
                    ElevatedButton(
                      onPressed: _submitComment,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Color(0xFF6750A4),
                      ),
                      child: Text('등록'),
                    ),

                    SizedBox(height: 5),
                  ],
                ),

                Divider(
                  thickness: 1, // 밑줄의 두께 설정
                  color: Color(0x8FABABAB), // 밑줄의 색상 설정
                ),

                SizedBox(height: 5),

                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    final timestamp = comment['timestamp'];
                    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                    final formattedDate = "${date.year}.${date.month}.${date.day}";
                    final likedBy = comment['likedBy'] as List<dynamic>? ?? [];
                    final likes = comment['likes'] as int? ?? 0;
                    final commentKey = comment['key'] as String?;

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 0), // 좌우 패딩 제거
                      // title: Text(
                      //     '${comment['userName']}',
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 14,
                      //   ),
                      // ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${comment['userName']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (_currentUser?.uid == comment['userId']) // 후기 작성자만 삭제 가능
                            GestureDetector(
                              onTap: () {
                                if (commentKey != null) {
                                  _showDeleteConfirmDialog(commentKey); // 삭제 확인 다이얼로그 띄우기
                                }
                              },
                              child: Icon(
                                Icons.close,
                                color: Color(0xFFBDB9C2),
                                size: 20,
                              ),
                            ),
                        ],
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 3), // 닉네임과 텍스트 사이의 간격
                          Text(comment['text'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF76727A),
                            ),
                          ),

                          SizedBox(height: 10), // 텍스트와 날짜 사이의 간격
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양쪽 끝으로 배치
                            children: [
                              Text(
                                formattedDate,
                                style: TextStyle(color: Color(0xFFBDB9C2), fontSize: 12),
                              ),
                              Row(
                                children: [
                                  // '댓글 보기' 버튼 추가
                                  SizedBox(
                                    width: 66,  // 버튼 너비
                                    height: 29, // 버튼 높이
                                    child: TextButton(
                                    onPressed: () {
                                      if (commentKey != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ReplyScreen(
                                              postId: widget.postId, // 게시물 ID 전달
                                              commentId: commentKey, // 해당 댓글 ID 전달
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black, textStyle: TextStyle(fontSize: 12), // 버튼 텍스트 크기
                                      side: BorderSide(color: Color(0xFF76727A), width: 0.5), // 버튼 테두리 색상 및 두께
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20), // 테두리 둥글기
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0), // 상하, 좌우 여백 조절
                                    ),
                                      child: Center(
                                        child: Text('댓글보기', style: TextStyle(color: Color(0xFF76727A))), // 버튼 텍스트
                                      ),
                                    ),
                                  ),

                              SizedBox(width: 14),
                                  GestureDetector(
                                    onTap: () {
                                      if (commentKey != null) {
                                        _toggleLike(commentKey, likedBy, likes);
                                      }
                                    },
                                    child: Icon(
                                      likedBy.contains(_currentUser?.uid)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: likedBy.contains(_currentUser?.uid)
                                          ? Color(0xFFE75656)
                                          : null,
                                      size: 27,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text('$likes'),
                                ],
                              ),
                            ],
                          ),

                          //SizedBox(height: 2),

                        if (comment['imageUrl'] != null) ...[
                          SizedBox(height: 10),
                          Image.network(
                          comment['imageUrl'],
                          width: double.infinity,
                          //height: 200,
                          fit: BoxFit.contain,
                          ),
                        ],

                          Divider(
                            thickness: 1, // 밑줄의 두께 설정
                            color: Color(0x8FABABAB), // 밑줄의 색상 설정
                          ),
                        ],

                      ),
                    );
                  },
                )
              ],
          ),
        ),
      ),
    );
  }
}