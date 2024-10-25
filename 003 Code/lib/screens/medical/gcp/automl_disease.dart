import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;

// 서비스 계정 파일을 JWT 방식으로 로드하는 함수
Future<Map<String, dynamic>> loadServiceAccount(String serviceAccountKeyPath) async {
  final String jsonString = await rootBundle.loadString(serviceAccountKeyPath);
  return json.decode(jsonString);
}

Future<int ?> predictImageClassification({
  required String projectId,
  required String endpointId,
  required File imageFile,
  String location = 'us-central1',
  String apiEndpoint = 'us-central1-aiplatform.googleapis.com',
  required String serviceAccountKeyPath, // 서비스 계정 JSON 키 파일 경로
}) async {
  // 서비스 계정 정보 읽기 (JWT 방식)
  final serviceAccountJson = await loadServiceAccount(serviceAccountKeyPath);
  final credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);

  // 인증된 HTTP 클라이언트 생성
  final authClient = await clientViaServiceAccount(credentials, [
    'https://www.googleapis.com/auth/cloud-platform'
  ]);

  // API 호출 URL 생성
  final url = Uri.https(
    apiEndpoint,
    '/v1/projects/$projectId/locations/$location/endpoints/$endpointId:predict',
  );

  // 이미지 파일 읽기
  final bytes = await imageFile.readAsBytes();
  final base64Image = base64Encode(bytes);

  // 요청 본문 작성
  final body = jsonEncode({
    'instances': [
      {
        'content': base64Image,
      }
    ],
    'parameters': {
      'confidence_threshold': 0.5,
      'max_predictions': 5,
    },
  });

  // API 호출
  final response = await authClient.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  int matchedValue = 6;  // 변수 선언을 조건문 밖에서
  // 응답 처리
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);

    // 예측 결과에서 predictions 추출
    final predictions = jsonResponse['predictions'][0];

    // confidences 배열과 displayNames 배열
    final List<double> confidences = List<double>.from(
        predictions['confidences']);
    final List<String> bestPredictNames = List<String>.from(
        predictions['displayNames']);

    final displayNameMapping = {
      '2_wlseltanf': 2,
      '1_wjaansmlqud': 4,
      '3_gmlsrkfnqud': 5,
    };

    final maxConfidenceIndex = confidences.indexWhere((confidence) =>
    confidence == confidences.reduce((a, b) => a > b ? a : b));

    print('Success predict: ${response.statusCode} - ${response.body}');

// confidence 값이 유효한지 확인 (maxConfidenceIndex가 유효한 인덱스인지 확인)
    if (maxConfidenceIndex >= 0 && confidences[maxConfidenceIndex] < 0.7) {
      matchedValue = 6;
    } else if (maxConfidenceIndex >= 0) {
      final bestPredictName = bestPredictNames[maxConfidenceIndex];
      matchedValue = displayNameMapping[bestPredictName] ?? 6;
    }

    if (response.statusCode == 400) {
      matchedValue = 6;
    } else if (response.statusCode != 200) {
      print('Failed to predict: ${response.statusCode} - ${response.body}');
    }

    return matchedValue;
  }
  // 클라이언트 종료
  authClient.close();
}