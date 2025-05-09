import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/hospital/hlogin.dart';
import 'package:heartguard_project_app/HeartGuard/layout/adminhome.dart';
import 'package:heartguard_project_app/HeartGuard/layout/home.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';
import 'package:heartguard_project_app/HeartGuard/user/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  // 1. 입력상자 컨트롤러
  TextEditingController uidControl = TextEditingController();
  TextEditingController upwdControl = TextEditingController();

  void onLogin() async {
    try {
      Dio dio = Dio();
      final sendData = {"uid": uidControl.text, "upwd": upwdControl.text};
      final response = await dio.post("http://192.168.40.45:8080/user/login", data: sendData);
      final data = response.data;

      if (data != '') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data);

        // 아이디가 'admin'이면 관리자 페이지로 이동
        if (uidControl.text == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminHome()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
        }
      } else {
        print("로그인 실패하였습니다.");
      }
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          margin: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("로그인", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Color(0xFFfd4b85)),),
              SizedBox(height: 20),
              TextField(
                controller: uidControl,
                decoration: InputDecoration(
                  labelText: "아이디",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: upwdControl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "비밀번호",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFfd4b85),
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("로그인"),
                ),
              ),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => Signup()));
                },
                child: Text("아직 회원이 아니신가요? _회원가입", style: TextStyle(fontSize: 14)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => Hlogin()));
                },
                child: Text("병원 로그인으로 전환", style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
