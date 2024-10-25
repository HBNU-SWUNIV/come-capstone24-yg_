import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:testproject/screens/home/home_screen.dart';
import 'package:testproject/screens/main_screens.dart';
import 'package:testproject/screens/menu/join_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login',
                style: TextStyle(
                    color: Color(0xFF6750A4),
                    fontSize: 42,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 24,),
              TextField(
                controller: idController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: '아이디(이메일)'),
              ),
              SizedBox(height: 16,),
              TextField(
                controller: pwdController,
                decoration: InputDecoration(labelText: '비밀번호'),
                obscureText: true,
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () async {
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: idController.text,
                      password: pwdController.text,
                    );
                    // 로그인 성공 시 홈 화면으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage(title: '')),
                    );
                    Fluttertoast.showToast(
                      msg: "로그인 성공",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } catch (e) {
                    // 로그인 실패 시 오류 메시지 출력
                    print('로그인 실패: $e');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')));
                  }
                },
                child: Text('로그인'),
              ),
              SizedBox(height: 30,),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JoinScreen()),
                  );
                },
                child: Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
