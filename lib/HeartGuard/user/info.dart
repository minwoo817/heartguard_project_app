
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/layout/home.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';
import 'package:heartguard_project_app/HeartGuard/user/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Info extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _InfoState();
  }
}

class _InfoState extends State<Info>{
  int uno = 0;
  String uid = "";
  String uname = "";
  String uphone = "";

  @override
  void initState() {loginCheck();}

  bool? isLogin;
  void loginCheck() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if( token != null && token.isNotEmpty ){
      setState(() {
        isLogin = true; print("로그인 중입니다.");
        onInfo( token );
      });
    }else{
      Navigator.pushReplacement( context , MaterialPageRoute(builder: (context) => Login() ) );
    }
  }

  void onInfo(token) async{
    try{
      Dio dio = Dio();
      dio.options.headers['Authorization'] = token;
      final response = await dio.get( "http://192.168.40.37:8080/user/info" );
      final data = response.data; print( data );
      if(data != ''){
        setState(() {
          uid = data['uid'];
          uname = data['uname'];
          uphone = data['uphone'];
          uno = data['uno'];
        });

      }
    }catch(e){print(e);}
  }

  void logout() async{
    final prefs =  await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if( token == null  ) return;
    Dio dio = Dio();
    dio.options.headers['Authorization'] = token;
    final response = dio.get("http://192.168.40.37:8080/user/logout");
    await prefs.remove('token');
    Navigator.pushReplacement( context , MaterialPageRoute( builder: (context)=> Home() ));
  }

  @override
  Widget build(BuildContext context) {
    if(isLogin==null){
      return Scaffold(
        appBar: MyAppBar(),
        body: Center(child: CircularProgressIndicator(),),
      );
    }
    return Scaffold(
      appBar: MyAppBar(),
      body: Container(
        margin: EdgeInsets.all( 60 ),
        padding: EdgeInsets.all( 60 ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("회원번호 : $uno" ),
            SizedBox( height: 20,),
            Text("아이디 : $uid  "),
            SizedBox( height: 20,),
            Text("이름(닉네임) : $uname"),
            SizedBox( height: 20,),
            Text("전화번호 : $uphone"),
            SizedBox( height: 20,),
            ElevatedButton(onPressed: logout , child: Text("로그아웃") ),
          ],
        ),
      ),
    );
  }
}