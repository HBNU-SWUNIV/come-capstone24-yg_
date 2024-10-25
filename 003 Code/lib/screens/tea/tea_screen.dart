import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testproject/screens/menu/drawer.dart';
import 'package:testproject/screens/tea/board_detail.dart';
import 'package:testproject/screens/tea/board_grid_view.dart';
import 'package:testproject/screens/tea/tea_detail.dart';
import 'package:testproject/screens/tea/tea_grid_view.dart';
import 'package:testproject/screens/tea/write_screen.dart';

class TeaScreen extends StatefulWidget {
  final Function resetIndexCallback;

  const TeaScreen({super.key, required this.resetIndexCallback});

  @override
  _TeaScreenState createState() => _TeaScreenState();
}

class _TeaScreenState extends State<TeaScreen> {
  int _selectedIndex = 0;
  Map<String, String>? _selectedTea;
  Map<String, dynamic>? _selectedBoard;
  String userName = '게스트'; // 추가

  void _onTeaSelected(Map<String, String> tea) {
    setState(() {
      _selectedTea = tea;
      _selectedIndex = 1;
    });
  }

  void _onBoardSelected(Map<String, dynamic> board) {
    setState(() {
      _selectedBoard = board;
      _selectedIndex = 2;
    });
  }

  void resetIndex() {
    setState(() {
      _selectedIndex = 0;
      _selectedTea = null;
      _selectedBoard = null;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.resetIndexCallback(resetIndex); // 콜백 설정

    // Firebase에서 현재 사용자 가져오기
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        userName = currentUser.displayName ?? currentUser.email ?? '아이디';
      });
    }
  }



@override
  Widget build(BuildContext context) {
    //return Scaffold(
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Colors.white,
              child: SafeArea(
                child: Column(
                  children: [
                    TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          child: Text(
                            '허브차와 포푸리',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            '게시판',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          body: TabBarView(
            children: [
              IndexedStack(
                index: _selectedIndex == 1 ? 1 : 0,
                children: [
                  TeaGridView(onTeaSelected: _onTeaSelected),
                  _selectedTea != null
                      ? TeaDetailScreen(
                      herb: _selectedTea!,
                      resetIndexCallback: widget.resetIndexCallback,
                      goBackToFirstScreen: () {
                        setState(() {
                          _selectedIndex = 0;
                          _selectedTea = null;
                        });
                      },
                  )
                      : Container(),
                ],
              ),
              Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    IndexedStack(
                      index: _selectedIndex == 2 ? 1 : 0,
                      children: [
                        BoardGridView(onBoardSelected: _onBoardSelected),
                        _selectedBoard != null
                            ? BoardDetailScreen(
                          title: _selectedBoard!['title']!,
                          content: _selectedBoard!['content']!,
                          herbType: _selectedBoard!['herbType']!,
                          imageUrl: _selectedBoard!['imageUrl']!,
                          userId: _selectedBoard!['userId']!,
                          postId: _selectedBoard!['postId']!,
                          userName: userName, // userName 전달
                          resetIndexCallback: widget.resetIndexCallback,
                          goBackToFirstScreen: () {
                            setState(() {
                              _selectedIndex = 0;
                              _selectedBoard = null;
                            });
                          },
                        )
                            : Container(),
                      ],
                    ),
                    Positioned(
                      bottom: 16.0,
                      right: 16.0,
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WriteScreen(),
                            ),
                          );
                        },
                        child: Icon(Icons.edit),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
}
}