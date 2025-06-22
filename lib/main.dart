import 'package:flutter/material.dart';
import 'package:project_clinder/NewScheduleScreen.dart';
import 'package:project_clinder/SettingsScreen.dart';
import 'package:project_clinder/SignUpScreen.dart'; // 회원가입 화면 임포트
import 'package:project_clinder/services/api_service.dart'; // ApiService 임포트
import 'package:project_clinder/domain/User.dart'; // User/LoginRequest 모델 임포트 (LoginRequest가 더 명확)
import 'package:table_calendar/table_calendar.dart'; // 캘린더 라이브러리 임포트
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위한 임포트 (CalendarScreen에서 사용)
import 'package:project_clinder/LoginScreen.dart'; // 현재 사용되지 않으므로 주석 처리 또는 삭제 가능
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async { // <<< main 함수를 async로 변경합니다.
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 바인딩 초기화
  await initializeDateFormatting('ko_KR', null); // <<< 이 줄을 추가합니다. 'ko_KR'은 사용하려는 로케일입니다.
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
        GlobalMaterialLocalizations.delegate, // Material Design 위젯에 대한 현지화 제공
        GlobalWidgetsLocalizations.delegate,  // 위젯 일반에 대한 현지화 제공
        GlobalCupertinoLocalizations.delegate, // iOS 스타일 위젯에 대한 현지화 제공
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어 지원
        Locale('en', 'US'), // 영어 지원 (필요하다면 추가)
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
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () {
            // TODO: 월 이동 로직 추가
          },
        ),
        centerTitle: true,
        title: Text(
          DateFormat('yyyy년 M월').format(_focusedDay),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF6C63FF), size: 32),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewScheduleScreen())
              );
            },
          ),
          IconButton(
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
                child: TableCalendar(
                  locale: 'ko_KR', // 한국어 로케일 설정
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  headerVisible: false, // AppBar에서 월 정보를 표시하므로 캘린더 자체 헤더는 숨깁니다.
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
                    markerBuilder: (context, day, events) {
                      // 예시: 6월 6일 빨간색 "현충" 배지 표시
                      if (day.year == 2025 && day.month == 6 && day.day == 6) {
                        return Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.pink,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '현충',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }
                      return null; // 다른 날짜에는 마커를 표시하지 않음
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 오늘의 일정 카드
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '오늘의 일정',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Meeting with John',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '10:00 AM ~ 10:00 PM',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 12),
                    Divider(height: 1), // 구분선
                  ],
                ),
              ),
            ),
            const Spacer(), // 남은 공간을 채워 하단에 붙지 않도록 합니다.
          ],
        ),
      ),
    );
  }
}