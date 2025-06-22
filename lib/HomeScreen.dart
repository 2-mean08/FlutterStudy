import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_clinder/domain/Schedule.dart';
import 'package:project_clinder/services/api_service.dart'; // 시간 포맷팅을 위해 추가

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Schedule> _todaySchedules = []; // 오늘의 일정 리스트
  bool _isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    _fetchTodaySchedules();
  }

  // 오늘의 일정을 가져오는 비동기 함수
  Future<void> _fetchTodaySchedules() async {
    try {
      // TODO: 실제 사용자 ID를 여기에 전달해야 합니다. (예: 로그인된 사용자 ID)
      // 현재는 임시로 1번 사용자 ID를 사용합니다.
      final List<Schedule> fetchedSchedules = await _apiService.getSchedulesByUserId(6);
      print('HomeScreen: Fetched ${fetchedSchedules.length} schedules from API.');

      // 오늘 날짜의 일정만 필터링 (선택 사항: 전체 일정 표시도 가능)
      final now = DateTime.now();
      _todaySchedules = fetchedSchedules.where((schedule) {
        // 일정이 오늘 하루 종일이거나, 시작 시간이 오늘이거나, 종료 시간이 오늘인 경우
        // 또는 오늘 날짜가 시작과 종료 시간 사이에 있는 경우 포함
        return (schedule.isAllDay && schedule.startTime.toLocal().day == now.day && schedule.startTime.toLocal().month == now.month && schedule.startTime.toLocal().year == now.year) ||
            (schedule.startTime.toLocal().day == now.day && schedule.startTime.toLocal().month == now.month && schedule.startTime.toLocal().year == now.year) ||
            (schedule.endTime.toLocal().day == now.day && schedule.endTime.toLocal().month == now.month && schedule.endTime.toLocal().year == now.year) ||
            (now.isAfter(schedule.startTime.toLocal()) && now.isBefore(schedule.endTime.toLocal()));
      }).toList();

      // 시작 시간 기준으로 정렬
      _todaySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    } catch (e) {
      print('오늘의 일정을 불러오는데 실패했습니다: $e');
      // 오류 발생 시 사용자에게 알림 (예: 스낵바)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정 불러오기 실패: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // 로딩 완료
      });
    }
  }

  // 일정 시간을 보기 좋게 포맷팅하는 헬퍼 함수
  String _formatScheduleTime(Schedule schedule) {
    final DateFormat timeFormat = DateFormat('HH:mm a'); // 예: 10:00 AM
    if (schedule.isAllDay) {
      return '하루 종일';
    } else {
      return '${timeFormat.format(schedule.startTime.toLocal())} ~ ${timeFormat.format(schedule.endTime.toLocal())}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('클린더'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 다른 위젯들 (예: 환영 메시지 등)
              const Text(
                '안녕하세요, 사용자님!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // 오늘의 일정 카드 컨테이너
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: _isLoading // 로딩 중인 경우 로딩 인디케이터 표시
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '오늘의 일정',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // 일정이 없는 경우 메시지 표시
                      if (_todaySchedules.isEmpty)
                        const Text(
                          '오늘의 일정이 없습니다.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      // 일정이 있는 경우 각 일정을 표시
                      ..._todaySchedules.map((schedule) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      schedule.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      overflow: TextOverflow.ellipsis, // 제목 길어지면 ...
                                    ),
                                  ),
                                  if (schedule.category != null && schedule.category!.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100, // 카테고리 배경색
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        schedule.category!,
                                        style: TextStyle(
                                          color: Colors.blue.shade700, // 카테고리 텍스트 색상
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatScheduleTime(schedule),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1), // 각 일정 구분선
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              // 다른 위젯들 계속
            ],
          ),
        ),
      ),
    );
  }
}