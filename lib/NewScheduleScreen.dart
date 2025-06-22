import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜와 시간 포맷팅을 위해 추가

class NewScheduleScreen extends StatefulWidget {
  const NewScheduleScreen({Key? key}) : super(key: key);

  @override
  State<NewScheduleScreen> createState() => _NewScheduleScreenState();
}

class _NewScheduleScreenState extends State<NewScheduleScreen> {
  // 텍스트 필드 컨트롤러
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  // 날짜/시간 저장 변수
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  bool _isAllDay = false; // 종일 여부
  bool _isClimbingSchedule = false; // 클라이밍 일정 여부

  // 시작 날짜 및 시간 선택 함수
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: '시작 날짜 선택',
      cancelText: '취소',
      confirmText: '확인',
      locale: const Locale('ko', 'KR'), // 한국어 로케일 설정
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _startTime ?? TimeOfDay.now(),
        helpText: '시작 시간 선택',
        cancelText: '취소',
        confirmText: '확인',
      );

      if (pickedTime != null) {
        setState(() {
          _startDate = pickedDate;
          _startTime = pickedTime;
        });
      }
    }
  }

  // 종료 날짜 및 시간 선택 함수
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(), // 종료일은 시작일 이후로 기본 설정
      firstDate: _startDate ?? DateTime(2000), // 종료일은 시작일보다 빠를 수 없음
      lastDate: DateTime(2101),
      helpText: '종료 날짜 선택',
      cancelText: '취소',
      confirmText: '확인',
      locale: const Locale('ko', 'KR'), // 한국어 로케일 설정
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _endTime ?? _startTime ?? TimeOfDay.now(), // 종료 시간은 시작 시간 이후로 기본 설정
        helpText: '종료 시간 선택',
        cancelText: '취소',
        confirmText: '확인',
      );

      if (pickedTime != null) {
        setState(() {
          _endDate = pickedDate;
          _endTime = pickedTime;
        });
      }
    }
  }

  // 선택된 날짜와 시간을 텍스트로 표시하는 헬퍼 함수
  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) {
      return '';
    }
    final DateTime fullDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return DateFormat('yyyy년 MM월 dd일 HH:mm', 'ko_KR').format(fullDateTime);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('새 일정'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 일정 저장 로직 구현
              print('일정 저장:');
              print('제목: ${_titleController.text}');
              print('시작: ${_formatDateTime(_startDate, _startTime)}');
              print('종료: ${_formatDateTime(_endDate, _endTime)}');
              print('종일: $_isAllDay');
              print('클라이밍 일정: $_isClimbingSchedule');
              print('장소: ${_placeController.text}');
              print('메모: ${_memoController.text}');
            },
            child: const Text(
              '저장',
              style: TextStyle(
                color: Colors.black, // 이미지와 동일한 색상
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 (드롭다운)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: null, // 초기 선택 값 없음 (힌트 텍스트처럼 보이게)
                  hint: const Text('카테고리'),
                  items: <String>['회의', '운동', '개인', '기타']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // TODO: 선택된 카테고리 값 처리
                    print('선택된 카테고리: $newValue');
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 제목
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '제목',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue), // 포커스 시 색상 변경
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // 종일 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '종일',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: _isAllDay,
                  onChanged: (bool value) {
                    setState(() {
                      _isAllDay = value;
                    });
                  },
                  activeColor: const Color(0xFF6C63FF),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 시작 시간 (TextField 대신 GestureDetector를 사용하여 터치 이벤트 감지)
            GestureDetector(
              onTap: () => _selectStartDate(context),
              child: AbsorbPointer( // TextField가 터치 이벤트를 먹지 않도록 방지
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '시작 시간',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  controller: TextEditingController(
                    text: _formatDateTime(_startDate, _startTime),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 종료 시간
            GestureDetector(
              onTap: () => _selectEndDate(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '종료',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  controller: TextEditingController(
                    text: _formatDateTime(_endDate, _endTime),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 반복 (TODO)
            TextField(
              readOnly: true, // 읽기 전용으로 만들어 입력 방지
              onTap: () {
                // TODO: 반복 설정 다이얼로그 또는 화면으로 이동
                print('반복 설정');
              },
              decoration: InputDecoration(
                hintText: '반복',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // 알림 (TODO)
            TextField(
              readOnly: true, // 읽기 전용으로 만들어 입력 방지
              onTap: () {
                // TODO: 알림 설정 다이얼로그 또는 화면으로 이동
                print('알림 설정');
              },
              decoration: InputDecoration(
                hintText: '알림',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // 클라이밍 일정 체크박스
            Row(
              children: [
                Checkbox(
                  value: _isClimbingSchedule,
                  onChanged: (bool? value) {
                    setState(() {
                      _isClimbingSchedule = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF6C63FF),
                ),
                const Text(
                  '클라이밍 일정',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 장소
            TextField(
              controller: _placeController,
              decoration: InputDecoration(
                hintText: '장소',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // 메모
            TextField(
              controller: _memoController,
              maxLines: 4, // 여러 줄 입력 가능
              decoration: InputDecoration(
                hintText: '메모',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}