import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:project_clinder/domain/User.dart'; // 기존 User/LoginRequest 모델 임포트
import 'package:project_clinder/domain/Schedule.dart'; // <-- 경로 변경
import 'package:project_clinder/domain/notification.dart' as app_notification; // <-- 경로 변경 및 알리아스 유지

class ApiService {
  final String _baseUrl = 'http://localhost:8081/api'; // Android Emulator 기준

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

  // 클라이밍 센터 목록 가져오기
  Future<List<Map<String, dynamic>>> getClimbingCenters() async {
    final url = Uri.parse('$_baseUrl/climbing-centers'); // 백엔드 엔드포인트 URL
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> centersJson = jsonDecode(utf8.decode(response.bodyBytes));
        return centersJson.map((center) => center as Map<String, dynamic>).toList();
      } else {
        throw Exception('클라이밍 센터 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류 또는 데이터 파싱 오류: $e');
    }
  }

  // 특정 사용자 ID의 일정 목록을 가져오는 메서드
  Future<List<Schedule>> getSchedulesByUserId(int userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/schedules/user/$userId'));

    if (response.statusCode == 200) {
      final String rawJson = utf8.decode(response.bodyBytes);
      print('Received raw JSON for schedules: $rawJson');

      final List<dynamic> jsonList = jsonDecode(rawJson); // utf8.decode를 한 번만 사용
      return jsonList.map((json) => Schedule.fromJson(json)).toList();
    } else {
      print('일정 목록 조회 실패: ${response.statusCode}');
      print('응답 본문: ${utf8.decode(response.bodyBytes)}');
      throw Exception('Failed to load schedules: ${response.statusCode}');
    }
  }

  // 사용자 일정 생성 메서드
  Future<void> createSchedule({
    required String title,
    String? category,
    required DateTime? startDate,
    required TimeOfDay? startTime,
    required DateTime? endDate,
    required TimeOfDay? endTime,
    required bool isAllDay,
    required String repeatOption,
    required String reminderOption,
    required bool isClimbingSchedule,
    String? climbingCenterName,
    int? userId,
    String? place,
    String? memo,
    List<Map<String, dynamic>>? allClimbingCenters,
  }) async {
    String? startDateTimeStr;
    if (startDate != null && startTime != null) {
      final combinedStart = DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute);
      startDateTimeStr = combinedStart.toIso8601String();
    }

    String? endDateTimeStr;
    if (endDate != null && endTime != null) {
      final combinedEnd = DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);
      endDateTimeStr = combinedEnd.toIso8601String();
    }

    // `recurringPattern`은 `_mapRepeatOptionToDb`에서 계산됩니다.
    String? recurringPattern = _mapRepeatOptionToDb(repeatOption);

    DateTime? notificationTime;
    bool notificationEnabled = false;
    if (reminderOption != '안 함' && startDateTimeStr != null) {
      notificationEnabled = true;
      notificationTime = _calculateNotificationTime(
          DateTime.parse(startDateTimeStr), reminderOption);
    }

    String? notificationTimeStr;
    if (notificationTime != null) {
      notificationTimeStr = notificationTime.toIso8601String();
    }

    int? centerId;
    if (isClimbingSchedule && climbingCenterName != null && allClimbingCenters != null) {
      try {
        centerId = allClimbingCenters
            .firstWhere((center) => center['name'] == climbingCenterName)['center_id'];
      } catch (e) {
        print('Warning: Climbing center ID not found for $climbingCenterName, error: $e');
      }
    }

    final Map<String, dynamic> body = {
      'userId': userId ?? 6,
      'centerId': centerId,
      'title': title,
      'category': category,
      'startTime': startDateTimeStr,
      'endTime': endDateTimeStr,
      'isAllDay': isAllDay,
      'notes': memo,
      'isRecurring': repeatOption != '안 함',
      'recurringPattern': recurringPattern,
      'place': place,
      'notificationEnabled': notificationEnabled,
      'notificationTime': notificationTimeStr,
    };

    print('Sending create schedule data: ${jsonEncode(body)}');

    final response = await http.post(
      Uri.parse('$_baseUrl/schedules'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      print('일정 생성 성공!');
    } else {
      print('일정 생성 실패: ${response.statusCode}');
      print('응답 본문: ${utf8.decode(response.bodyBytes)}');
      throw Exception('Failed to create schedule: ${response.statusCode}');
    }
  }

  // 일정 업데이트 메서드
  Future<void> updateSchedule(
      int scheduleId, // 업데이트할 일정의 ID
          {
        required String title,
        String? category,
        required DateTime? startDate,
        required TimeOfDay? startTime,
        required DateTime? endDate,
        required TimeOfDay? endTime,
        required bool isAllDay,
        required String repeatOption,
        required String reminderOption,
        required bool isClimbingSchedule,
        String? climbingCenterName,
        int? userId,
        String? place,
        String? memo,
        List<Map<String, dynamic>>? allClimbingCenters,
      }) async {
    String? startDateTimeStr;
    if (startDate != null && startTime != null) {
      final combinedStart = DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute);
      startDateTimeStr = combinedStart.toIso8601String();
    }

    String? endDateTimeStr;
    if (endDate != null && endTime != null) {
      final combinedEnd = DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);
      endDateTimeStr = combinedEnd.toIso8601String();
    }

    String? recurringPattern = _mapRepeatOptionToDb(repeatOption);

    DateTime? notificationTime;
    bool notificationEnabled = false;
    if (reminderOption != '안 함' && startDateTimeStr != null) {
      notificationEnabled = true;
      notificationTime = _calculateNotificationTime(
          DateTime.parse(startDateTimeStr), reminderOption);
    }

    String? notificationTimeStr;
    if (notificationTime != null) {
      notificationTimeStr = notificationTime.toIso8601String();
    }

    int? centerId;
    if (isClimbingSchedule && climbingCenterName != null && allClimbingCenters != null) {
      try {
        centerId = allClimbingCenters
            .firstWhere((center) => center['name'] == climbingCenterName)['center_id'];
      } catch (e) {
        print('Warning: Climbing center ID not found for $climbingCenterName, error: $e');
      }
    }

    final Map<String, dynamic> body = {
      'userId': userId, // 업데이트 시 userId는 기존 값을 그대로 사용
      'centerId': centerId,
      'title': title,
      'category': category,
      'startTime': startDateTimeStr,
      'endTime': endDateTimeStr,
      'isAllDay': isAllDay,
      'notes': memo,
      'isRecurring': repeatOption != '안 함',
      'recurringPattern': recurringPattern,
      'place': place,
      'notificationEnabled': notificationEnabled,
      'notificationTime': notificationTimeStr,
    };

    print('Sending update schedule data for ID $scheduleId: ${jsonEncode(body)}');

    final response = await http.put( // PUT 요청
      Uri.parse('$_baseUrl/schedules/$scheduleId'), // URL에 일정 ID 포함
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) { // 200 OK 예상
      print('일정 업데이트 성공!');
    } else {
      print('일정 업데이트 실패: ${response.statusCode}');
      print('응답 본문: ${utf8.decode(response.bodyBytes)}');
      throw Exception('Failed to update schedule: ${response.statusCode}');
    }
  }

  // 일정 삭제 메서드
  Future<void> deleteSchedule(int scheduleId) async {
    print('Deleting schedule with ID: $scheduleId');
    final response = await http.delete(
      Uri.parse('$_baseUrl/schedules/$scheduleId'), // URL에 일정 ID 포함
    );

    if (response.statusCode == 200 || response.statusCode == 204) { // 200 OK 또는 204 No Content 예상
      print('일정 삭제 성공!');
    } else {
      print('일정 삭제 실패: ${response.statusCode}');
      print('응답 본문: ${utf8.decode(response.bodyBytes)}');
      throw Exception('Failed to delete schedule: ${response.statusCode}');
    }
  }
  // --- 알림 목록 가져오기 메서드 (별칭 사용) ---
  Future<List<app_notification.Notification>> getNotificationsByUserId(int userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/notifications/user/$userId'));

    if (response.statusCode == 200) {
      final String rawJson = utf8.decode(response.bodyBytes);
      print('Received raw JSON for notifications: $rawJson');
      final List<dynamic> jsonList = jsonDecode(rawJson);
      // fromJson 호출 시 별칭 사용
      return jsonList.map((json) => app_notification.Notification.fromJson(json)).toList();
    } else {
      print('알림 목록 조회 실패: ${response.statusCode}');
      print('응답 본문: ${utf8.decode(response.bodyBytes)}');
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  }
  // 반복 옵션을 DB에 저장할 패턴으로 매핑
  String? _mapRepeatOptionToDb(String repeatOption) {
    switch (repeatOption) {
      case '매일': return 'DAILY';
      case '매주': return 'WEEKLY';
      case '2주마다': return 'BI_WEEKLY';
      case '매월': return 'MONTHLY';
      case '매년': return 'YEARLY';
      default: return null; // '안 함'
    }
  }

  // 알림 시간 계산 헬퍼 함수
  DateTime _calculateNotificationTime(DateTime eventTime, String reminderOption) {
    switch (reminderOption) {
      case '5분 전': return eventTime.subtract(const Duration(minutes: 5));
      case '10분 전': return eventTime.subtract(const Duration(minutes: 10));
      case '15분 전': return eventTime.subtract(const Duration(minutes: 15));
      case '30분 전': return eventTime.subtract(const Duration(minutes: 30));
      case '1시간 전': return eventTime.subtract(const Duration(hours: 1));
      case '2시간 전': return eventTime.subtract(const Duration(hours: 2));
      case '1일 전': return eventTime.subtract(const Duration(days: 1));
      case '이벤트 시간': return eventTime;
      default: return eventTime; // 기본값
    }
  }
}