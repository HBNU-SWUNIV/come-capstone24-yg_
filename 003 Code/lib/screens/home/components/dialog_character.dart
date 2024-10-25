import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'character/show_character.dart';

class CharacterDialog extends StatefulWidget {
  final List<Character> characters; // 현재 캐릭터 리스트
  final List<Character> dictionaryCharacters;  // 도감 캐릭터 리스트

  CharacterDialog({required this.characters, required this.dictionaryCharacters});

  @override
  _CharacterDialogState createState() => _CharacterDialogState();
}

class _CharacterDialogState extends State<CharacterDialog> {
  // 초기 상태: '도감'이 선택된 상태
  int _selectedIndex = 0;
  int _currentPage = 0; // PageView의 현재 페이지를 추적

  // 캐릭터 설명
  final String characterDescription = "이 캐릭터는 매우 특별한 캐릭터입니다.";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 18.0, 32.0, 18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 타이틀
              Text(
                '나의 캐릭터',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF49454F)
                ),
              ),
              SizedBox(height: 10),

          // 토글버튼
          ToggleButtons(
            borderRadius: BorderRadius.circular(30),
            borderColor: Color(0xFF4F378B),
            selectedBorderColor: Color(0xFF4F378B),
            color: Colors.black,
            constraints: BoxConstraints(minHeight: 35.0),
            isSelected: [_selectedIndex == 0, _selectedIndex == 1],
            onPressed: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text('스토리'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text('도감'),
                        ),
                      ],
                    ),
              SizedBox(height: 25),

              _selectedIndex == 0
                  ? _buildStoryView() // 캐릭터 설명 뷰
                  : _buildDictionaryView(), // 도감 뷰
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('닫기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

// 도감 뷰 (리스트)
  Widget _buildDictionaryView() {
    return SizedBox(
      height: 200, // 명시적인 고정 높이 설정
      child: ListView.builder(
        itemCount: widget.dictionaryCharacters.length,
        itemBuilder: (context, index) {
          final character = widget.dictionaryCharacters[index];
          return ListTile(
            title: Text(character.name),
            subtitle: Text(
                '레벨: ${character.level}, 경험치: ${character.experience}'),
            leading: ClipOval(
              child: Image.asset(
                'assets/profile/character_${character.imageIndex + 1}_profile.png', // 캐릭터 이미지
                fit: BoxFit.cover,  // 이미지를 꽉 채움
                width: 55.0,        // 이미지 크기 설정 (원하는 대로 조정 가능)
                height: 55.0,
              ),
            ),
          );
        },
      ),
    );
  }

// 캐릭터 설명 뷰 (PageView로 스크롤 가능하게 설정)
  Widget _buildStoryView() {
    double screenHeight = MediaQuery.of(context).size.height; // 화면 전체 높이를 가져옴

    return SizedBox(
      height: screenHeight * 0.52, // 화면 비율의 80%로 높이 설정
      child: PageView.builder(
        itemCount: widget.characters.length,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page; // 현재 페이지 인덱스를 추적
          });
        },
        itemBuilder: (context, index) {
          final character = widget.characters[index];
          return SingleChildScrollView( // 스크롤 가능하게 만듦
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
              children: [
                Center(
                  child: Image.asset(
                    'assets/profile/character_${character.imageIndex + 1}_profile.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 15),

                Text(
                  '${character.name}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5F326F, )),
                  textAlign: TextAlign.center, // 왼쪽 정렬
                ),
                SizedBox(height: 5),
                Text(
                  '${character.level} 레벨  |  현재 경험치 ${character.experience}',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  '스토리 추가 예시) 다라민티는 도토리를 아주 좋아하는 친구입니다. 하지만 멋진 도토리를 눈앞에 두고 다람이는 식욕이 없어 보이는데요···',
                  style: TextStyle(fontSize: 14, color: Color(0xFF49454F)),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}

void showCharacterDialog(BuildContext context, List<Character> characters, List<Character> dictionaryCharacters) async {
  // SharedPreferences에서 도감 데이터 불러오기
  List<Character> dictionaryCharacters = await _loadDictionaryFromPreferences();
  List<Character> characters = await _loadCurrentCharacterFromPreferences();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CharacterDialog(
          characters: characters,
          dictionaryCharacters: dictionaryCharacters
      );
    },
  );
}

// SharedPreferences에서 도감 데이터 불러오기
Future<List<Character>> _loadDictionaryFromPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? dictionaryList = prefs.getStringList('dictionaryCharacters');

  if (dictionaryList != null) {
    return dictionaryList.map((item) {
      Map<String, dynamic> json = jsonDecode(item);
      return Character.fromJson(json);
    }).toList();
  }

  return [];
}

// SharedPreferences에서 현재 캐릭터 데이터 불러오기
Future<List<Character>> _loadCurrentCharacterFromPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? CharacterList = prefs.getStringList('characters');

  if (CharacterList != null) {
    return CharacterList.map((item) {
      Map<String, dynamic> json = jsonDecode(item);
      return Character.fromJson(json);
    }).toList();
  }

  return [];
}
