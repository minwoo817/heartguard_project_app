import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/hospital/hlogin.dart';
import 'package:heartguard_project_app/HeartGuard/layout/home.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';
import 'package:heartguard_project_app/HeartGuard/user/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login>{
  // 1. 입력상자 컨트롤러
  TextEditingController uidControl = TextEditingController();
  TextEditingController upwdControl = TextEditingController();
  void onLogin() async{
    try{
      Dio dio =Dio();
      final sendData = {"uid": uidControl.text, "upwd": upwdControl.text};
      final response = await dio.post("http://192.168.40.37:8080/user/login", data: sendData);
      final data = response.data;
      if(data != ''){
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()),);
      }else{
        print("로그인 실패하였습니다.");
      }
    }catch(e){print(e);}
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(),
        body: Container(
          padding: EdgeInsets.all(30),
          margin: EdgeInsets.all( 30 ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(controller: uidControl,
                decoration: InputDecoration( labelText: "아이디" , border: OutlineInputBorder() ),
              ),
              SizedBox( height: 20 , ),
              TextField(  controller: upwdControl, obscureText: true,
                decoration: InputDecoration( labelText: "비밀번호" , border: OutlineInputBorder()),
              ),
              SizedBox( height: 20 , ),
              ElevatedButton( onPressed: onLogin , child: Text("로그인") ),
              SizedBox( height: 20 ,),
              TextButton(onPressed: ()=>{
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Signup() )
                )
              }, child: Text("아직 회원이 아니신가요? _회원가입") ),
              SizedBox( height: 20 ,),
              TextButton(onPressed: ()=>{
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Hlogin() )
                )
              }, child: Text("병원 로그인") ),
            ],
          ),
        )
    );
  }
}