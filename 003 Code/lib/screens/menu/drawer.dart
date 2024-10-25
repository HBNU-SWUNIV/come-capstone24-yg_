import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testproject/screens/menu/login_screen.dart';
import 'package:testproject/screens/menu/bookmark_screen.dart';

class AppDrawer extends StatefulWidget {
  // final String userName; // 사용자 이름을 전달 받을 변수
  //
  // AppDrawer({required this.userName}); // 생성자를 통해 사용자 이름을 전달 받음


  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool isLoggedIn = false;
  String userName = '게스트';

  late User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      isLoggedIn = true;
      userName = _currentUser!.displayName ?? '게스트';
    }
  }


  void signIn(User user) {
    setState(() {
      isLoggedIn = true;
      userName = user.displayName ?? user.email ?? '아이디';
    });
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      isLoggedIn = false;
      userName = '게스트';
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 240,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEFE3F3).withOpacity(0.93),
              Color(0xFFEFE3F3).withOpacity(0.93),
              Color(0xFFFDCBF1).withOpacity(0.93),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            Container(
              //mainAxisAlignment: MainAxisAlignment.center,
              margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 40.0),
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5), // 하얀 배경을 설정합니다.
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                    leading: Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/image/profile.png'),
                        ),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '식물집사',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14
                              ),
                            ),
                            Text(
                              userName, // 사용자 이름 표시
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        Spacer(), // 텍스트와 CircleAvatar 사이에 간격을 추가합니다.
                      ],
                    ),
                    onTap: () {
                      // onTap 동작 정의
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              leading: Icon(Icons.account_circle),
              title: Text(
                isLoggedIn ? '로그아웃 하기' : '로그인 하기', // 로그인 상태에 따라 버튼 텍스트 변경
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                if (isLoggedIn) {
                  // 로그아웃 처리
                  signOut(); // 위에서 정의한 로그아웃 함수 호출
                } else {
                  // 로그인 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ).then((value) {
                    if (value != null && value) {
                      _currentUser = FirebaseAuth.instance.currentUser;
                      if (_currentUser != null) {
                        signIn(_currentUser!);
                      }
                    }
                  });
                }
              },
              selectedTileColor: Color(0xffE2C3F0),
            ),

            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              leading: Icon(Icons.bookmark),
              title: Text(
                '북마크',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookmarkScreen()),
                );
              },
            ),


            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              leading: Icon(Icons.settings),
              title: Text(
                '출처 정보',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                ),
              ),
              onTap: () {
                // Item 2 선택 시 동작
              },
            ),

          ],
        ),
      ),
    );
  }
}