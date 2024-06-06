import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _errorMessageId = '';
  String _errorMessagePw = '';
  String _errorMessageConfirm = '';

  // 회원가입 처리 함수
  Future<void> _signup() async {
    final String emailController = _emailController.text.trim();
    final String pwController = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    // 유효성 검사
    if (!_isValidEmail(emailController)) {
      setState(() {
        _errorMessageId = '유효한 이메일 주소를 입력하세요.';
      });
      return;
    }

    if (!_isValidPassword(pwController)) {
      setState(() {
        _errorMessagePw = '비밀번호는 영어와 숫자의 조합으로 만들어야 합니다.';
      });
      return;
    }

    if (pwController != confirmPassword) {
      setState(() {
        _errorMessageConfirm = '비밀번호가 일치하지 않습니다.';
      });
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController,
        password: pwController,
      );
      setState(() {
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
      //Navigator.pushNamedAndRemoveUntil(
      //context, '/record_my_day', (Route<dynamic> route) => false);
      Navigator.pushNamed(context, '/record_my_day');
    } on FirebaseAuthException catch (e) {
      setState(() {});
      print(e);
    }
  }

  // 이메일 형식 유효성 검사 함수
  bool _isValidEmail(String emailController) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController);
  }

  // 비밀번호 유효성 검사 함수
  bool _isValidPassword(String password) {
    return RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]{6,}$')
            .hasMatch(password) &&
        !_hasThreeConsecutiveSameCharacters(password);
  }

  // 같은 문자 3개 이상 연속 사용 금지 검사 함수
  bool _hasThreeConsecutiveSameCharacters(String text) {
    for (int i = 0; i < text.length - 2; i++) {
      if (text[i] == text[i + 1] && text[i] == text[i + 2]) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(height: height * (60 / 852)),
                    const Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Ribeye',
                        color: Color.fromRGBO(1, 1, 1, 1),
                      ),
                    ),
                    SizedBox(height: height * (20 / 852)),
                    const Text(
                      "Create your account",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromRGBO(1, 1, 1, 0.7),
                        fontFamily: 'Ribeye',
                      ),
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    TextFormField(
                      cursorColor: Colors.black,
                      controller: _emailController,
                      decoration: InputDecoration(
                          errorText: _errorMessageId,
                          hintText: "Email",
                          hintStyle: const TextStyle(
                            fontFamily: 'Ribeye',
                            color: Color.fromRGBO(1, 1, 1, 0.5),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none),
                          fillColor: const Color.fromRGBO(217, 217, 217, 0.3),
                          filled: true,
                          prefixIcon: const Icon(Icons.email)),
                    ),
                    SizedBox(height: height * (20 / 852)),
                    TextField(
                      controller: _passwordController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        errorText: _errorMessagePw,
                        hintText: "Password",
                        hintStyle: const TextStyle(
                          fontFamily: 'Ribeye',
                          color: Color.fromRGBO(1, 1, 1, 0.5),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none),
                        fillColor: const Color.fromRGBO(217, 217, 217, 0.3),
                        filled: true,
                        prefixIcon: const Icon(Icons.password),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: height * (20 / 852)),
                    TextField(
                      controller: _confirmPasswordController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        errorText: _errorMessageConfirm,
                        hintStyle: const TextStyle(
                          fontFamily: 'Ribeye',
                          color: Color.fromRGBO(1, 1, 1, 0.5),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none),
                        fillColor: const Color.fromRGBO(217, 217, 217, 0.3),
                        filled: true,
                        prefixIcon: const Icon(Icons.password),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
                SizedBox(
                  height: height * (50 / 852),
                  child: ElevatedButton(
                    onPressed: () {
                      _signup();
                      setState(() {
                        _errorMessageConfirm = '';
                        _errorMessageId = '';
                        _errorMessagePw = '';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(17)),
                      backgroundColor: const Color.fromRGBO(1, 1, 1, 0.2),
                    ),
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: width * (13 / 320),
                        fontFamily: 'Ribeye',
                        color: const Color.fromARGB(255, 45, 45, 45),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Do you have a account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: width * (13 / 320),
                          fontFamily: 'Ribeye',
                          color: const Color.fromARGB(255, 45, 45, 45),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
