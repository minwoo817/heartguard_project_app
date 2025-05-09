import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/user/info.dart';
import 'package:heartguard_project_app/HeartGuard/user/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {

  void getUid(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        Navigator.pushReplacementNamed(context, '/');
        return;
      }

      Dio dio = Dio();
      dio.options.headers['Authorization'] = token;

      final response = await dio.get("http://192.168.40.45:8080/user/info");
      final uid = response.data['uid'];

      if (uid == 'admin') {
        Navigator.pushNamed(context, '/adminhome');
      } else {
        Navigator.pushNamed(context, '/');
      }
    } catch (e) {
      print('토큰 오류 또는 네트워크 에러: $e');
      Navigator.pushNamed(context, '/');
    }
  }


  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("HeartGuard | 골든타임 구조 플랫폼",
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      toolbarHeight: 80.0,

      backgroundColor: Color(0xFFFFDAE0),
      leadingWidth: 70,

        // 왼쪽 로고
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => getUid(context),
            child: Image.asset(
              'assets/images/logo1.png',
              width: 70,
              fit: BoxFit.contain,
            ),
          ),
        ),

      // 오른쪽 아이콘
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 30),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');

              if (token != null && token.isNotEmpty) {
                // 로그인 되어 있음 → 내 정보 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Info()),
                );
              } else {
                // 로그인 안 되어 있음 → 로그인 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              }
            },
          ),
        ]
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70.0);
}