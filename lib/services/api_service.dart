// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_clinder/domain/User.dart'; // User 모델 임포트

class ApiService {
  // Spring Boot 서버의 IP 주소와 포트를 정확히 지정합니다.
  // 에뮬레이터에서 localhost는 호스트 PC를 가리키지 않습니다.
  // 호스트 PC의 IP 주소를 사용하거나, 안드로이드 에뮬레이터의 경우 10.0.2.2를 사용합니다.
  // iOS 시뮬레이터의 경우 localhost (127.0.0.1)를 사용할 수 있습니다.
  final String _baseUrl = 'http://localhost:8081'; // Android Emulator
  // final String _baseUrl = 'http://localhost:8081'; // iOS Simulator or Web

  // 회원가입 요청
  Future<String> registerUser(User user) async {
    final url = Uri.parse('$_baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        return '회원가입 성공: ${response.body}';
      } else {
        return '회원가입 실패: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return '네트워크 오류: $e';
    }
  }

  // 로그인 요청
  Future<String> loginUser(String loginId, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(LoginRequest(loginId: loginId, password: password).toJson()),
      );

      if (response.statusCode == 200) {
        return '로그인 성공: ${response.body}';
      } else if (response.statusCode == 401) {
        return '로그인 실패: 아이디 또는 비밀번호 불일치';
      } else {
        return '로그인 실패: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return '네트워크 오류: $e';
    }
  }
}