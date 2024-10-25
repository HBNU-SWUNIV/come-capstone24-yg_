import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testproject/screens/home/components/character/show_character.dart';

class LevelUpManager {
  final List<Character> characters;
  final BuildContext context;
  int? selectedCharacterIndex;
  final Function onNewCharacter;
  int nextCharacterImageIndex;
  late final List<Character> dictionaryCharacters;

  LevelUpManager({
    required this.characters,
    required this.context,
    required this.selectedCharacterIndex,
    required this.onNewCharacter,
    required this.dictionaryCharacters,
    required this.nextCharacterImageIndex,
  });

  void checkLevelUp(int index) {
    // 인덱스가 유효한지 확인
    if (index < 0 || index >= characters.length) {
      print('Invalid index: $index, skipping checkLevelUp.');
      return;
    }

    final character = characters[index];

    print('다음 캐릭터 이미지 인덱스: ${nextCharacterImageIndex}');

    // 캐릭터 레벨이 4인지 확인
    if (character.level >= 4) {
      // 도감에 해당 이미지 인덱스가 없으면 레벨업 대화 상자가 뜨도록 함
      bool isInDictionary = dictionaryCharacters.any((c) => c.imageIndex == character.imageIndex);

      print('Is character in dictionary: $isInDictionary');

      if (!isInDictionary) {
        print('Showing level up dialog for character at index $index');
        _showLevelUpDialog(index);
      } else {
        print('캐릭터가 이미 도감에 있음, 다이얼로그 표시 X');
      }
    } else {
      print('캐릭터가 아직 4레벨이 아님, 다이얼로그 표시 X');
    }
  }

  void _showLevelUpDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text("캐릭터가 성장을 완료했어요.\n이제 어떻게 할까요?"),
          actions: [
            TextButton(
              onPressed: () {
                // 도감에 캐릭터 추가
                _addToDictionary(characters[index]);
                Navigator.of(context).pop();
                //nextCharacterImageIndex++;
                _createNewCharacter(index); // 새로운 캐릭터 생성
              },
              child: Text('새로운 캐릭터 만나기'),
            ),
            TextButton(
              onPressed: () {
                // 도감에 캐릭터 추가
                _addToDictionary(characters[index]);
                Navigator.of(context).pop();
              },
              child: Text('계속 키우기'),
            ),
          ],
        );
      },
    );
  }

  // 도감
  void _addToDictionary(Character character) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 기존 도감 데이터를 불러옴
    List<String>? savedDictionaryList = prefs.getStringList('dictionaryCharacters');

    // 만약 저장된 도감 리스트가 null이 아니면 이를 불러와서 decode 후 dictionaryCharacters에 추가
    if (savedDictionaryList != null) {
    // 기존에 초기화된 dictionaryCharacters에 데이터를 추가함 (다시 초기화하지 않음)
    List<Character> loadedCharacters = savedDictionaryList.map((item) {
    Map<String, dynamic> json = jsonDecode(item);
    return Character.fromJson(json);
    }).toList();

    // 중복되지 않는 캐릭터들만 추가
    for (var loadedCharacter in loadedCharacters) {
      if (!dictionaryCharacters.any((c) => c.imageIndex == loadedCharacter.imageIndex)) {
        dictionaryCharacters.add(loadedCharacter);
      }
    }
    }


    // 캐릭터가 도감에 없으면 추가
    if (!dictionaryCharacters.any((c) => c.imageIndex == character.imageIndex)) {
      dictionaryCharacters.add(character);
      print('캐릭터가 도감에 추가되었습니다: ${character.name}');

      // 도감에 추가한 후 SharedPreferences에 저장
      await _saveDictionaryToPreferences();
    } else {
      print('캐릭터가 이미 도감에 존재합니다.');
    }
  }


  Future<void> _saveDictionaryToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> dictionaryList = dictionaryCharacters.isNotEmpty
        ? dictionaryCharacters.map((c) => json.encode({
      'name': c.name,
      'level': c.level,
      'experience': c.experience,
      'imageIndex': c.imageIndex,
    })).toList()
        : [];

    await prefs.setStringList('dictionaryCharacters', dictionaryList);
    await prefs.setInt('nextCharacterImageIndex', nextCharacterImageIndex);
  }


  // 새 캐릭터
  void _createNewCharacter(int index) async {
    if (index < 0 || index >= characters.length) {
      print('Invalid index: $index');
      return;
    }

    characters.removeAt(index);

    // 새로운 캐릭터 생성
    final newCharacter = Character(
      name: "캐릭터 $nextCharacterImageIndex",
      imageIndex: nextCharacterImageIndex,
    );

    print('Adding new character: ${newCharacter.name}');

    // 새 캐릭터를 리스트에 추가
    characters.insert(index, newCharacter);

    // 다음 캐릭터 인덱스를 증가시킴
    nextCharacterImageIndex++;
    print('nextCharacterIndex -> ${nextCharacterImageIndex}');

    // SharedPreferences에 저장
    await _saveCharactersToPreferences();

    // 새 캐릭터가 생성되었음을 알리기 위해 상태 업데이트
    onNewCharacter();

  }

  Future<void> _saveCharactersToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> characterList = characters.isNotEmpty
        ? characters.map((c) => json.encode({
      'name': c.name,
      'level': c.level,
      'experience': c.experience,
      'imageIndex': c.imageIndex,
    })).toList()
        : [];

    await prefs.setStringList('characters', characterList);
    await prefs.setInt('nextCharacterImageIndex', nextCharacterImageIndex);

    // 데이터가 저장된 후 다시 불러와서 확인
    List<String>? savedCharacterList = prefs.getStringList('characters');
    int? savedNextCharacterImageIndex = prefs.getInt('nextCharacterImageIndex');

    // 저장된 데이터를 로그로 출력
    if (savedCharacterList != null) {
      print('Saved characters in SharedPreferences: ${savedCharacterList.map((s) => json.decode(s)).toList()}');
    } else {
      print('No characters found in SharedPreferences.');
    }

    print('Saved nextCharacterImageIndex in SharedPreferences: $savedNextCharacterImageIndex');
   }
}