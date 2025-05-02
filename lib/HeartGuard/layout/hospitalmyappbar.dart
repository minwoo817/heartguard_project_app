import 'package:flutter/material.dart';

class HospitalMyAppbar extends StatelessWidget implements PreferredSizeWidget {
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
          onTap: () => {
            Navigator.pushNamed(context, "/hlog")
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
          icon: Icon(Icons.account_circle, size: 30,),
          onPressed: () => {
            Navigator.pushNamed(context, "/hinfo")
          },
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70.0);
}