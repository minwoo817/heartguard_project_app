import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/user/info.dart';
import 'package:heartguard_project_app/HeartGuard/user/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text("HeartGuard",
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
            onTap: () => {
              Navigator.pushNamed(context, "/adminhome")
            },
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