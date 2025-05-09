import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/hospital/hlogin.dart';
import 'package:heartguard_project_app/HeartGuard/layout/home.dart';
import 'package:heartguard_project_app/HeartGuard/layout/hospitalmyappbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Hinfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HinfoState();
}

class _HinfoState extends State<Hinfo> {
  int hno = 0;
  String hid = "";
  String type = "";
  String name = "";
  String location = "";
  String tel = "";
  String emgTel = "";
  String address = "";

  @override
  void initState() {
    super.initState();
    hloginCheck();
  }

  bool? isLogin;

  void hloginCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      setState(() {
        isLogin = true;
        onHinfo(token);
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Hlogin()),
      );
    }
  }

  void onHinfo(token) async {
    try {
      Dio dio = Dio();
      dio.options.headers['Authorization'] = token;
      final response = await dio.get("http://192.168.40.40:8080/hospital/info");
      final data = response.data;
      if (data != '') {
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
    } catch (e) {
      print(e);
    }
  }

  void hlogout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    Dio dio = Dio();
    dio.options.headers['Authorization'] = token;
    await dio.get("http://192.168.40.40:8080/hospital/logout");
    await prefs.remove('token');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    if (isLogin == null) {
      return Scaffold(
        appBar: HospitalMyAppbar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HospitalMyAppbar(),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(40),
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade100,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("병원번호 : $hno", style: TextStyle(fontSize: 16)),
              SizedBox(height: 12),
              Text("아이디 : $hid", style: TextStyle(fontSize: 16)),
              SizedBox(height: 12),
              Text("타입 : $type", style: TextStyle(fontSize: 16)),
              SizedBox(height: 12),
              Text("이름 : $name", style: TextStyle(fontSize: 16)),
              SizedBox(height: 12),
              Text("지역 : $location", style: TextStyle(fontSize: 16)),
              SizedBox(height: 12),
              Text("전화번호 : $tel", style: TextStyle(fontSize: 16)),
              SizedBox(height: 12),
              Text("응급 전화번호 : $emgTel", style: TextStyle(fontSize: 16)),
              SizedBox(height: 12),
              Text("주소 : $address", style: TextStyle(fontSize: 16)),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hlogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text("로그아웃", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
