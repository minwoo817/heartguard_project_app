import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';
import 'package:heartguard_project_app/HeartGuard/layout/home.dart';

class UserUpdate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserUpdateState();
}

class _UserUpdateState extends State<UserUpdate> {
  TextEditingController unameControl = TextEditingController();
  TextEditingController uphoneControl = TextEditingController();
  String uid = "";

  @override
  void initState() {
    super.initState();
    loadInfo();
  }

  void loadInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    Dio dio = Dio();
    dio.options.headers['Authorization'] = token;

    try {
      final response = await dio.get("http://192.168.40.37:8080/user/info");
      final data = response.data;

      setState(() {
        uid = data['uid'];
        unameControl.text = data['uname'];
        uphoneControl.text = data['uphone'];
      });
    } catch (e) {
      print("정보 조회 실패: $e");
    }
  }

  void updateUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    Dio dio = Dio();
    dio.options.headers['Authorization'] = token;

    final sendData = {
      "uname": unameControl.text,
      "uphone": uphoneControl.text,
    };

    try {
      final response = await dio.put("http://192.168.40.37:8080/user/update", data: sendData);
      print("수정 성공: ${response.data}");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    } catch (e) {
      print("수정 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Container(
        margin: EdgeInsets.all(60),
        padding: EdgeInsets.all(60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("아이디: $uid"),
            SizedBox(height: 20),
            TextField(
              controller: unameControl,
              decoration: InputDecoration(labelText: "이름", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            TextField(
              controller: uphoneControl,
              decoration: InputDecoration(labelText: "전화번호", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: updateUser, child: Text("회원정보 수정")),
          ],
        ),
      ),
    );
  }
}
