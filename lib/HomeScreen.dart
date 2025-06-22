import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메인 화면'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          '로그인 성공! 메인 화면입니다.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}