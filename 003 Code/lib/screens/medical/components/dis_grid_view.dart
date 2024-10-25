import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img; // 이미지 압축을 위한 패키지
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:testproject/screens/medical/components/dis_card.dart';
import 'package:testproject/screens/medical/components/dis_detail.dart';
import 'package:testproject/screens/medical/components/dis_grid_view.dart';
import 'package:testproject/screens/medical/gcp/automl_disease.dart'; // API 서비스 파일을 임포트

class DisGridView extends StatefulWidget {
  final Function(Map<String, String>) onSelected;
  const DisGridView({super.key, required this.onSelected});

  @override
  _DisGridViewState createState() => _DisGridViewState();
}

class _DisGridViewState extends State<DisGridView> {
  late Future<List<Map<String, String>>> disData;

  late CameraController _controller;
  late List<CameraDescription> _cameras;
  late Future<void> _initializeControllerFuture;

  File? _image;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    disData = _loadDisData();
  }

  Future<void> _initializeCamera() async {
    await Permission.camera.request();
    _cameras = await availableCameras();
    _controller = CameraController(_cameras.first, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<File> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      return File(image.path)..copy(imagePath);
    } catch (e) {
      print('Error capturing image: $e');
      return Future.error(e);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  /// 이미지 압축 함수
  Future<File> _compressImage(File file) async {
    final imageBytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    img.Image resizedImage = img.copyResize(image!, width: 800);

    final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
    final directory = await getApplicationDocumentsDirectory();
    final compressedFilePath =
        '${directory.path}/compressed_${file.path.split('/').last}';
    final compressedFile = File(compressedFilePath)
      ..writeAsBytesSync(compressedBytes);

    return compressedFile;
  }

  Future<int?> _predictDisease(File imageFile) async {
    const String projectId = '';
    const String endpointId = '';
    const String serviceAccountKeyPath = 'service-key/second_account.json';

    try {
      final compressedImage = await _compressImage(imageFile);

      // AI Platform 예측 API 호출
      final matchedValue = await predictImageClassification(
        projectId: projectId,
        endpointId: endpointId,
        imageFile: compressedImage, // 압축된 이미지 파일 사용
        serviceAccountKeyPath: serviceAccountKeyPath,
      );

      return matchedValue;
    } catch (e) {
      print('Prediction error: $e');
      final matchedValue = 6;
      return matchedValue;
    }
  }

  Future<List<Map<String, String>>> _loadDisData() async {
    final String response =
        await rootBundle.loadString('assets/data/disease_data.json');
    final List<dynamic> data = json.decode(response);
    return data
        .map((item) => {
              'titleImage': item['titleImage'] as String,
              'DImage': item['DImage'] as String,
              'title': item['title'] as String,
              'titleContent': item['titleContent'] as String,
              'SolContent': item['SolContent'] as String,
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 사진으로 병을 진단하는 섹션
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '사진',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '으로 병을 진단받고 싶어요',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final image = await _takePicture();
                      setState(() {
                        _image = image;
                      });
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Gallery"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (_image != null) //미리보기
                Stack(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white70, size: 15),
                          onPressed: () {
                            setState(() {
                              _image = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),

              if (_image != null)
                FutureBuilder<List<Map<String, String>>>(
                  future: disData, // disData FutureBuilder로 가져오기
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No data found'));
                    } else {
                      final disData = snapshot.data!;

                      return _isLoading
                          ? const Center(
                              child: CircularProgressIndicator()) // 로딩 중 표시
                          : ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true; // 로딩 상태로 변경
                                });

                                if (_image != null) {
                                  final matchedValue =
                                      await _predictDisease(_image!);
                                  if (matchedValue != null &&
                                      matchedValue < disData.length) {
                                    // matchedValue로 disData 항목 선택
                                    widget.onSelected(disData[matchedValue]);
                                  } else {
                                    print(
                                        'Prediction failed or no match found.');
                                  }
                                }

                                setState(() {
                                  _isLoading = false; // 로딩 상태 해제
                                });
                              },
                              child: const Text('Predict Disease'),
                            );
                    }
                  },
                ),

              Align(
                alignment: Alignment.centerRight, // 왼쪽 정렬
                child: const Text(
                  "주의사항: 구별가능한 종류는 진딧물, 흰가루병, 점무늬병입니다.",
                  style: TextStyle(
                    color: Colors.grey, // 글씨 색상을 회색으로 설정
                    fontSize: 13.0, // 글씨 크기를 작게 설정
                  ),
                ),
              ),

              const Divider(thickness: 1, color: Color(0x8FABABAB)),

              const SizedBox(height: 20),

              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '병해충',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              FutureBuilder<List<Map<String, String>>>(
                future: disData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data found'));
                  } else {
                    final disData = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true, // GridView의 크기를 내용에 맞게 축소
                      physics:
                          NeverScrollableScrollPhysics(), // GridView 자체 스크롤 비활성화
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1 / 1.6,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 20,
                      ),
                      padding: const EdgeInsets.all(22.0),
                      itemCount: 6,
                      itemBuilder: (BuildContext context, int index) {
                        final disease = disData[index];
                        return GestureDetector(
                          onTap: () {
                            print(index);
                            widget.onSelected(disease);
                          },
                          child: Container(
                            child: Card(
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 16.0 / 18.0,
                                      child: Image.asset(
                                        disease['titleImage']!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 16.0, 16.0, 16.0),
                                    child: Text(
                                      disease['title']!,
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
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
            ],
          ),
        ),
      ),
    );
  }
}
