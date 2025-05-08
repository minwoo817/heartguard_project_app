import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/layout/adminappbar.dart';
import 'package:heartguard_project_app/HeartGuard/layout/usermanagepage.dart';

class AdminHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(),
      backgroundColor: Color(0xFFfef7ff),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 관리자 환영 인사
            Text(
              "관리자 페이지",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            /// 사용자 관리
            _buildAdminCard(
              title: "사용자 회원 관리",
              description: "가입된 사용자 목록을 확인하고 관리합니다",
              icon: Icons.people_alt,
              color: Colors.blueGrey,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserManagePage()),
              ),
            ),

            /// 호출 내역
            _buildAdminCard(
              title: "전체 호출 내역",
              description: "AED 호출 로그 전체 조회",
              icon: Icons.history,
              color: Colors.deepOrange,
              onTap: () => Navigator.pushNamed(context, "/hlog"),
            ),

            /// CPR, AED 가이드 글쓰기
            _buildAdminCard(
              title: "CPR, AED 가이드 글쓰기",
              description: "공지사항 등록 및 관리",
              icon: Icons.edit_note,
              color: Colors.black87,
              onTap: () => Navigator.pushNamed(
                context,
                "/board",
                arguments: {"category": 1},
              ),
            ),

            /// AED 설치 제안 답변
            _buildAdminCard(
              title: "AED 설치 제안 답변하기",
              description: "사용자의 설치 제안에 응답",
              icon: Icons.comment,
              color: Colors.teal,
              onTap: () => Navigator.pushNamed(
                context,
                "/board",
                arguments: {"category": 2},
              ),
            ),

            SizedBox(height: 40), // 여백으로 안정감 부여
          ],
        ),
      ),
    );
  }

  /// 공통 카드 위젯
  Widget _buildAdminCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 120,
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 30, color: color),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
