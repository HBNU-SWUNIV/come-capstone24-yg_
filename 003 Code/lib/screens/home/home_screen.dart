import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testproject/screens/home/_showCharacterDictionary().dart';
import 'package:testproject/screens/home/components/button/bt_checklist.dart';
import 'package:testproject/screens/home/components/button/bt_herbinformation.dart';
import 'package:testproject/screens/home/components/button/bt_plus.dart';
import 'package:testproject/screens/home/components/character/show_character.dart';
import 'package:testproject/screens/home/components/dialog_plus.dart';
import 'package:testproject/screens/home/components/dialog_plus2.dart';
import 'package:testproject/screens/home/components/tip_box.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:testproject/screens/home/components/dialog_character.dart';

import 'components/addHerb/dialog_addherb.dart';
import 'components/character/LevelUpManager.dart';
import 'components/character/rive_controller.dart';
import 'components/dialog_character.dart';

class HomeScreen extends StatefulWidget {

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StateMachineController _stateMachineController;
  SMITrigger? _Trigger1;

  void _onInit(Artboard art){
    print('Trigger ${selectedCharacterIndex! + 1}${characters[selectedCharacterIndex!].level}');

    _stateMachineController = StateMachineController.fromArtboard(art,
        'State Machine ${(selectedCharacterIndex! + 1) * 3 + characters[selectedCharacterIndex!].level -3}') as StateMachineController;
    art.addController(_stateMachineController);

    _Trigger1=_stateMachineController.findSMI('Trigger ${selectedCharacterIndex! + 1}${characters[selectedCharacterIndex!].level}');
  }

  void trigger1(){
    _Trigger1?.fire();
  }

  double progressValue = 0;
  int level = 1;
  late AudioPlayer _audioPlayer;

  int? selectedCharacterIndex;
  int nextCharacterImageIndex = 1; // 캐릭터 인덱스를 추적하는 변수

  final now = DateTime.now();
  bool waterCheck = false;
  bool LuvCheck = false;
  bool selected = false;
  bool ventilationCheck = false; // 환기
  bool repotCheck = false;
  bool pruneCheck = false;
  bool nutritionCheck = false; // 영양 관리 초기값
  bool harvestCheck = false; // 수확하기 초기값

  // 체크된 상태에서 중복으로 경험치가 올라가는 것을 방지하는 역할1
  bool _luvCheckHandled = false;
  bool _waterCheckHandled = false;
  bool _ventilationCheckHandled = false;
  bool _repotCheckHandled = false;
  bool _pruneCheckHandled = false;
  bool _nutritionCheckHandled = false;
  bool _harvestCheckHandled = false;

  // 체크된 상태에서 중복으로 경험치가 올라가는 것을 방지하는 역할2
  Map<String, bool> LuvChecksHandled = {};
  Map<String, bool> waterChecksHandled = {};
  Map<String, bool> ventilationChecksHandled = {};
  Map<String, bool> repotChecksHandled = {};
  Map<String, bool> pruneChecksHandled = {};
  Map<String, bool> nutritionChecksHandled = {};
  Map<String, bool> harvestChecksHandled = {};

  late Map<String, bool> waterChecks;
  late Map<String, bool> LuvChecks;
  late Map<String, bool> ventilationChecks;
  late Map<String, bool> repotChecks;
  late Map<String, bool> pruneChecks;
  late Map<String, bool> nutritionChecks;
  late Map<String, bool> harvestChecks;

  String selectedValuePrefs = "식물 미등록";
  List<String> selectedValues2Prefs = []; // 허브 추가 등록 관련
  bool _showCharacterImage = false;

  List<Character> dictionaryCharacters = []; // 도감을 관리할 리스트
  List<Character> characters = []; // 현재 캐릭터 리스트
  late LevelUpManager levelUpManager;

  void refreshBtn() async {
    await _loadCheckStatus();  // 체크 상태를 먼저 로드
    _initializeLevelUpManager();  // LevelUpManager를 새로 초기화
    _performLevelUpChecks();  // 레벨업 체크 수행
  }

  void _performLevelUpChecks() {
    for (int i = 0; i < characters.length; i++) {
      levelUpManager.checkLevelUp(i);
    }
  }

  void _initializeLevelUpManager() {
    print('전달되는 다음 이미지 인덱스: ${nextCharacterImageIndex}');
    levelUpManager = LevelUpManager(
      characters: characters,
      context: context,
      selectedCharacterIndex: selectedCharacterIndex,
      dictionaryCharacters: dictionaryCharacters,
      nextCharacterImageIndex: nextCharacterImageIndex,  // 초기화된 nextCharacterIndex 전달
      onNewCharacter: () {
        setState(() {
          // 새 캐릭터가 추가된 후 상태를 업데이트
          _showCharacterImage = characters.isNotEmpty;
        });
      },
    );
  }

  void initState() {
    super.initState();
    _initializeLevelUpManager(); // 레벨업 로드
    _loadCheckStatus(); // 체크리스트 체크상태 로드
    _initializeChecksHandled(); // 중복체크 방지를 위한 로드
    _loadCheckHandled();
    _loadChecksHandled();

    _audioPlayer = AudioPlayer();
    _playMusic(); // 홈 화면 진입 시 음악 재생

    // 앱을 켰을 때 첫 번째 캐릭터가 선택되도록 설정
    if (characters.isNotEmpty) {
      setState(() {
        selectedCharacterIndex = 0;
      });
    }

  }

  Future<void> _playMusic() async {
    try {
      await _audioPlayer.play(AssetSource('audio/background_music1.mp3'));
      print('음악 재생 성공');
    } catch (e) {
      print('음악 재생 실패: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // 화면을 나갈 때 오디오 플레이어를 정리
    super.dispose();
  }

  void _initializeChecksHandled() {
    // 허브 리스트(selectedValues2Prefs) 기반으로 각 맵을 false로 초기화
    LuvChecksHandled = {for (var value in selectedValues2Prefs) value: false};
    waterChecksHandled = {for (var value in selectedValues2Prefs) value: false};
    ventilationChecksHandled = {for (var value in selectedValues2Prefs) value: false};
    repotChecksHandled = {for (var value in selectedValues2Prefs) value: false};
    pruneChecksHandled = {for (var value in selectedValues2Prefs) value: false};
    nutritionChecksHandled = {for (var value in selectedValues2Prefs) value: false};
    harvestChecksHandled = {for (var value in selectedValues2Prefs) value: false};
  }

    _loadCheckHandled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _luvCheckHandled = prefs.getBool('_luvCheckHandled') ?? false;
      _waterCheckHandled = prefs.getBool('_waterCheckHandled') ?? false;
      _ventilationCheckHandled = prefs.getBool('_ventilationCheckHandled') ?? false;
      _repotCheckHandled = prefs.getBool('_repotCheckHandled') ?? false;
      _pruneCheckHandled = prefs.getBool('_pruneCheckHandled') ?? false;
      _nutritionCheckHandled = prefs.getBool('_nutritionCheckHandled') ?? false;
      _harvestCheckHandled = prefs.getBool('_harvestCheckHandled') ?? false;

    });
  }

  void _saveCheckHandled(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value); // 전달된 key에 대해 value를 저장
  }


  void _saveChecksHandled(
      Map<String, bool> luvMap, Map<String, bool> waterMap, Map<String, bool> ventilationMap, Map<String, bool> repotMap, Map<String, bool> pruneMap, Map<String, bool> nutritionMap, Map<String, bool> harvestMap) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String luvJsonString = jsonEncode(luvMap);  // LuvChecksHandled를 JSON으로 변환
    String waterJsonString = jsonEncode(waterMap);  // waterChecksHandled를 JSON으로 변환
    String ventilationJsonString = jsonEncode(ventilationMap);  // ventilationChecksHandled를 JSON으로 변환
    String repotJsonString = jsonEncode(repotMap);
    String pruneJsonString = jsonEncode(pruneMap);
    String nutritionJsonString = jsonEncode(nutritionMap);
    String harvestJsonString = jsonEncode(harvestMap);

    prefs.setString('LuvChecksHandled', luvJsonString);
    prefs.setString('waterChecksHandled', waterJsonString);
    prefs.setString('ventilationChecksHandled', ventilationJsonString);
    prefs.setString('repotChecksHandled', repotJsonString);
    prefs.setString('pruneChecksHandled', pruneJsonString);
    prefs.setString('nutritionChecksHandled', nutritionJsonString);
    prefs.setString('harvestChecksHandled', harvestJsonString);

  }

   _loadChecksHandled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? luvJsonString = prefs.getString('LuvChecksHandled');
    String? waterJsonString = prefs.getString('waterChecksHandled');
    String? ventilationJsonString = prefs.getString('ventilationChecksHandled');
    String? repotJsonString = prefs.getString('repotChecksHandled');
    String? pruneJsonString = prefs.getString('pruneChecksHandled');
    String? nutritionJsonString = prefs.getString('nutritionChecksHandled');
    String? harvestJsonString = prefs.getString('harvestChecksHandled');

    setState(() {
      // LuvChecksHandled 로드
      if (luvJsonString != null) {
        Map<String, dynamic> luvJsonMap = jsonDecode(luvJsonString);
        LuvChecksHandled = luvJsonMap.map((key, value) => MapEntry(key, value as bool));
        // 새로운 캐릭터에 대한 기본값 추가
        for (var value in selectedValues2Prefs) {
          if (!LuvChecksHandled.containsKey(value)) {
            LuvChecksHandled[value] = false; // 기본값으로 false 설정
          }
        }
      } else {
        LuvChecksHandled = {for (var value in selectedValues2Prefs) value: false};
      }

      // waterChecksHandled 로드
      if (waterJsonString != null) {
        Map<String, dynamic> waterJsonMap = jsonDecode(waterJsonString);
        waterChecksHandled = waterJsonMap.map((key, value) => MapEntry(key, value as bool));
        // 새로운 캐릭터에 대한 기본값 추가
        for (var value in selectedValues2Prefs) {
          if (!waterChecksHandled.containsKey(value)) {
            waterChecksHandled[value] = false; // 기본값으로 false 설정
          }
        }
      } else {
        waterChecksHandled = {for (var value in selectedValues2Prefs) value: false};
      }

      // ventilationChecksHandled 로드
      if (ventilationJsonString != null) {
        Map<String, dynamic> ventilationJsonMap = jsonDecode(ventilationJsonString);
        ventilationChecksHandled = ventilationJsonMap.map((key, value) => MapEntry(key, value as bool));
        // 새로운 캐릭터에 대한 기본값 추가
        for (var value in selectedValues2Prefs) {
          if (!ventilationChecksHandled.containsKey(value)) {
            ventilationChecksHandled[value] = false; // 기본값으로 false 설정
          }
        }
      } else {
        ventilationChecksHandled = {for (var value in selectedValues2Prefs) value: false};
      }

      // repotHandled 로드
      if (repotJsonString != null) {
        Map<String, dynamic> repotJsonMap = jsonDecode(repotJsonString);
        repotChecksHandled = repotJsonMap.map((key, value) => MapEntry(key, value as bool));
        // 새로운 캐릭터에 대한 기본값 추가
        for (var value in selectedValues2Prefs) {
          if (!repotChecksHandled.containsKey(value)) {
            repotChecksHandled[value] = false; // 기본값으로 false 설정
          }
        }
      } else {
        repotChecksHandled = {for (var value in selectedValues2Prefs) value: false};
      }

      // pruneHandled 로드
      if (pruneJsonString != null) {
        Map<String, dynamic> pruneJsonMap = jsonDecode(pruneJsonString);
        pruneChecksHandled = pruneJsonMap.map((key, value) => MapEntry(key, value as bool));
        // 새로운 캐릭터에 대한 기본값 추가
        for (var value in selectedValues2Prefs) {
          if (!pruneChecksHandled.containsKey(value)) {
            pruneChecksHandled[value] = false; // 기본값으로 false 설정
          }
        }
      } else {
        pruneChecksHandled = {for (var value in selectedValues2Prefs) value: false};
      }

      // nutritionHandled 로드
      if (nutritionJsonString != null) {
        Map<String, dynamic> nutritionJsonMap = jsonDecode(nutritionJsonString);
        nutritionChecksHandled = nutritionJsonMap.map((key, value) => MapEntry(key, value as bool));
        // 새로운 캐릭터에 대한 기본값 추가
        for (var value in selectedValues2Prefs) {
          if (!nutritionChecksHandled.containsKey(value)) {
            nutritionChecksHandled[value] = false; // 기본값으로 false 설정
          }
        }
      } else {
        nutritionChecksHandled = {for (var value in selectedValues2Prefs) value: false};
      }

      // harvestHandled 로드
      if (harvestJsonString != null) {
        Map<String, dynamic> harvestJsonMap = jsonDecode(harvestJsonString);
        harvestChecksHandled = harvestJsonMap.map((key, value) => MapEntry(key, value as bool));
        // 새로운 캐릭터에 대한 기본값 추가
        for (var value in selectedValues2Prefs) {
          if (!harvestChecksHandled.containsKey(value)) {
            harvestChecksHandled[value] = false; // 기본값으로 false 설정
          }
        }
      } else {
        harvestChecksHandled = {for (var value in selectedValues2Prefs) value: false};
      }
    });
  }


  _loadCharacters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // SharedPreferences에서 저장된 캐릭터 리스트 로드
    List<String>? savedCharacters = prefs.getStringList('characters');
    print('Saved characters in SharedPreferences: ${savedCharacters?.map((s) => json.decode(s)).toList()}');
    // 캐릭터 리스트 초기화
    characters.clear();

    if (savedCharacters != null && savedCharacters.isNotEmpty) {
      // 저장된 각 캐릭터 데이터를 파싱하여 리스트에 추가
      characters = savedCharacters.map((characterString) {
        Map<String, dynamic> characterMap = json.decode(characterString);
        return Character(
          name: characterMap['name'],
          level: characterMap['level'],
          experience: characterMap['experience'],
          imageIndex: characterMap['imageIndex'],
        );
      }).toList();
    }

    // 캐릭터 로드 후 길이 확인
    print('1. Loaded characters length: ${characters.length}');

    // 다음 이미지 인덱스를 정확하게 설정
    setState(() {
      // 현재 로드된 캐릭터 리스트에서 가장 큰 imageIndex 값을 찾고, 다음 인덱스를 설정
      nextCharacterImageIndex = characters.isNotEmpty
          ? characters.map((c) => c.imageIndex).reduce((a, b) => a > b ? a : b) + 1
          : 1;
    });
    print('Characters after loading: ${characters.map((c) => c.level).toList()}');
  }


  void _onCharacterSelected(int index) {
    if (index >= 0 && index < characters.length) {
      setState(() {
        selectedCharacterIndex = index;
      });
    }
  }


  void _increaseFirstCharacterExperience(double value) {
    setState(() {
      // 캐릭터 리스트가 비어 있지 않은지 확인
      if (characters.isEmpty) return;

      // 첫 번째 캐릭터의 경험치 증가
      characters[0].experience += value;

      // 소수점 둘째 자리로 제한
      characters[0].experience = double.parse(characters[0].experience.toStringAsFixed(2));

      if (characters[0].experience >= 1.0) {
        characters[0].level++;
        characters[0].experience -= 1.0;

        print('Calling checkLevelUp with index 0');
        //levelUpManager.checkLevelUp(0);  // 레벨업 체크 호출

      }
    });
    _saveCharactersToPreferences();

  }

  void _decreaseFirstCharacterExperience(double value) {
    setState(() {
      // 캐릭터 리스트가 비어 있지 않은지 확인
      if (characters.isEmpty) return;

      // 첫 번째 캐릭터의 경험치 감소
      characters[0].experience -= value;

      // 소수점 둘째 자리로 제한
      characters[0].experience = double.parse(characters[0].experience.toStringAsFixed(2));

      if (characters[0].experience < 0 && characters[0].level > 1) {
        characters[0].level -= 1;
        characters[0].experience = 1+characters[0].experience;

        print('Calling checkLevelUp with index 0');
      }
    });
    _saveCharactersToPreferences();
  }

  void _increaseAnotherCharacterExperience(int index, double value) {
    setState(() {
      // 캐릭터 리스트가 비어 있지 않은지 확인
      if (characters.isEmpty) return;

      // 첫 번째 이후 캐릭터의 경험치 증가
      characters[index].experience += value;

      // 소수점 둘째 자리로 제한
      characters[index].experience = double.parse(characters[index].experience.toStringAsFixed(2));

      if (characters[index].experience >= 1.0) {
        characters[index].level++;
        characters[index].experience -= 1.0;
      }
    });
    _saveCharactersToPreferences();
  }

  void _decreaseAnotherCharacterExperience(int index, double value) {
    setState(() {
      // 캐릭터 리스트가 비어 있지 않은지 확인
      if (characters.isEmpty) return;

      // 첫 번째 이후 캐릭터의 경험치 감소
      characters[index].experience -= value;

      // 소수점 둘째 자리로 제한
      characters[index].experience = double.parse(characters[index].experience.toStringAsFixed(2));

      if (characters[index].experience <= 0 && characters[index].level > 1) {
        characters[index].level -= 1;
        characters[index].experience = 1+characters[index].experience;

      }

      if (characters[index].experience <= 0 && characters[index].level < 1) {
        characters[index].level == 1;
        characters[index].experience = 0.0;
      }
    });
    _saveCharactersToPreferences();
  }


  _loadCheckStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = DateFormat('yyyy-MM-dd').format(now);

    List<String>? savedCharacters = prefs.getStringList('characters');
    print('Load characters in SharedPreferences: ${savedCharacters?.map((s) => json.decode(s)).toList()}');
    characters.clear();

    if (savedCharacters != null && savedCharacters.isNotEmpty) {
      // 저장된 각 캐릭터 데이터를 파싱하여 리스트에 추가
      characters = savedCharacters.map((characterString) {
        Map<String, dynamic> characterMap = json.decode(characterString);
        return Character(
          name: characterMap['name'],
          level: characterMap['level'],
          experience: characterMap['experience'],
          imageIndex: characterMap['imageIndex'],
        );
      }).toList();
    }

    setState(() {
      LuvCheck = prefs.getBool('$key LUVChecked') ?? false;
      waterCheck = prefs.getBool('$key waterChecked') ?? false;
      ventilationCheck = prefs.getBool('$key ventilationChecked') ?? false;
      repotCheck = prefs.getBool('$key repotChecked') ?? false;
      pruneCheck = prefs.getBool('$key pruneChecked') ?? false;
      nutritionCheck = prefs.getBool('$key nutritionChecked') ?? false;
      harvestCheck = prefs.getBool('$key harvestChecked') ?? false;

      List<String>? currentCharacterList = prefs.getStringList('characters');
      if (currentCharacterList != null) {
        // 각 문자열을 Character 객체로 변환
        characters = currentCharacterList.map((item) {
          Map<String, dynamic> json = jsonDecode(item);  // JSON 문자열을 Map으로 디코드
          return Character.fromJson(json);               // Map을 Character 객체로 변환
        }).toList();
      }
      nextCharacterImageIndex = prefs.getInt('nextCharacterImageIndex') ?? 0 ;

      selectedValuePrefs = prefs.getString('SelectedValue') ?? "식물 미등록";
      selectedValues2Prefs = prefs.getStringList('SelectedValues2') ?? []; // 허브 추가 등록 관련


      // 두 번째 이후 허브의 체크 값 가져오기
      String? waterChecksString = prefs.getString('$key waterChecked2');
      if (waterChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(waterChecksString);
        waterChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        waterChecks = {for (var value in selectedValues2Prefs) value: false};
      }

      String? LuvChecksString = prefs.getString('$key LuvChecked2');
      if (LuvChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(LuvChecksString);
        LuvChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        LuvChecks = {for (var value in selectedValues2Prefs) value: false};
      }

      String? ventilationChecksString = prefs.getString('$key ventilationChecked2');
      if (ventilationChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(ventilationChecksString);
        ventilationChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        ventilationChecks = {for (var value in selectedValues2Prefs) value: false};
      }

      String? repotChecksString = prefs.getString('$key repotChecked2');
      if (repotChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(repotChecksString);
        repotChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        repotChecks = {for (var value in selectedValues2Prefs) value: false};
      }

      String? pruneChecksString = prefs.getString('$key pruneChecked2');
      if (pruneChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(pruneChecksString);
        pruneChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        pruneChecks = {for (var value in selectedValues2Prefs) value: false};
      }

      String? nutritionChecksString = prefs.getString('$key nutritionChecked2');
      if (nutritionChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(nutritionChecksString);
        nutritionChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        nutritionChecks = {for (var value in selectedValues2Prefs) value: false};
      }

      String? harvestChecksString = prefs.getString('$key harvestChecked2');
      if (harvestChecksString != null) {
        Map<String, dynamic> jsonMap = json.decode(harvestChecksString);
        harvestChecks = jsonMap.map((key, value) => MapEntry(key, value as bool));
      } else {
        harvestChecks = {for (var value in selectedValues2Prefs) value: false};
      }

      // 캐릭터 초기화
      _initializeCharacters();

    });
  }

 // void _handleCheckConfirmed(Map<String, bool> checkStates) {
    void _onCheckConfirmed() async {
      await _loadCheckStatus();
      await _loadCheckHandled();
      await _loadChecksHandled();
      //await _initializeCharacters();  // 캐릭터 리스트 초기화

      setState(() {
        print('확인 반응');
        print(
            'Confirmed 체크 확인 ${_waterCheckHandled}, ${_ventilationCheckHandled}, ${_luvCheckHandled}');

        // 체크리스트의 상태에 따라 경험치 증가
        // 경험치가 중복으로 올라가는 것 방지 예를들어 _luvCheckHandled가 false일 때만 경험치가 올라감
        if (LuvCheck == true && characters.isNotEmpty && !_luvCheckHandled) {
          _increaseFirstCharacterExperience(0.2);
          _luvCheckHandled = true; // 경험치 증가 후 체크 상태를 처리 완료로 변경
          _saveCheckHandled('_luvCheckHandled', _luvCheckHandled);
        }
        if (LuvCheck == false && characters.isNotEmpty && _luvCheckHandled) {
          _decreaseFirstCharacterExperience(0.2);
          _luvCheckHandled = false;
          _saveCheckHandled('_luvCheckHandled', _luvCheckHandled);
        }

        if (waterCheck == true && characters.isNotEmpty && !_waterCheckHandled) {
          _increaseFirstCharacterExperience(0.2);
          _waterCheckHandled = true; // 경험치 증가 후 체크 상태를 처리 완료로 변경
          _saveCheckHandled('_waterCheckHandled', _waterCheckHandled);
        }
        if (waterCheck == false && characters.isNotEmpty && _waterCheckHandled) {
          _decreaseFirstCharacterExperience(0.2);
          _waterCheckHandled = false; // 경험치 증가 후 체크 상태를 처리 완료로 변경
          _saveCheckHandled('_waterCheckHandled', _waterCheckHandled);
        }

        if(ventilationCheck == true && characters.isNotEmpty && !_ventilationCheckHandled) {
          _increaseFirstCharacterExperience(0.2);
          _ventilationCheckHandled = true;
          _saveCheckHandled('_ventilationCheckHandled', _ventilationCheckHandled);
        }
        if (ventilationCheck == false && characters.isNotEmpty && _ventilationCheckHandled) {
          _decreaseFirstCharacterExperience(0.2);
          _ventilationCheckHandled = false; // 경험치 증가 후 체크 상태를 처리 완료로 변경
          _saveCheckHandled('_ventilationCheckHandled', _ventilationCheckHandled);
        }

        if(repotCheck == true && characters.isNotEmpty && !_repotCheckHandled) {
          _increaseFirstCharacterExperience(0.4);
          _repotCheckHandled = true;
          _saveCheckHandled('_repotCheckHandled', _repotCheckHandled);
        }
        if (repotCheck == false && characters.isNotEmpty && _repotCheckHandled) {
          _decreaseFirstCharacterExperience(0.4);
          _repotCheckHandled = false; // 경험치 증가 후 체크 상태를 처리 완료로 변경
          _saveCheckHandled('_repotCheckHandled', _repotCheckHandled);
        }

        if(pruneCheck == true && characters.isNotEmpty && !_pruneCheckHandled) {
          _increaseFirstCharacterExperience(0.4);
          _pruneCheckHandled = true;
          _saveCheckHandled('_pruneCheckHandled', _pruneCheckHandled);
        }
        if (pruneCheck == false && characters.isNotEmpty && _pruneCheckHandled) {
          _decreaseFirstCharacterExperience(0.4);
          _repotCheckHandled = false; // 경험치 증가 후 체크 상태를 처리 완료로 변경
          _saveCheckHandled('_pruneCheckHandled', _pruneCheckHandled);
        }

        if(nutritionCheck == true && characters.isNotEmpty && !_nutritionCheckHandled) {
          _increaseFirstCharacterExperience(0.4);
          _nutritionCheckHandled = true;
          _saveCheckHandled('_nutritionCheckHandled', _nutritionCheckHandled);
        }
        if (nutritionCheck == false && characters.isNotEmpty && _nutritionCheckHandled) {
          _decreaseFirstCharacterExperience(0.4);
          _nutritionCheckHandled = false; // 경험치 증가 후 체크 상태를 처리 완료로 변경
          _saveCheckHandled('_nutritionCheckHandled', _nutritionCheckHandled);
        }

        if(harvestCheck == true && characters.isNotEmpty && !_harvestCheckHandled) {
          _increaseFirstCharacterExperience(0.4);
          _harvestCheckHandled = true;
          _saveCheckHandled('_harvestCheckHandled', _harvestCheckHandled);
        }
        if (harvestCheck == false && characters.isNotEmpty && _harvestCheckHandled) {
          _decreaseFirstCharacterExperience(0.4);
          _harvestCheckHandled = false; // 경험치 증가 후 체크 상태를 처리 완료로 변경
          _saveCheckHandled('_harvestCheckHandled', _harvestCheckHandled);
        }

        print('Checks 확인: ${waterChecks}, ${ventilationChecks}, ${LuvChecks}');
        print(
            'Handled 상태 변경 전 확인 ${waterChecksHandled}, ${ventilationChecksHandled}, ${LuvChecksHandled}, ${repotChecksHandled}');

        // 2번째 이후 캐릭터 경험치 변화
        for (int i = 0; i < selectedValues2Prefs.length; i++) {
          String herbName = selectedValues2Prefs[i];
          // 해당 허브 이름이 waterChecks 맵에 있는지 확인하고, true라면 경험치 증가
          if (waterChecks[herbName] == true && characters.isNotEmpty && waterChecksHandled[herbName] == false) {
            _increaseAnotherCharacterExperience(i + 1, 0.2);  // 캐릭터의 경험치를 0.2 증가
            waterChecksHandled[herbName] = true; // 경험치 증가 후 처리 완료로 설정
            _saveChecksHandled(LuvChecksHandled, waterChecksHandled, ventilationChecksHandled, repotChecksHandled, pruneChecksHandled, nutritionChecksHandled, harvestChecksHandled);
          }
          if (waterChecks[herbName] == false && characters.isNotEmpty && waterChecksHandled[herbName] == true) {
            _decreaseAnotherCharacterExperience(i + 1, 0.2);  // 캐릭터의 경험치를 0.2 감소
            waterChecksHandled[herbName] = false; // 경험치 증가 후 처리 완료로 설정
            _saveChecksHandled(LuvChecksHandled, waterChecksHandled, ventilationChecksHandled, repotChecksHandled, pruneChecksHandled, nutritionChecksHandled, harvestChecksHandled);
          }
        }

        for (int i = 0; i < selectedValues2Prefs.length; i++) {
          String herbName = selectedValues2Prefs[i];
          // 해당 허브 이름이 veChecks 맵에 있는지 확인하고, true라면 경험치 증가
          if (LuvChecks[herbName] == true && characters.isNotEmpty && LuvChecksHandled[herbName] == false) {
            _increaseAnotherCharacterExperience(i + 1, 0.2); // 캐릭터의 경험치를 0.2 증가
            LuvChecksHandled[herbName] = true;
            _saveChecksHandled(LuvChecksHandled, waterChecksHandled, ventilationChecksHandled, repotChecksHandled, pruneChecksHandled, nutritionChecksHandled, harvestChecksHandled);
          }
          if (LuvChecks[herbName] == false && characters.isNotEmpty && LuvChecksHandled[herbName] == true) {
            _decreaseAnotherCharacterExperience(i + 1, 0.2); // 캐릭터의 경험치를 0.2 감소
            LuvChecksHandled[herbName] = false; // 경험치 증가 후 처리 완료로 설정
            _saveChecksHandled(LuvChecksHandled, waterChecksHandled, ventilationChecksHandled, repotChecksHandled, pruneChecksHandled, nutritionChecksHandled, harvestChecksHandled);
          }
        }

        for (int i = 0; i < selectedValues2Prefs.length; i++) {
          String herbName = selectedValues2Prefs[i];
          // 해당 허브 이름이 veChecks 맵에 있는지 확인하고, true라면 경험치 증가
          if (ventilationChecks[herbName] == true && characters.isNotEmpty && ventilationChecksHandled[herbName] == false) {
            _increaseAnotherCharacterExperience(i + 1, 0.2); // 캐릭터의 경험치를 0.2 증가
            ventilationChecksHandled[herbName] = true;
            _saveChecksHandled(LuvChecksHandled, waterChecksHandled, ventilationChecksHandled, repotChecksHandled, pruneChecksHandled, nutritionChecksHandled, harvestChecksHandled);
          }
          if (ventilationChecks[herbName] == false && characters.isNotEmpty && ventilationChecksHandled[herbName] == true) {
            _decreaseAnotherCharacterExperience(i + 1, 0.2); // 캐릭터의 경험치를 0.2 감소
            ventilationChecksHandled[herbName] = false;
            _saveChecksHandled(LuvChecksHandled, waterChecksHandled, ventilationChecksHandled, repotChecksHandled, pruneChecksHandled, nutritionChecksHandled, harvestChecksHandled);
          }
        }

        for (int i = 0; i < selectedValues2Prefs.length; i++) {
          String herbName = selectedValues2Prefs[i];
          // 해당 허브 이름이 veChecks 맵에 있는지 확인하고, true라면 경험치 증가
          if (repotChecks[herbName] == true && characters.isNotEmpty && repotChecksHandled[herbName] == false) {
            _increaseAnotherCharacterExperience(i + 1, 0.4); // 캐릭터의 경험치를 0.4 증가
            repotChecksHandled[herbName] = true;
            _saveChecksHandled(LuvChecksHandled, waterChecksHandled, ventilationChecksHandled, repotChecksHandled, pruneChecksHandled, nutritionChecksHandled, harvestChecksHandled);
          }
          if (repotChecks[herbName] == false && characters.isNotEmpty && repotChecksHandled[herbName] == true) {
            _decreaseAnotherCharacterExperience(i + 1, 0.4); // 캐릭터의 경험치를 0.4 감소
            repotChecksHandled[herbName] = false;
            _saveChecksHandled(LuvChecksHandled, waterChecksHandled, ventilationChecksHandled, repotChecksHandled, pruneChecksHandled, nutritionChecksHandled, harvestChecksHandled);
          }
        }

        for (int i = 0; i < selectedValues2Prefs.length; i++) {
          String herbName = selectedValues2Prefs[i];
          // 해당 허브 이름이 veChecks 맵에 있는지 확인하고, true라면 경험치 증가
          if (pruneChecks[herbName] == true && characters.isNotEmpty && pruneChecksHandled[herbName] == false) {
            _increaseAnotherCharacterExperience(i + 1, 0.4); // 캐릭터의 경험치를 0.4 증가
            pruneChecksHandled[herbName] = true;
            _saveChecksHandled(LuvChecksHandled, waterChecksHandled, ventilationChecksHandled, repotChecksHandled, pruneChecksHandled, nutritionChecksHandled, harvestChecksHandled);
          }
          if (pruneChecks[herbName] == false && characters.isNotEmpty && pruneChecksHandled[herbName] == true) {
            _decreaseAnotherCharacterExperience(i + 1, 0.4); // 캐릭터의 경험치를 0.4 감소
            pruneChecksHandled[herbName] = false;
            _saveChecksHandled(LuvChecksHandled, waterChecksHandled, ventilationChecksHandled, repotChecksHandled, pruneChecksHandled, nutritionChecksHandled, harvestChecksHandled);
          }
        }

        for (int i = 0; i < selectedValues2Prefs.length; i++) {
          String herbName = selectedValues2Prefs[i];
          // 해당 허브 이름이 veChecks 맵에 있는지 확인하고, true라면 경험치 증가
          if (nutritionChecks[herbName] == true && characters.isNotEmpty && nutritionChecksHandled[herbName] == false) {
            _increaseAnotherCharacterExperience(i + 1, 0.4); // 캐릭터의 경험치를 0.4 증가
            nutritionChecksHandled[herbName] = true;
            _saveChecksHandled(LuvChecksHandled, waterChecksHandled, ventilationChecksHandled, repotChecksHandled, pruneChecksHandled, nutritionChecksHandled, harvestChecksHandled);
          }
          if (nutritionChecks[herbName] == false && characters.isNotEmpty && nutritionChecksHandled[herbName] == true) {
            _decreaseAnotherCharacterExperience(i + 1, 0.4); // 캐릭터의 경험치를 0.4 감소
            nutritionChecksHandled[herbName] = false;
            _saveChecksHandled(LuvChecksHandled, waterChecksHandled, ventilationChecksHandled, repotChecksHandled, pruneChecksHandled, nutritionChecksHandled, harvestChecksHandled);
          }
        }

        for (int i = 0; i < selectedValues2Prefs.length; i++) {
          String herbName = selectedValues2Prefs[i];
          // 해당 허브 이름이 veChecks 맵에 있는지 확인하고, true라면 경험치 증가
          if (harvestChecks[herbName] == true && characters.isNotEmpty && harvestChecksHandled[herbName] == false) {
            _increaseAnotherCharacterExperience(i + 1, 0.4); // 캐릭터의 경험치를 0.4 증가
            harvestChecksHandled[herbName] = true;
            _saveChecksHandled(LuvChecksHandled, waterChecksHandled, ventilationChecksHandled, repotChecksHandled, pruneChecksHandled, nutritionChecksHandled, harvestChecksHandled);
          }
          if (harvestChecks[herbName] == false && characters.isNotEmpty && harvestChecksHandled[herbName] == true) {
            _decreaseAnotherCharacterExperience(i + 1, 0.4); // 캐릭터의 경험치를 0.4 감소
            harvestChecksHandled[herbName] = false;
            _saveChecksHandled(LuvChecksHandled, waterChecksHandled, ventilationChecksHandled, repotChecksHandled, pruneChecksHandled, nutritionChecksHandled, harvestChecksHandled);
          }
        }
        print(
            'Confirmed 상태 변경 후 확인 ${waterChecksHandled}, ${ventilationChecksHandled}, ${LuvChecksHandled}, ${repotChecksHandled}');

      });
  }




  Future<void> _saveCharactersToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 캐릭터 리스트를 JSON 문자열로 변환
    List<String> characterList = characters.isNotEmpty
        ? characters.map((c) => json.encode({
      'name': c.name,
      'level': c.level,
      'experience': c.experience,
      'imageIndex': c.imageIndex,
    })).toList()
        : [];

    // SharedPreferences에 저장
    await prefs.setStringList('characters', characterList);
    await prefs.setInt('nextCharacterImageIndex', nextCharacterImageIndex!);
  }

  _initializeCharacters() async {
    int CharactersLength= characters.length;

    for (int i = 0; i < selectedValues2Prefs.length; i++) {
      bool characterExists = false;

      // 현재 캐릭터 리스트에서 해당 name이 있는지 확인
      for (var character in characters) {
        if (character.name == selectedValues2Prefs[i]) {
          characterExists = true;
          break; // 이미 존재하면 더 이상 확인할 필요 없음
        }
      }

      // 캐릭터가 존재하지 않으며, selectedValues2Prefs의 길이가 characters보다 길거나 같은 경우 추가 캐릭터 생성
      if (!characterExists && selectedValues2Prefs.length >= characters.length) {
        characters.add(Character(
            name: selectedValues2Prefs[i], imageIndex: nextCharacterImageIndex)); // 추가 캐릭터 생성
        nextCharacterImageIndex += 1;
      }
    }
    print('저장된 다음 이미지 인덱스 : ${nextCharacterImageIndex}');

    // 캐릭터 리스트를 SharedPreferences에 저장
    await _saveCharactersToPreferences();

    setState(() {
      _showCharacterImage = characters.isNotEmpty;

    });

  }

  void _onHerbAdded(String selectedValue) async{
    setState(() {
      selectedValuePrefs = selectedValue;
      _saveCheckStatus(LuvCheck, waterCheck, selected, selectedValue);

      // 첫 번째 캐릭터가 추가되면 자동으로 선택
      if (characters.length == 1) {
        selectedCharacterIndex = 0;
      }
    });

    // SelectedValue가 있으면 첫 번째 캐릭터 생성
    if (selectedValuePrefs.isNotEmpty && selectedValuePrefs != "식물 미등록" && characters.isEmpty) {
      characters.add(Character(name: selectedValuePrefs, imageIndex: 0,));
    }

    nextCharacterImageIndex += 1;

    // 첫 번째 허브가 추가된 후 캐릭터 이미지 표시
    if (selectedValuePrefs.isNotEmpty) {
      _showCharacterImage = true;
    }

    // 캐릭터 리스트를 SharedPreferences에 저장
    await _saveCharactersToPreferences();

  }

  void _resetAll() async {
    // 초기화 SharedPreferences 데이터
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = DateFormat('yyyy-MM-dd').format(now);

    // 모든 SharedPreferences 데이터 삭제
    await prefs.clear();

    // 상태 초기화
    setState(() {
      characters.clear();
      selectedCharacterIndex = null;
      selectedValuePrefs = "식물 미등록";
      selectedValues2Prefs = [];
      _showCharacterImage = false;
      progressValue = 0;
      level = 1;

      LuvCheck = false;
      waterCheck = false;
      ventilationCheck = false;
      selected = false;

      dictionaryCharacters = [];
      nextCharacterImageIndex = 0;

      _luvCheckHandled = false;
      _waterCheckHandled = false;
      _ventilationCheckHandled = false;
      _repotCheckHandled = false;
      _pruneCheckHandled = false;
      _nutritionCheckHandled = false;
      _harvestCheckHandled = false;

      LuvChecksHandled = {};
      waterChecksHandled = {};
      ventilationChecksHandled = {};
      repotChecksHandled = {};
      pruneChecksHandled = {};
      nutritionChecksHandled = {};
      harvestChecksHandled = {};

      _saveCheckStatus(LuvCheck, waterCheck, selected, selectedValuePrefs);
    });
  }


  _saveCheckStatus(bool LuvCheck, bool waterCheck, bool selected, String selectedValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = DateFormat('yyyy-MM-dd').format(now);

    await prefs.setBool('$key LUVChecked', LuvCheck);
    await prefs.setBool('$key waterChecked', waterCheck);
    await prefs.setBool('Selected', selected);
    await prefs.setString('SelectedValue', selectedValue);

  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          Positioned(
            left: 40,
            top: 38,
            child: IconButtonExample1(selectedValue: selectedValuePrefs,
              onConfirmed: _onCheckConfirmed,
            ),),

          Positioned(
            right: 40,
            top: 38,
            child: IconButtonExample2(selectedValue: selectedValuePrefs,
            ),),

          if (characters.isEmpty)
          // 첫 번째 허브 추가 버튼
            Center(
              child: IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: Color(0xFBE0DCE3),
                  size: 55,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.7),
                    barrierDismissible: false,
                    builder: (context) => PlusBtnDialog(
                      onConfirm: _onHerbAdded,
                    ),
                  );
                },
              ),
            ),

          //동적 버튼 생성
          Positioned(
            bottom: 162,
            left: 20,
            //right: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(characters.length, (index) {
                return ElevatedButton(
                  onPressed: () => _onCharacterSelected(index),
                  //child: Text(characters[index].name),
                  child: Text((index + 1).toString()),
                );
              }),
            ),
          ),

          // 선택된 캐릭터의 정보 표시
          if (selectedCharacterIndex != null && selectedCharacterIndex! < characters.length)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    child: RiveAnimation.asset(
                      characters[selectedCharacterIndex!].getRiveFilePath(),  // 캐릭터의 레벨에 따른 Rive 파일 경로
                      onInit: _onInit,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 20),

                  Text(
                    'Level: ${characters[selectedCharacterIndex!].level}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 300,
                    child: LinearProgressIndicator(
                      value: characters[selectedCharacterIndex!].experience,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

          // 도감
          Positioned(
            bottom: 210,
            right: 40,
            child: IconButton(
              icon: Icon(
                Icons.pets,
                size: 35,
              ),
              onPressed: () {
                showCharacterDialog(context, characters, dictionaryCharacters); // 리스트 전달
              },
            ),
          ),

          //tip 박스
          Padding(
            padding: EdgeInsets.only(top: 400),
            child: Center(
              child: TipBox(selectedValue: selectedValuePrefs), // TipBox 위젯을 호출
            ),
          ),


          // 새로고침
          Positioned(
            bottom: 158,
            right: 40,
            child: SizedBox(
              width: 48,
              child: Stack(
                children: [
                  OutlinedButton(
                    onPressed: refreshBtn,
                    child: SizedBox(),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.restart_alt),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 초기화 버튼 (나중에 옮길 예정)
          Positioned(
            bottom: 22,
            right: 10,
            child: SizedBox(
              width: 48,
              child: Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.restore_from_trash),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      _resetAll;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}