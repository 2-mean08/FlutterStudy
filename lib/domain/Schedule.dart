import 'package:flutter/material.dart';

class Schedule {
  final int scheduleId;
  final int? userId;
  final int? centerId; // null 허용
  final String title;
  final String? category; // null 허용
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String? notes; // null 허용
  final bool isRecurring;
  final String? recurringPattern; // null 허용
  final String? place; // null 허용
  final bool notificationEnabled;
  final DateTime? notificationTime; // null 허용

  Schedule({
    required this.scheduleId,
    required this.userId,
    this.centerId,
    required this.title,
    this.category,
    required this.startTime,
    required this.endTime,
    required this.isAllDay,
    this.notes,
    required this.isRecurring,
    this.recurringPattern,
    this.place,
    required this.notificationEnabled,
    this.notificationTime,
  });

  // JSON 데이터를 Schedule 객체로 변환하는 팩토리 메서드
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      scheduleId: json['scheduleId'] as int,
      userId: json['userId'] as int,
      centerId: json['centerId'] as int?,
      title: json['title'] as String,
      category: json['category'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isAllDay: json['isAllDay'] as bool,
      notes: json['notes'] as String?,
      isRecurring: json['isRecurring'] as bool,
      recurringPattern: json['recurringPattern'] as String?,
      place: json['place'] as String?,
      notificationEnabled: json['notificationEnabled'] as bool,
      notificationTime: json['notificationTime'] != null
          ? DateTime.parse(json['notificationTime'] as String)
          : null,
    );
  }
}