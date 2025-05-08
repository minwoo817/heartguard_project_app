import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_phone_number/get_phone_number.dart';
import 'package:intl/intl.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';

class Report extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SubmitPage();
  }
}

class SubmitPage extends StatefulWidget {
  @override
  _SubmitPageState createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  String? phone;
  double llat = 12.34;
  double llong = 56.78;
  String? reportTime;
  String resultMessage = "전송 중...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    submitReport();
  }

  Future<void> submitReport() async {
    try {
      phone = await GetPhoneNumber().get();
      reportTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

      final sendData = {
        "phone": phone,
        "llat": llat,
        "llong": llong,
      };

      Dio dio = Dio();
      final response = await dio.post(
        "http://192.168.40.40:8080/log/submit",
        data: sendData,
      );

      setState(() {
        resultMessage = response.statusCode == 200
            ? "🚨 신고가 접수되었습니다"
            : "❌ 전송 실패 (${response.statusCode})";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        resultMessage = "❌ 에러 발생: 네트워크 또는 앱 오류";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_hospital, size: 60, color: Colors.redAccent),
                    SizedBox(height: 12),
                    Text("응급 신고 완료", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Divider(height: 30, thickness: 1),
                    buildInfoRow(Icons.phone, "전화번호", phone ?? "로딩 중..."),
                    buildInfoRow(Icons.location_on, "위치", "$llat, $llong"),
                    buildInfoRow(Icons.access_time, "신고 시각", reportTime ?? "로딩 중..."),
                    SizedBox(height: 30),
                    isLoading
                        ? CircularProgressIndicator(color: Colors.redAccent)
                        : Text(
                      resultMessage,
                      style: TextStyle(fontSize: 18, color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.redAccent),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label: $value",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
