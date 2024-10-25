import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class Character {
  int level;
  double experience;
  int imageIndex;  // 고유한 이미지 인덱스 (예: 캐릭터별 고유 ID)

  late String name;  // 캐릭터 이름

  Character({
    required this.name,
    this.level = 1,
    this.experience = 0.0,
    required this.imageIndex,
  }) {
    // 캐릭터 이름을 파일 이름에 맞춰 자동 생성
    name = _generateCharacterName();
  }
  // 캐릭터의 레벨과 인덱스에 맞는 Rive 파일 경로 반환
  String getRiveFilePath() {
    return 'assets/rive/ch${imageIndex + 1}_${level}.riv';
  }

  // 파일 이름 기반으로 캐릭터 이름을 생성하는 함수
  String _generateCharacterName() {
    switch (imageIndex + 1) {
      case 1:
        return "캐머";
      case 2:
        return "레모";
      case 3:
        return "메리";
      case 4:
        return "다라민티";
      case 5:
        return "라벤독";

      default:
        return "기본 캐릭터";
    }
  }

  // 캐릭터가 레벨업 할 때 호출되는 함수
  void levelUp() {
    if (level < 3) {
      level++;
      experience = 0.0;  // 레벨업 후 경험치는 초기화
    }
  }

  // 캐릭터 정보를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'experience': experience,
      'imageIndex': imageIndex,
    };
  }

  // JSON에서 캐릭터 정보를 생성
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'],
      level: json['level'],
      experience: json['experience'],
      imageIndex: json['imageIndex'],
    );
  }
}
