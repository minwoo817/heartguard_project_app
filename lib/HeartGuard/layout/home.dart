import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';

class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 70.0, horizontal: 45.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 삭제예정 (관리자 페이지로 이동)
                    SizedBox(
                      width: double.infinity,
                      height: 80,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, "/adminhome"),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)
                          ),
                        ),
                        child: Text("관리자 이동(테스트)",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // AED 찾기
                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, "/mapview"),
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFFfd4b85),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                          ),
                        ),
                        child: Text("AED 찾기",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // 응급실 찾기
                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, "/mapview"),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                          ),
                        ),
                        child: Text("응급실 찾기",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // CPR, AED 가이드 / AED 설치 제안
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 80,
                            child: TextButton(
                              onPressed: () => Navigator.pushNamed(context, "/board"),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)
                                ),
                              ),
                              child: Text("CPR, AED 가이드",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 80,
                            child: TextButton(
                              onPressed: () => Navigator.pushNamed(context, "/board"),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text("AED 설치 제안",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}