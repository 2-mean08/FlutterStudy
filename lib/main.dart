import 'package:flutter/material.dart';
import 'package:project_clinder/NewScheduleScreen.dart';
import 'package:project_clinder/SettingsScreen.dart';
import 'package:project_clinder/SignUpScreen.dart'; // 회원가입 화면 임포트
import 'package:project_clinder/domain/Schedule.dart';
import 'package:project_clinder/services/api_service.dart'; // ApiService 임포트
import 'package:project_clinder/domain/User.dart'; // User/LoginRequest 모델 임포트 (LoginRequest가 더 명확)
import 'package:table_calendar/table_calendar.dart'; // 캘린더 라이브러리 임포트
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위한 임포트
import 'package:project_clinder/LoginScreen.dart'; // 현재 사용되지 않으므로 주석 처리 또는 삭제 가능
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // 앱 시작 시 로그인 화면을 보여줍니다.
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay; // 현재 선택된 날짜
  Map<DateTime, List<Schedule>> _events = {}; // 날짜별 일정을 저장할 맵
  List<Schedule> _selectedEvents = []; // 선택된 날짜의 일정 리스트
  final ApiService _apiService = ApiService(); // ApiService 인스턴스
  bool _isLoading = true; // 일정 로딩 상태

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // 초기에는 오늘 날짜를 선택된 날짜로 설정
    _fetchAndLoadSchedules(); // 초기 일정 데이터 불러오기
  }

  // DateTime 객체에서 시간 부분을 제거하고 날짜만 남기는 헬퍼 함수
  // TableCalendar의 키와 _events 맵의 키를 일관되게 유지하기 위함
  DateTime _clearTime(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  // 백엔드에서 일정 데이터를 불러와 _events 맵에 로드하는 함수
  Future<void> _fetchAndLoadSchedules() async {
    setState(() {
      _isLoading = true;
      _events = {}; // 새로운 데이터를 불러오기 전에 기존 이벤트 초기화
    });

    try {
      // TODO: 실제 사용자 ID를 여기에 전달해야 합니다. (예: 로그인된 사용자 ID)
      // 현재는 임시로 1번 사용자 ID를 사용합니다.
      final List<Schedule> fetchedSchedules = await _apiService.getSchedulesByUserId(6);
      print('HomeScreen: Fetched ${fetchedSchedules.length} schedules from API.');

      // 불러온 일정을 _events 맵에 날짜별로 정리
      for (var schedule in fetchedSchedules) {
        final normalizedDate = _clearTime(schedule.startTime.toLocal()); // 로컬 시간으로 변환 후 시간 제거
        _events.putIfAbsent(normalizedDate, () => []); // 해당 날짜의 리스트가 없으면 생성
        _events[normalizedDate]!.add(schedule);
      }

      // 각 날짜별 일정을 시작 시간 기준으로 정렬 (선택 사항)
      _events.forEach((key, value) {
        value.sort((a, b) => a.startTime.compareTo(b.startTime));
      });

      // 선택된 날짜(_selectedDay)에 해당하는 일정을 업데이트
      _selectedEvents = _getEventsForDay(_selectedDay!); // _selectedDay는 initState에서 초기화됨

    } catch (e) {
      print('일정 데이터를 불러오는 데 실패했습니다: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정 데이터 불러오기 실패: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // 로딩 완료
      });
    }
  }

  // TableCalendar의 eventLoader가 호출될 때 해당 날짜의 이벤트 리스트를 반환
  List<Schedule> _getEventsForDay(DateTime day) {
    return _events[_clearTime(day)] ?? [];
  }

  // 일정 시간을 보기 좋게 포맷팅하는 헬퍼 함수
  String _formatScheduleTime(Schedule schedule) {
    final DateFormat timeFormat = DateFormat('HH:mm'); // 24시간 형식
    if (schedule.isAllDay) {
      return '하루 종일';
    } else {
      return '${timeFormat.format(schedule.startTime.toLocal())} ~ ${timeFormat.format(schedule.endTime.toLocal())}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        // leading 속성 제거 (월 이동 버튼을 title 내부에 포함)
        centerTitle: true, // title에 있는 Row의 내용이 AppBar 중앙에 오도록 합니다.
        title: Row( // Row로 감싸서 버튼과 텍스트를 함께 배치
          mainAxisAlignment: MainAxisAlignment.center, // Row 내부 콘텐츠를 중앙 정렬
          children: [
            // 이전 달로 이동 버튼
            IconButton(
              padding: EdgeInsets.zero, // 패딩을 0으로 설정하여 간격 최소화
              icon: const Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, _focusedDay.day);
                  _fetchAndLoadSchedules();
                });
              },
            ),
            // 월 표시 텍스트
            Text(
              DateFormat('yyyy년 M월').format(_focusedDay),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            // 다음 달로 이동 버튼
            IconButton(
              padding: EdgeInsets.zero, // 패딩을 0으로 설정하여 간격 최소화
              icon: const Icon(Icons.chevron_right, color: Colors.black),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, _focusedDay.day);
                  _fetchAndLoadSchedules();
                });
              },
            ),
          ],
        ),
        actions: [
          // 기존의 추가 및 설정 버튼은 그대로 유지 (패딩 0으로 유지)
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add_circle, color: Color(0xFF6C63FF), size: 32),
            onPressed: () async {
              // 새 일정 화면으로 이동 후, 돌아올 때 일정 목록 갱신
              final bool? result = await Navigator.push( // 결과 값 받기
                context,
                MaterialPageRoute(builder: (context) => const NewScheduleScreen()),
              );
              // 일정이 성공적으로 추가 또는 수정, 삭제되었다면 목록 갱신
              if (result == true) {
                _fetchAndLoadSchedules();
              }
            },
          ),
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // 캘린더 카드
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar<Schedule>( // TableCalendar에 Schedule 타입 지정
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay, // eventLoader 설정
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedEvents = _getEventsForDay(selectedDay); // 선택된 날짜의 이벤트 업데이트
                    });
                  },
                  onPageChanged: (focusedDay) {
                    // 캘린더 페이지가 변경(월 변경)될 때
                    _focusedDay = focusedDay;
                    // _fetchAndLoadSchedules(); // 필요시 페이지 변경 시점에도 데이터 로드 (위 월 이동 버튼과 중복될 수 있음)
                  },
                  headerVisible: false,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF6C63FF),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    todayTextStyle: const TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.grey),
                    weekdayStyle: TextStyle(color: Colors.grey),
                  ),
                  calendarBuilders: CalendarBuilders(
                    // 일정 마커 빌더
                    markerBuilder: (context, day, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 30, // 마커 너비
                            height: 3,  // 마커 높이
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor, // 주요 색상으로 마커
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 오늘의 일정 카드 (선택된 날짜의 일정만 표시)
            Expanded( // 남은 공간을 채우도록 Expanded 추가
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedDay != null
                            ? DateFormat('MM월 dd일 오늘의 일정').format(_selectedDay!)
                            : '오늘의 일정', // 날짜가 선택되지 않았을 때
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // 선택된 날짜에 일정이 없는 경우
                      if (_selectedEvents.isEmpty)
                        const Text(
                          '선택된 날짜의 일정이 없습니다.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      // 선택된 날짜에 일정이 있는 경우
                      Expanded( // 일정 목록이 길어질 경우 스크롤 가능하도록 Expanded 추가
                        child: ListView.builder(
                          itemCount: _selectedEvents.length,
                          itemBuilder: (context, index) {
                            final schedule = _selectedEvents[index];
                            return InkWell( // <-- InkWell 추가
                              onTap: () async {
                                final bool? result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewScheduleScreen(initialSchedule: schedule), // <-- 일정 객체 전달
                                  ),
                                );
                                if (result == true) {
                                  _fetchAndLoadSchedules(); // 수정/삭제 완료 후 목록 갱신
                                }
                              },
                              child: Padding(
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
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (schedule.category != null && schedule.category!.isNotEmpty)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              schedule.category!,
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
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
                                    // 마지막 항목이 아니라면 구분선 표시
                                    if (index < _selectedEvents.length - 1) ...[
                                      const SizedBox(height: 12),
                                      const Divider(height: 1),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 기존 Spacer 대신 Expanded를 일정 카드에 적용했으므로 Spacer는 제거하거나 필요에 따라 재배치
          ],
        ),
      ),
    );
  }
}
