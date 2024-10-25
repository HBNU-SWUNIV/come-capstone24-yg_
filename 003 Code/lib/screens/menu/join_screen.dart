import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:testproject/screens/home/home_screen.dart';
import 'package:testproject/screens/main_screens.dart';
import 'package:testproject/screens/menu/login_screen.dart';
import 'package:testproject/screens/menu/setname_screen.dart';

class JoinScreen extends StatefulWidget {
  @override
  _JoinScreenState createState() => _JoinScreenState();
}


class _JoinScreenState extends State<JoinScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController verificationCodeController = TextEditingController();

  String sentVerificationCode = '';

  @override
  Widget build(BuildContext context) {
    TextEditingController idController = TextEditingController();
    TextEditingController pwdController = TextEditingController();
    TextEditingController nicknameController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          ' ',
        ),

        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context);
            }
        ),
      ),

      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '회원 정보를 입력하세요',
                style: TextStyle(
                    color: Color(0xFF2b2b2b),
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),

              SizedBox(height: 24,),


              TextField(
                controller: idController,
                keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: '이메일',),
              ),

              SizedBox(height: 16,),

              TextField(
                controller: pwdController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                ),
                obscureText: true,
              ),

              SizedBox(height: 16,),

              TextField(
                controller: nicknameController,
                decoration: InputDecoration(
                  labelText: '닉네임',
                ),
              ),

              SizedBox(height: 30,),
              ElevatedButton(
                onPressed: () async {
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: idController.text,
                      password: pwdController.text,
                    );
                    // 회원가입 성공 시 추가 정보를 저장하고 홈 화면으로 이동
                    await userCredential.user!.updateDisplayName(nicknameController.text);
                    Fluttertoast.showToast(
                      msg: "회원가입 성공",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  } catch (e) {
                    // 회원가입 실패 시 오류 메시지 출력
                    print('회원가입 실패: $e');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')));
                  }
                },
                child: Text('가입하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}