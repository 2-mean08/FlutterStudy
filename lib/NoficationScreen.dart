import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_clinder/services/api_service.dart'; // ApiService 임포트
import 'package:project_clinder/domain/notification.dart' as app_notification; // 충돌 방지를 위해 별칭 사용

class NotificationScreen extends StatefulWidget {
  final int userId; // 알림을 불러올 사용자 ID

  const NotificationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ApiService _apiService = ApiService();
  List<app_notification.Notification> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedNotifications = await _apiService.getNotificationsByUserId(widget.userId);
      setState(() {
        _notifications = fetchedNotifications;
      });
    } catch (e) {
      print('알림 불러오기 실패: $e');
      setState(() {
        _errorMessage = '알림을 불러오는 데 실패했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 알림 시간 포맷팅 헬퍼 함수
  String _formatNotificationTime(DateTime dateTime) {
    return DateFormat('yyyy년 MM월 dd일 HH:mm', 'ko_KR').format(dateTime.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('알림'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchNotifications,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      )
          : _notifications.isEmpty
          ? const Center(
        child: Text(
          '새로운 알림이 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: notification.type == 'REPLACEMENT_ALERT'
                              ? Colors.orange.shade100
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          notification.type == 'REPLACEMENT_ALERT' ? '문제 교체 알림' : '일정 알림',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: notification.type == 'REPLACEMENT_ALERT'
                                ? Colors.orange.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                      Text(
                        _formatNotificationTime(notification.notificationTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.message,
                    style: const TextStyle(fontSize: 15),
                  ),
                  if (notification.isSent) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '전송됨: ${_formatNotificationTime(notification.sentAt!)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
