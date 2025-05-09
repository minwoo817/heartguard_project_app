import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_phone_number/get_phone_number.dart';
import 'package:intl/intl.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

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
  double llat = 0.0;
  double llong = 0.0;
  String? reportTime;
  String resultMessage = "전송 중...";
  bool isLoading = true;
  String errorMessage = '';
  WebSocketChannel? channel;
  List<String> socketMessages = [];  // WebSocket으로 받은 메시지 저장 리스트

  @override
  void initState() {
    super.initState();
    initializeWebSocket();
    submitReport();
  }
  Future<void> asd() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      llat = pos.latitude;
      llong = pos.longitude;
    });
  }

  @override
  void dispose() {
    // WebSocket 연결 종료
    channel?.sink.close(status.normalClosure);
    print("위젯 닫힘");
    super.dispose();
  }

  void initializeWebSocket() async {
    try {
      String phone = await GetPhoneNumber().get();
      channel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.40.40:8080/ws/user/$phone'),
      );

      // WebSocket에 핸드폰 번호 등록 메시지 전송

      channel?.sink.add("신고접수:$phone");

      channel?.stream.listen((message) {
        setState(() {
          socketMessages.add(message);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$message"),
            backgroundColor: Colors.orange.shade600,
            duration: Duration(seconds: 3),
          ),
        );
      });
    } catch (e) {
      print('WebSocket 연결 실패: $e');
    }
  }

  Future<void> submitReport() async {
    try {
      await asd();
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
