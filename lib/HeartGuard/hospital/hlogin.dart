import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/hospital/hlog.dart';
import 'package:heartguard_project_app/HeartGuard/layout/hospitalmyappbar.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';
import 'package:heartguard_project_app/HeartGuard/user/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Hlogin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HloginState();
}

class _HloginState extends State<Hlogin> {
  TextEditingController hidControl = TextEditingController();
  TextEditingController hpwdControl = TextEditingController();

  void onHlogin() async {
    try {
      Dio dio = Dio();
      final sendData = {'hid': hidControl.text, 'hpwd': hpwdControl.text};
      final response = await dio.post(
        "http://192.168.40.40:8080/hospital/login",
        data: sendData,
      );
      final data = response.data;
      if (data != '') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Hlog()),
        );
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
      backgroundColor: Colors.white,
      appBar: HospitalMyAppbar(),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          margin: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("병원 로그인", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Color(0xFFfd4b85)),),
              SizedBox(height: 20),
              TextField(
                controller: hidControl,
                decoration: InputDecoration(
                  labelText: "아이디",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: hpwdControl,
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
                  onPressed: onHlogin,
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
                      context, MaterialPageRoute(builder: (context) => Login()));
                },
                child: Text("사용자 로그인으로 전환", style: TextStyle(fontSize: 14, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
