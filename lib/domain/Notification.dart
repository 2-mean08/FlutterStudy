import 'package:flutter/material.dart'; // TimeOfDay, Material UI 사용을 위해 임포트 (필요시)

class Notification {
  final int notificationId;
  final int? userId;
  final int? scheduleId;
  final int? centerId;
  final String type; // 'SCHEDULE', 'REPLACEMENT_ALERT'
  final String message;
  final DateTime notificationTime;
  final bool isSent;
  final DateTime? sentAt;

  Notification({
    required this.notificationId,
    this.userId,
    this.scheduleId,
    this.centerId,
    required this.type,
    required this.message,
    required this.notificationTime,
    required this.isSent,
    this.sentAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      notificationId: json['notificationId'] as int,
      userId: json['userId'] as int?,
      scheduleId: json['scheduleId'] as int?,
      centerId: json['centerId'] as int?,
      type: json['type'] as String,
      message: json['message'] as String,
      notificationTime: DateTime.parse(json['notificationTime'] as String),
      isSent: json['isSent'] as bool,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'scheduleId': scheduleId,
      'centerId': centerId,
      'type': type,
      'message': message,
      'notificationTime': notificationTime.toIso8601String(),
      'isSent': isSent,
      'sentAt': sentAt?.toIso8601String(),
    };
  }
}
