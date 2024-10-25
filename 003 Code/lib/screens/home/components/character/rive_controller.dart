// import 'package:rive/rive.dart';
//
// class RiveController {
//   late StateMachineController _stateMachineController;
//   SMITrigger? _trigger1;
//
//   void onInit(Artboard art, String stateMachineName) {
//     _stateMachineController = StateMachineController.fromArtboard(art, stateMachineName) as StateMachineController;
//     art.addController(_stateMachineController);
//
//     _trigger1 = _stateMachineController.findSMI('Trigger1');
//   }
//
//   void trigger1() {
//     _trigger1?.fire();
//   }
// }
