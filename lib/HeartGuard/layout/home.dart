import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      // backgroundColor: Color(0xFFfef7ff),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 사용자 인사말
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("안녕하세요 👋\n골든타임 구조 플랫폼", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

              ],
            ),
            SizedBox(height: 24),

            /// AED 찾기 카드
            _buildFeatureCard(
              title: "AED 찾기",
              description: "가까운 AED 위치를 확인하세요",
              icon: Icons.favorite,
              color: Color(0xFFfd4b85),
              onTap: () => Navigator.pushNamed(context, "/mapview"),
            ),

            /// 응급실 찾기 카드
            _buildFeatureCard(
              title: "응급실 찾기",
              description: "근처 응급실을 빠르게 검색합니다",
              icon: Icons.local_hospital,
              color: Colors.blueAccent,
              onTap: () => Navigator.pushNamed(context, "/mapview"),
            ),

            /// CPR 가이드 + AED 제안 카드
            Row(
              children: [
                Expanded(
                  child: _buildMiniCard(
                    title: "AED ・ CPR 가이드",
                    icon: Icons.health_and_safety,
                    onTap: () => Navigator.pushNamed(
                      context, "/board", arguments: {"category": 1},
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildMiniCard(
                    title: "AED 설치 제안",
                    icon: Icons.add_location_alt,
                    onTap: () => Navigator.pushNamed(
                      context, "/board", arguments: {"category": 2},
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            /// 관리자 이동 버튼 (테스트용)
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, "/adminhome"),
                child: Text("관리자 이동 (테스트용)", style: TextStyle(color: Colors.grey)),
              ),
            ),

            SizedBox(height: 40), // 하단 여백 추가로 더 안정적인 화면 구성
          ],
        ),
      ),
    );
  }

  /// 메인 기능 카드 위젯
  Widget _buildFeatureCard({
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
        margin: const EdgeInsets.only(bottom: 24),
        elevation: 3,
        child: Container(
          height: 200, // 높이 증가
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 30),
              ),
              SizedBox(width: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text(description, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
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

  /// 하단 기능 미니 카드 (2개 나란히)
  Widget _buildMiniCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.black87),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
