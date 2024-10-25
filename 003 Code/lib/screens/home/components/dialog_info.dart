import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'addHerb/dialog_addherb.dart';

class InfoBtnDialog extends StatefulWidget {
  // const NewSheetDialog({super.key}); // const 는 생성자를 상수 생성자로 만들려고 하는 시도 / 그러나 여기서 생성자는 기본 생성자이므로 사용할 수 없음

  final String selectedValue; // selectedValue 매개변수 정의
  final List<String> selectedValues2;

  InfoBtnDialog({
    required this.selectedValue,
    required this.selectedValues2
  });

  _InfoBtnDialogState createState() => _InfoBtnDialogState();
}

class _InfoBtnDialogState extends State<InfoBtnDialog> {
  String data = '';
  List<String> selectedValues2Prefs = [];
  String selectedValuePrefs = "식물 미등록";
  Map<String, String> additionalData = {};
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadSavedValue();
    //fetchFileData();
    fetchFileData(widget.selectedValue).then((value) {
      setState(() {
        data = value;
      });
    });

    for (var value in widget.selectedValues2) {
      fetchFileData(value).then((fileData) {
        setState(() {
          additionalData[value] = fileData;
        });
      });
    }
  }

  Future<String> fetchFileData(String value) async {
    String responseText;

    if (value.contains('라벤더')) {
      responseText = await rootBundle.loadString('assets/text/lavandula.txt');
    } else if (value.contains('로즈마리')) {
      responseText = await rootBundle.loadString('assets/text/rosmarinus.txt');
    } else if (value.contains('레몬 밤')) {
      responseText = await rootBundle.loadString('assets/text/lemonbalm.txt');
    } else if (value.contains('세이지')) {
      responseText = await rootBundle.loadString('assets/text/sage.txt');
    } else if (value.contains('스위트 바질')) {
      responseText = await rootBundle.loadString('assets/text/sweetbasil.txt');
    } else if (value.contains('애플민트')) {
      responseText = await rootBundle.loadString('assets/text/applemint.txt');
    } else if (value.contains('케모마일')) {
      responseText = await rootBundle.loadString('assets/text/chamomile.txt');
    } else if (value.contains('페퍼민트')) {
      responseText = await rootBundle.loadString('assets/text/peppermint.txt');
    } else {
      responseText = ''; // 다른 값이 선택된 경우 빈 문자열을 할당
    }

    return responseText;
  }



  _loadSavedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      selectedValuePrefs = prefs.getString('SelectedValue') ?? "식물 미등록";
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> additionalPages = _buildAdditionalPages(widget.selectedValues2);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFCEEFC).withOpacity(0.95),
              Color(0xFFD3C9E3).withOpacity(0.95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: [
                    //_buildPage(widget.selectedValue, data),
                    _buildPage(selectedValuePrefs, data),
                    if (widget.selectedValues2.isNotEmpty) ...additionalPages,
                  ],
                ),
              ),
              SizedBox(height: 20),
              if (selectedValuePrefs != "식물 미등록")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 허브 삭제 버튼
                    OutlinedButton(
                      onPressed: () {
                        // 허브 삭제 로직 처리
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("정말로 삭제할까요?",
                              style: TextStyle(fontSize: 18, color: Color(0xFF49454F), fontWeight: FontWeight.bold),),
                              content: Text("이 허브를 더 이상 기르지 못하는 경우\n삭제할 수 있어요. 육성 중인 캐릭터와\n이별합니다.",
                              style: TextStyle(fontSize: 16),),
                              actions: [
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // 허브 삭제 로직 처리
                                        setState(() {});
                                        Navigator.of(context).pop();  // 삭제 확인 다이얼로그 닫기
                                        Navigator.of(context).pop();  // 원래 다이얼로그 닫기
                                      },
                                      child: Text(
                                        "삭제하기",
                                        style: TextStyle(color: Color(
                                            0xFFB3261E), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "취소하기",
                                        style: TextStyle(color: Color(0xFF49454F), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever),
                          SizedBox(width: 5),
                          Text("허브 삭제"),
                        ],
                      ),
                    ),

                    // 허브 추가 버튼
                    OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.7),
                          barrierDismissible: false,
                          builder: (context) => HerbAddDialog(
                            onConfirm: (List<String> selectedValues) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 5),
                          Text("허브 추가"),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPage(String title, String content) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            content,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }


  List<Widget> _buildAdditionalPages(List<String> selectedValues) {
    if (selectedValues.isEmpty) {
      return [];
    }

    return selectedValues.map((value) {
      return _buildPage(value, additionalData[value] ?? '');
    }).toList();
  }
}