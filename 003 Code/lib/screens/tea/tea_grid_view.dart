import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:testproject/screens/tea/tea_detail.dart';

class TeaGridView extends StatefulWidget {
  //const TeaGridView({super.key});
  final Function(Map<String, String>) onTeaSelected;


  const TeaGridView({super.key, required this.onTeaSelected});

  @override
  _TeaGridViewState createState() => _TeaGridViewState();
}

class _TeaGridViewState extends State<TeaGridView> {
  late Future<List<Map<String, String>>> herbData;

  @override
  void initState() {
    super.initState();
    herbData = _loadTeaData();
  }

  Future<List<Map<String, String>>> _loadTeaData() async {
    final String response = await rootBundle.loadString('assets/data/herb_data.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => {
      'titleImage': item['titleImage'] as String,
      'teaImage': item['teaImage'] as String,
      'title': item['title'] as String,
      'titleContent': item['titleContent'] as String,
      'teaContent': item['teaContent'] as String,
      'potpourriImage': item['potpourriImage'] as String,
      'potpourriContent' : item['potpourriContent'] as String,
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, String>>>(
        future: herbData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            final herbData = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1 / 1.6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 20,
              ),
              padding: const EdgeInsets.all(22.0),
              itemCount: herbData.length,
              itemBuilder: (BuildContext context, int index) {
                final herb = herbData[index];
                return GestureDetector(
                  onTap: () {
                    widget.onTeaSelected(herb);
                  },

                  child: Container(
                    child: Card(
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10), // 이미지 위 모서리 둥글게 설정
                              topRight: Radius.circular(10), // 이미지 위 모서리 둥글게 설정
                            ),
                            child: AspectRatio(
                              aspectRatio: 16.0 / 18.0,
                              child: Image.asset(
                                herb['titleImage']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                              child: AutoSizeText(
                                herb['title']!,
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,  // 텍스트가 길면 생략표시(...)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                },
            );
          }
        },
      ),
    );
  }
}