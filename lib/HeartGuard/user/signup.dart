import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';
import 'package:heartguard_project_app/HeartGuard/user/login.dart';

class Signup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignupState();
  }
}

class _SignupState extends State<Signup> {
  TextEditingController uidControl = TextEditingController();
  TextEditingController upwdControl = TextEditingController();
  TextEditingController unameControl = TextEditingController();
  TextEditingController uphoneControl = TextEditingController();

  void onSignup() async {
    final uid = uidControl.text.trim().toLowerCase(); // 소문자로 비교
    if (uid.contains("admin") || uid.contains("hospital")) {
      Fluttertoast.showToast(
        msg: "아이디에 'admin' 또는 'hospital'이 포함될 수 없습니다.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16,
      );
      return; // 회원가입 진행 중단
    }

    final sendData = {
      'uid': uidControl.text,
      'upwd': upwdControl.text,
      'uname': unameControl.text,
      'uphone': uphoneControl.text
    };

    showDialog(
      context: context,
      builder: (context) => Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      Dio dio = Dio();
      final response = await dio.post("http://192.168.40.45:8080/user/signup", data: sendData);
      final data = response.data;

      Navigator.pop(context);
      if (data) {
        Fluttertoast.showToast(
          msg: "회원가입을 성공했습니다.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16,
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
      } else {
        print("회원가입 실패하였습니다.");
      }
    } catch (e) {
      Navigator.pop(context); // 에러 시에도 로딩창 제거
      print("에러: $e");
      Fluttertoast.showToast(
        msg: "회원가입 중 오류가 발생했습니다.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16,
      );
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("회원가입", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Color(0xFFfd4b85)),),
                SizedBox(height: 30),
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
                SizedBox(height: 20),
                TextField(
                  controller: unameControl,
                  decoration: InputDecoration(
                    labelText: "닉네임",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: uphoneControl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "전화번호",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFfd4b85),
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("회원가입"),
                  ),
                ),
                SizedBox(height: 20),
                Divider(),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: Text(
                    "이미 가입된 사용자 이면 _로그인",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
