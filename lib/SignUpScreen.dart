import 'package:flutter/material.dart';
import 'package:project_clinder/services/api_service.dart'; // ApiService 임포트
import 'package:project_clinder/domain/User.dart'; // User 모델 임포트

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 텍스트 필드 컨트롤러 추가
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController(); // 이름 필드용
  final TextEditingController _emailController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _registerMessage = ''; // 회원가입 결과를 표시할 메시지

  // ApiService 인스턴스 생성
  final ApiService apiService = ApiService();

  // 회원가입 처리 함수
  Future<void> _register() async {
    // 1. 입력 필드 유효성 검사 (기본적인 빈칸 체크 및 비밀번호 일치 여부)
    if (_loginIdController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty) {
      setState(() {
        _registerMessage = '모든 필드를 입력해주세요.';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _registerMessage = '비밀번호가 일치하지 않습니다.';
      });
      return;
    }

    setState(() {
      _registerMessage = '회원가입 중...'; // 사용자에게 로딩 중임을 알림
    });

    // 2. User 객체 생성
    final user = User(
      loginId: _loginIdController.text,
      username: _usernameController.text, // 이름 필드를 username으로 사용
      password: _passwordController.text,
      email: _emailController.text,
    );

    // 3. ApiService를 사용하여 회원가입 API 호출
    String result = await apiService.registerUser(user);

    // 4. 회원가입 결과 메시지 업데이트
    setState(() {
      _registerMessage = result;
    });

    // TODO: 회원가입 성공 시 추가 로직 (예: 로그인 화면으로 돌아가기)
    if (result.contains('회원가입 성공')) {
      // 성공적으로 회원가입 후 로그인 화면으로 돌아가기
      Navigator.pop(context);
      // 또는 ScaffoldMessenger.of(context).showSnackBar() 등으로 메시지 표시 후 pop
    }
  }

  @override
  void dispose() {
    // 컨트롤러는 위젯이 dispose될 때 함께 dispose해야 메모리 누수를 방지합니다.
    _loginIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
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
                    '회원가입',
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
                      '계정 생성',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '몇 가지 정보만 입력하면 됩니다!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    // 아이디
                    const Text(
                      '아이디',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _loginIdController, // 컨트롤러 연결
                      decoration: InputDecoration(
                        hintText: '아이디를 입력해 주세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // 비밀번호
                    const Text(
                      '비밀번호',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController, // 컨트롤러 연결
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '8자 이상의 비밀번호를 입력해 주세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // 비밀번호 확인
                    const Text(
                      '비밀번호 확인',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmPasswordController, // 컨트롤러 연결
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        hintText: '비밀번호를 다시 입력해 주세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirm = !_obscureConfirm;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // 이름
                    const Text(
                      '이름',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameController, // 컨트롤러 연결
                      decoration: InputDecoration(
                        hintText: '성명을 입력해 주세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // 이메일
                    const Text(
                      '이메일',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController, // 컨트롤러 연결
                      decoration: InputDecoration(
                        hintText: '이메일을 입력해 주세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 28),
                    // 회원가입 버튼
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _register, // _register 함수 연결
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '회원가입',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 회원가입 결과 메시지 표시
                    Text(
                      _registerMessage,
                      style: TextStyle(
                        color: _registerMessage.contains('성공') ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}