import 'package:flutter/material.dart';
import 'package:project_clinder/SignUpScreen.dart'; // 회원가입 화면 임포트
import 'package:project_clinder/main.dart';
import 'package:project_clinder/services/api_service.dart'; // ApiService 임포트
import 'package:project_clinder/domain/User.dart'; // User/LoginRequest 모델 임포트 (LoginRequest가 더 명확)


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  String _loginMessage = '';

  final ApiService apiService = ApiService(); // ApiService 인스턴스

  Future<void> _login() async {
    if (_loginIdController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _loginMessage = '아이디와 비밀번호를 모두 입력해주세요.';
      });
      return;
    }

    setState(() {
      _loginMessage = '로그인 중...';
    });

    String result = await apiService.loginUser(
      _loginIdController.text,
      _passwordController.text,
    );

    setState(() {
      _loginMessage = result;
    });

    if (result.contains('로그인 성공')) {
      print('로그인 성공! 캘린더 화면으로 이동합니다.');
      // 로그인 성공 시 LoginScreen을 제거하고 CalendarScreen으로 대체
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CalendarScreen()),
      );
    }
  }

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 400,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: const Center(
                  child: Text(
                    '환영합니다!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 400,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '계속하려면 아이디와 비밀번호를 입력하세요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      '아이디',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _loginIdController,
                      decoration: InputDecoration(
                        hintText: '로그인 아이디를 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      '비밀번호',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: '비밀번호를 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: 비밀번호 찾기 로직
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6C63FF),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '비밀번호를 잊으셨나요?',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '로그인',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _loginMessage,
                      style: TextStyle(
                        color: _loginMessage.contains('성공') ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6C63FF),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            '회원가입',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '계정이 없으신가요?',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36)
            ],
          ),
        ),
      ),
    );
  }
}