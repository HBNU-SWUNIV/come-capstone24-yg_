// import 'package:flutter/material.dart';
// import 'package:testproject/screens/home/components/character/show_character.dart';
//
// // 도감 리스트 관리 (HomeScreen과 공유해야 할 리스트)
// List<Character> dictionaryCharacters = [];
//
// // 도감 함수
// void showCharacterDictionary(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierColor: Colors.black.withOpacity(0.7),
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text("캐릭터 도감"),
//         content: Container(
//           width: double.maxFinite,
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: dictionaryCharacters.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 leading: Image.asset('assets/image/character_${dictionaryCharacters[index].imageIndex + 31}.png'),
//                 title: Text(dictionaryCharacters[index].name),
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text('닫기'),
//           ),
//         ],
//       );
//     },
//   );
// }
