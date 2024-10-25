// 예시 캐릭터(화분 캐릭터) 주석처리: ctrl+a, ctrl+/
// import 'package:flutter/material.dart';
// import 'package:rive/rive.dart';
//
// class ShowCharacter extends StatefulWidget {
//   final int level;
//
//   ShowCharacter({required this.level});
//
//   @override
//   _ShowCharacterState createState() => _ShowCharacterState();
// }
//
// class _ShowCharacterState extends State<ShowCharacter> {
//   late StateMachineController _stateMachineController;
//   SMIBool? _Boolean1;
//   SMITrigger? _primoramo1;
//
//   @override
//   void initState() {
//     super.initState();
//     level = widget.level;
//   }
//
//   int? level;
//
//   void _onInit(Artboard art){
//     _stateMachineController = StateMachineController.fromArtboard(art, 'State Machine 1') as StateMachineController;
//     art.addController(_stateMachineController);
//
//     _Boolean1=_stateMachineController.findSMI('Boolean 1');
//     _primoramo1=_stateMachineController.findSMI('primo ramo1');
//
//   }
//
//   void trigger(){
//     _primoramo1?.fire();
//   }
//
//   void togglePrimo(bool newValue){
//     setState(() => _Boolean1!.value = newValue);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Padding(
//         padding: EdgeInsets.only(bottom: 55),
//         child: Center(
//           child: getImageForLevel(),
//         ),
//       ),
//     );
//   }
//
//   // 레벨에 따라 해당하는 이미지를 반환하는 함수
//   Widget getImageForLevel() {
//     switch (level) {
//       case 1:
//         return RiveAnimation.asset('assets/rive/cresci_piantina.riv',
//             onInit: _onInit,
//             alignment: Alignment.center);
//       default:
//         return Container();
//     }
//   }
// }