import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;

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
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.label_outline, color: Colors.black),
            title: const Text('글꼴 설정', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
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
              },
              activeColor: const Color(0xFF6C63FF),
            ),
            onTap: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.black),
            title: const Text('자주 묻는 질문', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.black),
            title: const Text('언어', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Made with ',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Icon(Icons.favorite, color: Colors.blueAccent, size: 16),
                const Text(
                  ' Visily',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
