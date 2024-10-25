import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class WriteScreen extends StatefulWidget {
  @override
  _WriteScreenState createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  TextEditingController _herbTypeController = TextEditingController();
  File? _image; // 선택한 이미지를 저장할 변수

  final ImagePicker _picker = ImagePicker();

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
  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = 'images/${DateTime.now().millisecondsSinceEpoch.toString()}.png';
      Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('Image URL: $downloadUrl'); // 디버깅을 위해 추가
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('이미지 업로드 실패: $e');
      return null;
    }
  }

  Future<void> _uploadPost() async {
    // 사용자 아이디 저장
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

      // Realtime Database 에 게시물 정보 저장
          //try {
            //DatabaseReference _database = FirebaseDatabase.instance.reference();
        DatabaseReference _database = FirebaseDatabase.instance.reference().child('posts').push();
        String postId = _database.key!; // 자동 생성된 postId

            //이미지 관련
            String? imageUrl;
            if (_image != null) {
              imageUrl = await _uploadImage(_image!);
              print('UploadPost Image URL: $imageUrl'); // 디버깅을 위해 추가
            }

              //await _database.child('posts').push().set({
              await _database.set({
                'userId' : user.uid,
                'postId' : postId,
                'title': _titleController.text,
                'content': _contentController.text,
                'herbType': _herbTypeController.text,
                'imageUrl': imageUrl, // 이미지 URL 추가
          });

            Fluttertoast.showToast(
              msg: "게시 완료 되었습니다",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
            Navigator.pop(context);
          } catch (e) {
            print('Failed to add post: $e');
            Fluttertoast.showToast(
              msg: "게시물 추가에 실패했습니다",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('게시글 쓰기',
        style: TextStyle(
          fontWeight: FontWeight.bold
        ),),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            SizedBox(height: 20.0),

            ElevatedButton(
              onPressed: _pickImage,
              child: Text('이미지 선택'),
            ),
            if (_image != null) ...[
              SizedBox(height: 20.0),
              Image.file(_image!),
            ],

            SizedBox(height: 20.0),


            TextField(
              controller: _herbTypeController,
              decoration: InputDecoration(labelText: '관련 허브 종류'),
            ),
            SizedBox(height: 20.0,),
            SizedBox(height: 20.0),
            TextField(
              controller: _contentController, // 허브 종류 추가
              decoration: InputDecoration(labelText: '자신의 허브 활용 방법을 공유해 보세요!'),
              maxLines: null, // 높이 자동 조절
              keyboardType: TextInputType.multiline, // 줄바꿈 가능하도록 설정
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _uploadPost,
              child: Text('게시하기'),
            ),
          ],
        ),
      ),
    );
  }
}
