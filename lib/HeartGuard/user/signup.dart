
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';
import 'package:heartguard_project_app/HeartGuard/user/login.dart';

class Signup extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _SignupState();
  }
}
class _SignupState extends State<Signup>{
  TextEditingController uidControl = TextEditingController();
  TextEditingController upwdControl = TextEditingController();
  TextEditingController unameControl = TextEditingController();
  TextEditingController uphoneControl = TextEditingController();

  void onSignup() async{
    final sendData = {
      'uid': uidControl.text,
      'upwd': upwdControl.text,
      'uname': unameControl.text,
      'uphone': uphoneControl.text
    }; print(sendData);
    showDialog(
      context: context,
      builder: (context) => Center( child: CircularProgressIndicator() ,),
      barrierDismissible: false,
    );
    try{
      Dio dio = Dio();
      final response = await dio.post("http://192.168.40.37:8080/user/signup", data: sendData);
      final data = response.data;

      Navigator.pop(context);
      if(data){
        print("회원가입 성공하였습니다.");
        Fluttertoast.showToast(
          msg: "회원가입을 성공했습니다.", // 출력할내용
          toastLength : Toast.LENGTH_LONG , // 메시지 유지시간
          gravity : ToastGravity.BOTTOM, // 메시지 위치 : 앱 적용
          timeInSecForIosWeb: 3 , // 자세한 유지시간 (sec)
          backgroundColor: Colors.black, // 배경색
          textColor: Colors.white, // 글자색상
          fontSize : 16, // 글자크기
        );
        Navigator.pushReplacement(context,  MaterialPageRoute(builder:  (context)=>Login() ) );
      }else{
        print("회원가입 실패하였습니다.");
      }
    }catch(e){print(e);}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Container(
        padding : EdgeInsets.all( 30 ),
        margin : EdgeInsets.all( 30 ) ,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: uidControl,
              decoration: InputDecoration( labelText: "아이디", border: OutlineInputBorder() ),
            ),
            SizedBox( height: 20, ),
            TextField(
              controller: upwdControl,
              obscureText: true, // 입력한 텍스트 가리기
              decoration: InputDecoration( labelText: "비밀번호" , border: OutlineInputBorder() ),
            ),
            SizedBox( height: 20, ),
            TextField(
              controller: unameControl,
              decoration: InputDecoration( labelText: "닉네임" , border: OutlineInputBorder() ),
            ),
            SizedBox( height: 20, ),
            TextField(
              controller: uphoneControl,
              decoration: InputDecoration( labelText: "전화번호" , border: OutlineInputBorder() ),
            ),
            SizedBox( height: 20, ),
            ElevatedButton( onPressed: onSignup , child: Text("회원가입") ),
            SizedBox( height: 20, ),
            TextButton( onPressed: ()=>{
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context)=> Login() )
              )
            }, child: Text("이미 가입된 사용자 이면 _로그인") )
          ],
        ),
      ),
    );
  }
}