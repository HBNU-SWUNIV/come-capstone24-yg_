// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class HerbAddDialog2 extends StatefulWidget {
//   final String selectedValue;
//
//   HerbAddDialog2({required this.selectedValue});
//
//   @override
//   _HerbAddDialog2State createState() => _HerbAddDialog2State();
// }
//
// class _HerbAddDialog2State extends State<HerbAddDialog2> {
//   bool _waterSetting = true;
//   bool _notificationSetting = true;
//   bool _showTextField = false;
//   bool selected2 = false;
//   TextEditingController _textFieldController = TextEditingController();
//   List<String> _selectedValues2 = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedValue = widget.selectedValue;
//     _loadSelectedValues();
//   }
//
//   String? _selectedValue;
//
//   Future<void> _loadSelectedValues() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String>? storedValues = prefs.getStringList('SelectedValues2');
//     if (storedValues != null) {
//       setState(() {
//         _selectedValues2 = List.from(storedValues);
//       });
//     }
//   }
//
//   _saveCheckStatus(List<String> selectedValues2) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     //await prefs.setBool('Selected2', selected2);
//     await prefs.setStringList('SelectedValues2', selectedValues2);
//   }
//
//
//   void _addSelectedValue(String newValue) {
//     if (_selectedValues2.length < 5) {
//       setState(() {
//         _selectedValues2.add(newValue);
//       });
//       _saveCheckStatus(_selectedValues2);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('최대 5개의 허브만 추가할 수 있습니다.'),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(
//         "관리를 도와드릴게요",
//         textAlign: TextAlign.center,
//         style: TextStyle(
//             fontSize: 18,
//             color: Color(0xFF2b2b2b),
//             fontWeight: FontWeight.bold
//         ),
//       ),
//
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 12),
//             Text(
//               "📍 물 주는 날짜를 허브에 맞추어 자동으로 설정할까요? (초보자 추천)",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF2b2b2b),
//               ),
//             ),
//             SizedBox(height: 16),
//             Row(
//               children: [
//                 Radio(
//                   value: true,
//                   groupValue: _waterSetting,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       _waterSetting = value!;
//                     });
//                   },
//                 ),
//                 Text("네",
//                   style: TextStyle(
//                       fontSize: 18
//                   ),
//                 ),
//                 Radio(
//                   value: false,
//                   groupValue: _waterSetting,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       _waterSetting = value!;
//                       if (!_waterSetting) {
//                         _showTextField = true;
//                       } else {
//                         _showTextField = false;
//                       }
//                     });
//                   },
//                 ),
//                 Text("아니오",
//                   style: TextStyle(
//                       fontSize: 16
//                   ),
//                 ),
//               ],
//             ),
//             if (_showTextField)
//               TextField(
//                 controller: _textFieldController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   hintText: '며칠에 한 번씩 물 주기를 설정할까요?',
//                 ),
//               ),
//             SizedBox(height: 20), // 여분의 여백
//             Text(
//               "📍 할 일을 잊으셨다면 알림을 보내드릴까요? (매일 오후 8시 발송)",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF2b2b2b),
//               ),
//             ),
//             Row(
//               children: [
//                 Radio(
//                   value: true,
//                   groupValue: _notificationSetting,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       _notificationSetting = value!;
//                     });
//                   },
//                 ),
//                 Text("네",
//                   style: TextStyle(
//                       fontSize: 18
//                   ),
//                 ),
//                 Radio(
//                   value: false,
//                   groupValue: _notificationSetting,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       _notificationSetting = value!;
//                     });
//                   },
//                 ),
//                 Text("아니오",
//                   style: TextStyle(
//                       fontSize: 16
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           child: Text("취소"),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         TextButton(
//           onPressed: () {
//             _addSelectedValue(_selectedValue!);
//             //selected2 = true;
//
//             Navigator.of(context).pop();
//           },
//           child: Text("완료"),
//         ),
//       ],
//     );
//   }
// }
