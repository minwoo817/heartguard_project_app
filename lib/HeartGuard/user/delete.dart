import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartguard_project_app/HeartGuard/layout/home.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';

class UserDelete extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserDeleteState();
}

class _UserDeleteState extends State<UserDelete> {
  bool isConfirm = false;

  void deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    Dio dio = Dio();
    dio.options.headers['Authorization'] = token;

    try {
      final response = await dio.delete("http://192.168.40.37:8080/user/delete");
      print("삭제 성공: ${response.data}");

      await prefs.remove('token');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    } catch (e) {
      print("삭제 실패: $e");
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
            Text("정말로 회원 탈퇴하시겠습니까?"),
            SizedBox(height: 20),
            CheckboxListTile(
              title: Text("확인했습니다."),
              value: isConfirm,
              onChanged: (value) {
                setState(() {
                  isConfirm = value ?? false;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConfirm ? deleteUser : null,
              child: Text("회원 탈퇴"),
            ),
          ],
        ),
      ),
    );
  }
}
