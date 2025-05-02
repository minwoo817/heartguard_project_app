import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';

class AdminHome extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _AdminHomeState();
  }
}

class _AdminHomeState extends State<AdminHome>{
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
                    // CPR, AED 가이드 / AED 설치 제안
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 80,
                            child: TextButton(
                              onPressed: () => Navigator.pushNamed(context, "/"),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)
                                ),
                              ),
                              child: Text("사용자 회원 관리",
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
                              onPressed: () => Navigator.pushNamed(context, "/hlog"),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text("전체 호출 내역",
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
                              child: Text("CPR, AED 가이드 글쓰기",
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
                              child: Text("AED 설치 제안     답변하기",
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