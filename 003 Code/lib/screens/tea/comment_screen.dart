import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReplyScreen extends StatefulWidget {
  final String postId;  // 해당 게시물의 ID
  final String commentId;  // 후기 ID

  const ReplyScreen({Key? key, required this.postId, required this.commentId}) : super(key: key);

  @override
  _ReplyScreenState createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  final TextEditingController _replyController = TextEditingController();
  final TextEditingController _nestedReplyController = TextEditingController();
  final DatabaseReference _commentsRef =
  FirebaseDatabase.instance.reference().child('comments');
  Map<dynamic, dynamic>? _comment; // 후기 데이터를 저장할 변수
  List<Map<dynamic, dynamic>> _replies = [];
  String? _replyBeingRepliedTo; // 답글을 달고 있는 댓글의 키
  String? _replyBeingRepliedToForTextField; // 대댓글 입력 필드를 위한 댓글의 키
  bool _showNestedReplyField = false; // 대댓글 입력 필드 표시 여부

  @override
  void initState() {
    super.initState();
    _fetchComment();
    _fetchReplies();
  }

  // 후기 본문 가져오기
  Future<void> _fetchComment() async {
    try {
      DataSnapshot snapshot = await _commentsRef
          .child(widget.postId)
          .child(widget.commentId)
          .get();
      if (snapshot.value != null) {
        setState(() {
          _comment = snapshot.value as Map<dynamic, dynamic>;
        });
      }
    } catch (error) {
      print("Error fetching comment: $error");
    }
  }

  // 댓글과 답글 불러오기
  Future<void> _fetchReplies() async {
    try {
      DataSnapshot snapshot = await _commentsRef
          .child(widget.postId)
          .child(widget.commentId)
          .child('replies') // 댓글을 불러오는 경로
          .get();
      if (snapshot.value != null) {
        List<Map<dynamic, dynamic>> replies = [];
        (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
          replies.add({...value as Map<dynamic, dynamic>, 'key': key});
        });
        replies.sort((b, a) => b['timestamp'].compareTo(a['timestamp']));
        setState(() {
          _replies = replies;
        });
      }
    } catch (error) {
      print("Error fetching replies: $error");
    }
  }

  // 댓글 또는 답글 제출
  Future<void> _submitReply({String? parentReplyId, required bool isNestedReply}) async {
    try {
      print('Entering _submitReply function with parentReplyId: $parentReplyId');
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Fluttertoast.showToast(
          msg: "로그인이 필요합니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      String replyText = isNestedReply ? _nestedReplyController.text : _replyController.text;

      if (replyText.isNotEmpty) {
        final reply = {
          'userId': user.uid,
          'userName': user.displayName ?? 'Unknown', // 유저 이름 추가
          'text': replyText,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        DatabaseReference targetRef = _commentsRef
            .child(widget.postId)
            .child(widget.commentId)
            .child('replies');

        // 만약 parentReplyId가 존재하면 해당 댓글의 'replies'로 답글을 저장
        if (parentReplyId != null) {
          targetRef = targetRef.child(parentReplyId).child('replies');
        }

        // Firebase에 답글 데이터 저장
        await targetRef.push().set(reply);

        if (isNestedReply) {
          _nestedReplyController.clear(); // 대댓글 입력창 초기화
          setState(() {
            _showNestedReplyField = false; // 대댓글 입력 필드 숨기기
            _replyBeingRepliedToForTextField = null; // 대댓글 입력 필드를 위한 댓글 키 초기화
          });
        } else {
          _replyController.clear(); // 댓글 입력창 초기화
        }


        Fluttertoast.showToast(
          msg: "답글 등록 완료",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        _fetchReplies(); // 대댓글 목록 갱신
      } else {
        print('No text entered');
      }
    } catch (e) {
      print('Failed to add reply: $e');
      Fluttertoast.showToast(
        msg: "답글 등록 실패",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true, // 제목을 중앙으로 정렬
        title: Text(
          "댓글",
          style: TextStyle(
            fontWeight: FontWeight.bold, // 제목의 굵기를 굵게 설정
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_comment != null) ...[
            // 후기 본문 표시
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _comment!['userName'] ?? 'Unknown User',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(_comment!['text'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF76727A),
                    ),),
                  SizedBox(height: 10),

                  Text(
                    _formatTimestamp(_comment!['timestamp']),
                    style: TextStyle(color: Color(0xFFBDB9C2), fontSize: 12),
                  ),

                  if (_comment!['imageUrl'] != null)
                    Image.network(
                      _comment!['imageUrl'],
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  Divider(),
                ],
              ),
            ),
          ] else ...[
            // 후기가 로딩 중일 때
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],


          // 댓글 목록 표시
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16.0),
              itemCount: _replies.length,
              itemBuilder: (context, index) {
                final reply = _replies[index];
                return _buildReplyItem(reply);
              },
            ),
          ),
          // 댓글 입력 필드
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      //labelText: '댓글을 입력하세요',
                      hintText: '칭찬이나 질문을 남겨보세요.', // 힌트 텍스트 추가
                      hintStyle: TextStyle(
                        color: Colors.grey, // 힌트 텍스트 색상 설정
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ), // 테두리를 추가합니다
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _submitReply(isNestedReply: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 날짜 포맷팅 메서드
  String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final formattedDate = "${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}";
    return formattedDate;
  }

  Widget _buildReplyItem(Map<dynamic, dynamic> reply) {
    bool showNestedReplyField = _replyBeingRepliedToForTextField == reply['key'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(reply['userName'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reply['text'],
              style: TextStyle(
                color: Color(0xFF76727A)
                ),
              ),
              SizedBox(height: 10),
              Text(
                _formatTimestamp(reply['timestamp']),
                style: TextStyle(color: Color(0xFFBDB9C2), fontSize: 12),
              ),
            ],
          ),
        ),
        // 답글이 있을 경우 답글 목록 표시
        if (reply['replies'] != null)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: (reply['replies'] as Map).length,
                  itemBuilder: (context, index) {
                    String replyKey = (reply['replies'] as Map).keys.elementAt(index);
                    Map<dynamic, dynamic> nestedReply = (reply['replies'] as Map)[replyKey];
                    return ListTile(
                      title: Text(nestedReply['userName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nestedReply['text'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF76727A),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _formatTimestamp(nestedReply['timestamp']),
                            style: TextStyle(color: Color(0xFFBDB9C2), fontSize: 12),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

        // 답글 작성 버튼 및 답글 입력 필드
        if (showNestedReplyField)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nestedReplyController,
                    decoration: InputDecoration(
                      //labelText: '답글을 입력하세요',
                      hintText: '답글을 입력하세요.', // 힌트 텍스트 추가
                      hintStyle: TextStyle(
                        color: Colors.grey, // 힌트 텍스트 색상 설정
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ), // 테두리를 추가합니다
                    ),
                    onSubmitted: (value) {
                      _nestedReplyController.text = value;
                      _submitReply(parentReplyId: reply['key'], isNestedReply: true);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _submitReply(parentReplyId: reply['key'], isNestedReply: true);
                  },
                ),
              ],
            ),
          ),
        // 답글 작성 버튼
        if (_replyBeingRepliedTo != reply['key'])
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: TextButton(
              onPressed: () {
                setState(() {
                  if (_replyBeingRepliedToForTextField == reply['key']) {
                    _showNestedReplyField = false; // Hide nested reply field
                    _replyBeingRepliedToForTextField = null; // Clear the reply key
                  } else {
                    _replyBeingRepliedToForTextField = reply['key'];
                    _showNestedReplyField = true; // Show nested reply field
                  }
                });
              },
              child: Text(
                (_replyBeingRepliedToForTextField == reply['key'] && _showNestedReplyField)
                    ? '취소'
                    : '답글 작성',
              ),
            ),
          ),
        Divider(),
      ],
    );
  }
}