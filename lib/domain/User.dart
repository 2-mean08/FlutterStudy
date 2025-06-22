class User {
  final String loginId;
  final String username;
  final String password;
  final String email;

  User({
    required this.loginId,
    required this.username,
    required this.password,
    required this.email,
  });

  // 회원가입 요청을 위한 JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'loginId': loginId,
      'username': username,
      'password': password,
      'email': email,
    };
  }
}

// 로그인 요청을 위한 별도의 DTO (필요한 경우) 또는 User 모델 재활용
class LoginRequest {
  final String loginId;
  final String password;

  LoginRequest({
    required this.loginId,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'loginId': loginId,
      'password': password,
    };
  }
}