import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:heartguard_project_app/HeartGuard/board/board.dart';
import 'package:heartguard_project_app/HeartGuard/hospital/hinfo.dart';
import 'package:heartguard_project_app/HeartGuard/hospital/hlog.dart';
import 'package:heartguard_project_app/HeartGuard/hospital/hlogin.dart';
import 'package:heartguard_project_app/HeartGuard/hospital/hospitallog.dart';
import 'package:heartguard_project_app/HeartGuard/layout/adminhome.dart';
import 'package:heartguard_project_app/HeartGuard/layout/home.dart';
import 'package:heartguard_project_app/HeartGuard/layout/usermanagepage.dart';
import 'package:heartguard_project_app/HeartGuard/map/mapview.dart';
import 'package:heartguard_project_app/HeartGuard/user/delete.dart';
import 'package:heartguard_project_app/HeartGuard/user/info.dart';
import 'package:heartguard_project_app/HeartGuard/user/login.dart';
import 'package:heartguard_project_app/HeartGuard/user/report.dart';
import 'package:heartguard_project_app/HeartGuard/user/update.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterNaverMap().init(
      clientId: 'fo1nlo8f10',
      onAuthFailed: (ex) => switch (ex) {
        NQuotaExceededException(:final message) =>
            print("사용량 초과 (message: $message)"),
        NUnauthorizedClientException() ||
        NClientUnspecifiedException() ||
        NAnotherAuthFailedException() =>
            print("인증 실패: $ex"),
      });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/" : (context) => Home(), // 홈화면
        "/login" : (context) => Login(), // 로그인(유저아이콘)
        "/report" : (context) => Report(), // 신고(호출)하기
        "/mapview" : (context) => MapView(), // 지도
        "/board" : (context) => Board(), // 게시판
        "/adminhome" : (context) => AdminHome(), // 관리자 홈화면
        '/info': (context) => Info(), // 내정보(회원)
        '/hlogin' : (context) => Hlogin(), // 병원 로그인
        '/update': (context) => UserUpdate(), // 회원 정보 수정
        '/delete': (context) => UserDelete(), // 회원 정보 삭제
        '/hlog' : (context) => Hlog(), // 병원 호출 로그
        '/usermanagepage' : (context) => UserManagePage(), // 사용자 전체 출력
        '/hinfo' : (context) => Hinfo(), // 병원 정보
        '/hospitallog' : (context) => Hospitallog(),
      }
    );

  }
}