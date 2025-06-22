import 'package:flutter/material.dart';
import 'package:project_clinder/NoficationScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true; // 현재는 UI 상태만 변경

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '설정',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F3F3)),
          ListTile(
            leading: const Icon(Icons.text_fields, color: Colors.black),
            title: const Text('글꼴 설정', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 글꼴 설정 페이지로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.label_outline, color: Colors.black),
            title: const Text('카테고리 설정', style: TextStyle(fontWeight: FontWeight.w500)), // 텍스트 수정
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 카테고리 설정 페이지로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.nightlight_round, color: Colors.black),
            title: const Text('다크모드', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (val) {
                setState(() {
                  _isDarkMode = val;
                });
                // TODO: 다크 모드 실제 적용 로직 추가
              },
              activeColor: const Color(0xFF6C63FF),
            ),
            onTap: () {
              setState(() {
                _isDarkMode = !_isDarkMode; // 스위치 탭 시 상태 토글
              });
              // TODO: 다크 모드 실제 적용 로직 추가
            },
          ),
          // 새로운 알림 확인 버튼 추가
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.black), // 종 모양 아이콘
            title: const Text('알림', style: TextStyle(fontWeight: FontWeight.w500)), // '알림' 텍스트
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 알림 화면으로 이동
              // TODO: 실제 사용자 ID를 전달해야 합니다. 현재는 임시로 1 사용
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen(userId: 5)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.black),
            title: const Text('자주 묻는 질문', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 자주 묻는 질문 페이지로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.black),
            title: const Text('언어', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 언어 설정 페이지로 이동
            },
          ),
          const Spacer(), // 남은 공간을 채워 하단에 붙지 않도록 합니다.
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
