import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜와 시간 포맷팅을 위해 추가
import 'package:project_clinder/domain/Schedule.dart'; // Schedule 모델 임포트 (경로 확인)
import 'package:project_clinder/services/api_service.dart'; // ApiService 임포트

class NewScheduleScreen extends StatefulWidget {
  // 기존 일정 객체를 받을 수 있도록 생성자를 수정합니다.
  // 이 객체가 있으면 수정 모드, 없으면 생성 모드입니다.
  final Schedule? initialSchedule;

  const NewScheduleScreen({Key? key, this.initialSchedule}) : super(key: key);

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
  // bool _isClimbingSchedule = false; // <-- 이 변수는 이제 필요 없으므로 제거

  // 반복 및 알림 관련 변수
  String? _selectedRepeatOption; // 선택된 반복 옵션
  String? _selectedReminderOption; // 선택된 알림 옵션

  // 클라이밍 센터 관련 변수
  List<Map<String, dynamic>> _climbingCenters = []; // 백엔드에서 가져올 클라이밍 센터 목록
  String? _selectedClimbingCenterName; // 선택된 클라이밍 센터 이름

  // 카테고리 관련 변수
  String? _selectedCategory; // 선택된 카테고리

  final ApiService _apiService = ApiService(); // ApiService 인스턴스

  // 수정 모드인지 확인하는 변수
  bool get _isEditMode => widget.initialSchedule != null;

  // 모든 가능한 카테고리 목록 - '일반' 카테고리 포함
  final List<String> _categories = ['개인', '회의', '운동', '기타', '클라이밍', '일반'];

  @override
  void initState() {
    super.initState();
    // 화면 초기화 시 클라이밍 센터 목록을 불러옵니다.
    _fetchClimbingCenters();

    // 반복 및 알림의 기본값 설정
    _selectedRepeatOption = '안 함';
    _selectedReminderOption = '안 함';

    // 수정 모드인 경우, 초기 일정 데이터를 필드에 채워 넣습니다.
    if (_isEditMode) {
      final schedule = widget.initialSchedule!;
      _titleController.text = schedule.title;
      _memoController.text = schedule.notes ?? '';
      _isAllDay = schedule.isAllDay;
      _startDate = schedule.startTime.toLocal(); // DB에서 UTC로 저장되었다면 toLocal() 필요
      _startTime = TimeOfDay.fromDateTime(schedule.startTime.toLocal());
      _endDate = schedule.endTime.toLocal();
      _endTime = TimeOfDay.fromDateTime(schedule.endTime.toLocal());
      _selectedRepeatOption = schedule.recurringPattern != null ? _mapDbToRepeatOption(schedule.recurringPattern!) : '안 함';
      _selectedReminderOption = schedule.notificationEnabled && schedule.notificationTime != null
          ? _mapDbToReminderOption(schedule.startTime.toLocal(), schedule.notificationTime!)
          : '안 함';

      String? initialCategory = schedule.category;
      if (initialCategory != null && _categories.contains(initialCategory)) {
        _selectedCategory = initialCategory;
      } else if (initialCategory == null) {
        _selectedCategory = '개인';
      } else if (initialCategory == '일반') {
        _selectedCategory = '일반';
      } else {
        _selectedCategory = '개인';
      }

      // _selectedCategory에 따라 place 필드를 초기화
      if (_selectedCategory == '클라이밍') {
        _selectedClimbingCenterName = schedule.place; // place가 클라이밍 센터 이름이므로 그대로 사용
        _placeController.text = ''; // 일반 장소 입력 필드는 비워둡니다.
      } else {
        _placeController.text = schedule.place ?? ''; // 클라이밍 일정이 아니면 place 필드에 일반 장소 입력
        _selectedClimbingCenterName = null; // 클라이밍 센터는 선택되지 않음
      }
    } else {
      // 생성 모드일 때의 초기 카테고리 설정
      _selectedCategory = '개인'; // 기본값 "개인"
    }
  }

  // DB에 저장된 반복 패턴을 UI 옵션으로 매핑
  String _mapDbToRepeatOption(String dbPattern) {
    switch (dbPattern) {
      case 'DAILY': return '매일';
      case 'WEEKLY': return '매주';
      case 'BI_WEEKLY': return '2주마다';
      case 'MONTHLY': return '매월';
      case 'YEARLY': return '매년';
      default: return '안 함';
    }
  }

  // DB에 저장된 알림 시간을 UI 옵션으로 매핑
  String _mapDbToReminderOption(DateTime eventTime, DateTime notificationTime) {
    final Duration diff = eventTime.difference(notificationTime);
    if (diff.inMinutes == 0) return '이벤트 시간';
    if (diff.inMinutes == 5) return '5분 전';
    if (diff.inMinutes == 10) return '10분 전';
    if (diff.inMinutes == 15) return '15분 전';
    if (diff.inMinutes == 30) return '30분 전';
    if (diff.inHours == 1) return '1시간 전';
    if (diff.inHours == 2) return '2시간 전';
    if (diff.inDays == 1 && diff.inHours == 24) return '1일 전';
    return '안 함';
  }

  // 클라이밍 센터 목록을 백엔드에서 불러오는 함수
  Future<void> _fetchClimbingCenters() async {
    try {
      final List<Map<String, dynamic>> centers = await _apiService.getClimbingCenters();
      setState(() {
        _climbingCenters = centers;
        // 수정 모드이고 클라이밍 카테고리이며 선택된 클라이밍 센터 이름이 있다면, 목록 로드 후 유효성 확인
        if (_isEditMode && _selectedCategory == '클라이밍' && _selectedClimbingCenterName != null) {
          bool found = _climbingCenters.any((center) => center['name'] == _selectedClimbingCenterName);
          if (!found) {
            _selectedClimbingCenterName = null; // 이전에 선택된 센터가 현재 목록에 없으면 초기화
          }
        }
      });
    } catch (e) {
      print('클라이밍 센터를 불러오는 데 실패했습니다: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('클라이밍 센터 목록을 불러오지 못했습니다: $e')),
      );
    }
  }

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
      locale: const Locale('ko', 'KR'),
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
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(2101),
      helpText: '종료 날짜 선택',
      cancelText: '취소',
      confirmText: '확인',
      locale: const Locale('ko', 'KR'),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _endTime ?? _startTime ?? TimeOfDay.now(),
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
    // _selectedCategory 값이 null인 경우를 대비하여 기본값 설정
    final bool isClimbingCategorySelected = _selectedCategory == '클라이밍';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(_isEditMode ? '일정 수정' : '새 일정'),
        centerTitle: true,
        actions: [
          // 삭제 버튼 (수정 모드일 때만 표시)
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () async {
                final bool? confirmDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('일정 삭제'),
                    content: const Text('정말 이 일정을 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('삭제', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirmDelete == true) {
                  try {
                    await _apiService.deleteSchedule(widget.initialSchedule!.scheduleId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('일정이 성공적으로 삭제되었습니다!')),
                    );
                    Navigator.pop(context, true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('일정 삭제에 실패했습니다: $e')),
                    );
                    print('일정 삭제 오류: $e');
                  }
                }
              },
            ),
          TextButton(
            onPressed: () async {
              // 유효성 검사
              if (_titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('제목을 입력해주세요.')),
                );
                return;
              }
              if (_startDate == null || _startTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('시작 날짜와 시간을 선택해주세요.')),
                );
                return;
              }
              if (_endDate == null || _endTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('종료 날짜와 시간을 선택해주세요.')),
                );
                return;
              }
              // 클라이밍 카테고리 선택 시 센터 선택 유효성 검사
              if (isClimbingCategorySelected && _selectedClimbingCenterName == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('클라이밍 센터를 선택해주세요.')),
                );
                return;
              }

              // 장소 값 설정 로직
              String? placeToSend;
              if (isClimbingCategorySelected) {
                placeToSend = _selectedClimbingCenterName; // 클라이밍 센터 이름 사용
              } else {
                placeToSend = _placeController.text.isNotEmpty ? _placeController.text : null; // 일반 장소 사용
              }

              try {
                if (_isEditMode) {
                  await _apiService.updateSchedule(
                    widget.initialSchedule!.scheduleId,
                    title: _titleController.text,
                    category: _selectedCategory,
                    startDate: _startDate,
                    startTime: _startTime,
                    endDate: _endDate,
                    endTime: _endTime,
                    isAllDay: _isAllDay,
                    repeatOption: _selectedRepeatOption ?? '안 함',
                    reminderOption: _selectedReminderOption ?? '안 함',
                    isClimbingSchedule: isClimbingCategorySelected, // <-- 카테고리 기반으로 전달
                    climbingCenterName: _selectedClimbingCenterName, // 센터 ID를 찾기 위해 전달
                    place: placeToSend,
                    memo: _memoController.text,
                    userId: widget.initialSchedule!.userId ?? 6,
                    allClimbingCenters: _climbingCenters,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('일정이 성공적으로 수정되었습니다!')),
                  );
                  Navigator.pop(context, true);
                } else {
                  await _apiService.createSchedule(
                    title: _titleController.text,
                    category: _selectedCategory,
                    startDate: _startDate,
                    startTime: _startTime,
                    endDate: _endDate,
                    endTime: _endTime,
                    isAllDay: _isAllDay,
                    repeatOption: _selectedRepeatOption ?? '안 함',
                    reminderOption: _selectedReminderOption ?? '안 함',
                    isClimbingSchedule: isClimbingCategorySelected, // <-- 카테고리 기반으로 전달
                    climbingCenterName: _selectedClimbingCenterName, // 센터 ID를 찾기 위해 전달
                    place: placeToSend,
                    memo: _memoController.text,
                    userId: 6,
                    allClimbingCenters: _climbingCenters,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('일정이 성공적으로 저장되었습니다!')),
                  );
                  Navigator.pop(context, true);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('일정 저장/수정에 실패했습니다: $e')),
                );
                print('일정 저장/수정 오류: $e');
              }
            },
            child: const Text(
              '저장',
              style: TextStyle(
                color: Colors.black,
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
            InputDecorator(
              decoration: InputDecoration(
                labelText: '카테고리',
                labelStyle: const TextStyle(color: Colors.black54),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              isEmpty: _selectedCategory == null,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  hint: const Text('카테고리 선택'),
                  items: _categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                      // 클라이밍 카테고리 선택 시 place 필드 초기화 또는 유지
                      if (newValue == '클라이밍') {
                        // _isClimbingSchedule 변수를 사용하지 않음
                        _placeController.text = ''; // 장소 필드를 비워 센터 선택으로 유도
                      } else {
                        _selectedClimbingCenterName = null; // 다른 카테고리 선택 시 센터 초기화
                      }
                    });
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
                  borderSide: const BorderSide(color: Colors.blue),
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

            // 시작 시간
            GestureDetector(
              onTap: () => _selectStartDate(context),
              child: AbsorbPointer(
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

            // 반복
            InputDecorator(
              decoration: InputDecoration(
                labelText: '반복',
                labelStyle: const TextStyle(color: Colors.black54),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              isEmpty: _selectedRepeatOption == null,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedRepeatOption,
                  items: <String>['안 함', '매일', '매주', '2주마다', '매월', '매년']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRepeatOption = newValue;
                    });
                    print('선택된 반복 옵션: $newValue');
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 알림
            InputDecorator(
              decoration: InputDecoration(
                labelText: '알림',
                labelStyle: const TextStyle(color: Colors.black54),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              isEmpty: _selectedReminderOption == null,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedReminderOption,
                  items: <String>['안 함', '이벤트 시간', '5분 전', '10분 전', '15분 전', '30분 전', '1시간 전', '2시간 전', '1일 전']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedReminderOption = newValue;
                    });
                    print('선택된 알림 옵션: $newValue');
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 클라이밍 일정 체크박스 (카테고리 드롭다운과 연동되므로 제거)
            // Column(
            //   children: [
            //     Checkbox(
            //       value: _isClimbingSchedule,
            //       onChanged: (bool? value) {
            //         setState(() {
            //           _isClimbingSchedule = value ?? false;
            //           if (!_isClimbingSchedule) {
            //             _selectedClimbingCenterName = null;
            //           }
            //         });
            //       },
            //       activeColor: const Color(0xFF6C63FF),
            //     ),
            //     const Text(
            //       '클라이밍 일정',
            //       style: TextStyle(fontSize: 16),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 16),

            // 클라이밍 카테고리 선택 시에만 센터 선택 드롭다운 표시
            if (isClimbingCategorySelected) // <-- 카테고리 선택 여부에 따라 표시
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '클라이밍 센터 선택',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedClimbingCenterName,
                        hint: const Text('클라이밍 센터를 선택하세요'),
                        items: _climbingCenters.map((center) {
                          return DropdownMenuItem<String>(
                            value: center['name'], // 센터 이름을 값으로 사용
                            child: Text(center['name']),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedClimbingCenterName = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // 일반 카테고리 선택 시에만 장소 입력 필드 표시
            if (!isClimbingCategorySelected) // <-- 카테고리 선택 여부에 따라 표시
              Column(
                children: [
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
                ],
              ),

            // 메모
            TextField(
              controller: _memoController,
              maxLines: 4,
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
