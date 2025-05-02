
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/layout/home.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';
import 'package:heartguard_project_app/HeartGuard/user/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Hlogin extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _HloginState();
  }
}

class _HloginState extends State<Hlogin>{
  TextEditingController hidControl = TextEditingController();
  TextEditingController hpwdControl = TextEditingController();
  void onHlogin() async{
    try{
      Dio dio = Dio();
      final sendData ={'hid': hidControl.text, 'hpwd': hpwdControl.text};
      final response = await dio.post("http://192.168.40.37:8080/hospital/login", data: sendData);
      final data= response.data;
      if(data != ''){
        final prefs =await SharedPreferences.getInstance();
        await prefs.setString('token', data);
        Navigator.pushReplacement(
          context ,
          MaterialPageRoute(builder: (context)=>Home() ), // 병원 페이지 연동 Home X
        );
      }else{
        print("로그인 실패하였습니다.");
      }
    }catch(e){print(e);}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Container( // 여백 제공하는 박스 위젯
        padding: EdgeInsets.all( 30 ) , // 박스 안쪽 여백
        margin: EdgeInsets.all( 30 ) , // 박스 바깥 여백
        child: Column( // 하위 요소 세로 위젯
          mainAxisAlignment: MainAxisAlignment.center, // 현재 축(Column) 기준으로 정렬
          children: [ // 하위 요소들 위젯
            TextField(  controller: hidControl,
              decoration: InputDecoration( labelText: "아이디" , border: OutlineInputBorder() ),
            ),
            SizedBox( height: 20 , ),
            TextField(  controller: hpwdControl, obscureText: true, // 입력값 감추기
              decoration: InputDecoration( labelText: "비밀번호" , border: OutlineInputBorder()),
            ),
            SizedBox( height: 20 , ),
            ElevatedButton( onPressed: onHlogin , child: Text("로그인") ),
            SizedBox( height: 20 ,),
            TextButton(onPressed: ()=>{
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Hlogin() )
              )
            }, child: Text("사용자 로그인") )
          ],
        ),
      ),
    );
  }
}