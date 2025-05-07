
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/hospital/hlogin.dart';
import 'package:heartguard_project_app/HeartGuard/layout/home.dart';
import 'package:heartguard_project_app/HeartGuard/layout/hospitalmyappbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Hinfo extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _HinfoState();
  }
}

class _HinfoState extends State<Hinfo>{
  int hno = 0;
  String hid = "";
  String type = "";
  String name = "";
  String location = "";
  String tel = "";
  String emgTel = "";
  String address = "";
  @override
  void initState() { hloginCheck(); }
  bool? isLogin;
  void hloginCheck() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if( token != null && token.isNotEmpty ){ // 전역변수에 (로그인)토큰이 존재하면
      setState(() {
        isLogin = true; print("로그인 중입니다.");
        onHinfo( token ); // 로그인 중일때 로그인 정보 요청 함수 실행
      });
    }else{ // 비로그인 중일때 페이지 전환/이동
      // Navigator.pushReplacement( context , MaterialPageRoute(builder: (context) => 이동할위젯명() ) );
      Navigator.pushReplacement( context , MaterialPageRoute(builder: (context) => Hlogin() ) );
    }
  }
  void onHinfo( token ) async {
    try{
      Dio dio = Dio();
      //* Dio 에서 Headers 정보를 보내는 방법 , Options
      // 방법1 : dio.options.headers['속성명'] = 값;
      // 방법2 : dio.get( options : { headers : { '속성명' : 값 } } )
      dio.options.headers['Authorization'] = token;
      final response = await dio.get( "http://192.168.40.40:8080/hospital/info" );
      final data = response.data; print( data );
      if( data != '' ) {
        setState(() {
          hid = data['hid'];
          type = data['type'];
          name = data['name'];
          location = data['location'];
          tel = data['tel'];
          emgTel = data['emgTel'];
          address = data['address'];
          hno = data['hno'];
        });
      }
    }catch(e){ print(e); }
  }

  void hlogout() async{
    final prefs =  await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if( token == null  ) return;
    Dio dio = Dio();
    dio.options.headers['Authorization'] = token;
    final response = dio.get("http://192.168.40.40:8080/hospital/logout");
    await prefs.remove('token');
    Navigator.pushReplacement( context , MaterialPageRoute( builder: (context)=> Home() ));
  }

  @override
  Widget build(BuildContext context) {
    if( isLogin == null ){
      return Scaffold(
        body: Center( child: CircularProgressIndicator(),),
      );
    }
    return Scaffold(
      appBar: HospitalMyAppbar(),
      body: Container(
        margin: EdgeInsets.all( 60 ),
        padding: EdgeInsets.all( 60 ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("병원번호 : $hno" ),
            SizedBox( height: 20,),
            Text("아이디 : $hid  "),
            SizedBox( height: 20,),
            Text("타입 : $type"),
            SizedBox( height: 20,),
            Text("이름 : $name"),
            SizedBox( height: 20,),
            Text("지역 : $location"),
            SizedBox( height: 20,),
            Text("전화번호 : $tel"),
            SizedBox( height: 20,),
            Text("응급 전화번호 : $emgTel"),
            SizedBox( height: 20,),
            Text("주소 : $address"),
            SizedBox( height: 20,),
            ElevatedButton(onPressed: hlogout , child: Text("로그아웃") ),
          ],
        ),
      ),
    );
  }


}