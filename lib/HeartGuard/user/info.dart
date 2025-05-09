import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/layout/home.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';
import 'package:heartguard_project_app/HeartGuard/layout/adminappbar.dart';
import 'package:heartguard_project_app/HeartGuard/user/delete.dart';
import 'package:heartguard_project_app/HeartGuard/user/login.dart';
import 'package:heartguard_project_app/HeartGuard/user/update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Info extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InfoState();
  }
}

class _InfoState extends State<Info> {
  int uno = 0;
  String uid = "";
  String uname = "";
  String uphone = "";
  bool? isLogin;

  @override
  void initState() {
    super.initState();
    loginCheck();
  }

  void loginCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      setState(() {
        isLogin = true;
        print("로그인 중입니다.");
        onInfo(token);
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  void onInfo(token) async {
    try {
      Dio dio = Dio();
      dio.options.headers['Authorization'] = token;
      final response = await dio.get("http://192.168.40.45:8080/user/info");
      final data = response.data;
      print(data);
      if (data != '') {
        setState(() {
          uid = data['uid'];
          uname = data['uname'];
          uphone = data['uphone'];
          uno = data['uno'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    Dio dio = Dio();
    dio.options.headers['Authorization'] = token;
    await dio.get("http://192.168.40.45:8080/user/logout");
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLogin == null) {
      return Scaffold(
        appBar: MyAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: uid == 'admin' ? AdminAppBar() : MyAppBar(),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(40),
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade100,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("회원번호 : $uno", style: TextStyle(fontSize: 16)),
              SizedBox(height: 12),
              Text("아이디 : $uid", style: TextStyle(fontSize: 16)),
              SizedBox(height: 12),
              Text("이름(닉네임) : $uname", style: TextStyle(fontSize: 16)),
              SizedBox(height: 12),
              Text("전화번호 : $uphone", style: TextStyle(fontSize: 16)),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text("로그아웃", style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(height: 16),
              if (uid != 'admin') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserUpdate()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text("회원정보 수정", style: TextStyle(fontSize: 16)),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserDelete()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text("회원 탈퇴", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
