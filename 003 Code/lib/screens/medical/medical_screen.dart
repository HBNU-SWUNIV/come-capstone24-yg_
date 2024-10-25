import 'dart:io';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img; // 이미지 압축을 위한 패키지
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testproject/screens/medical/gcp/automl_disease.dart'; // API 서비스 파일을 임포트
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:testproject/screens/medical/components/dis_card.dart';
import 'package:testproject/screens/medical/components/dis_detail.dart';
import 'package:testproject/screens/medical/components/dis_grid_view.dart';


class MedicalScreen extends StatefulWidget {
  final Function resetIndexCallback;
  const MedicalScreen({super.key, required this.resetIndexCallback});

  @override
  _MedicalScreenState createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen> {
  int _selectedIndex = 0;
  Map<String, String>? _selectedDis;

  void _onSelected(Map<String, String> disease) {
    setState(() {
      _selectedDis = disease;
      _selectedIndex = 1;
    });
  }

  void resetIndex() {
    setState(() {
      _selectedIndex = 0;
      _selectedDis = null;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.resetIndexCallback(resetIndex); // 콜백 설정
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 1,
        child:Scaffold(
          backgroundColor: Colors.white,
          body: TabBarView(
            children: [
              IndexedStack(
                index: _selectedIndex == 1 ? 1:0,
                children: [
                  DisGridView(onSelected: _onSelected),

                  _selectedDis != null
                      ? DisDetailScreen(
                    disease: _selectedDis!,
                    resetIndexCallback: widget.resetIndexCallback,
                    goBackToFirstScreen: () {
                      setState(() {
                        _selectedIndex = 0;
                        _selectedDis = null;
                      });
                    },
                  )
                      : Container(),
                ],
              ),
            ],
          ),
        )
    );
  }
}