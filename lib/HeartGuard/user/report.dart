import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_phone_number/get_phone_number.dart';
import 'package:intl/intl.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';
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
  double llat = 12.34;
  double llong = 56.78;
  String? reportTime;
  String resultMessage = "전송 중...";
  bool isLoading = true;
  late WebSocketChannel channel;

  // WebSocket 메시지를 받을 리스트
  List<String> socketMessages = [];

  // 1회성으로 보여줄 메시지 변수
  String oneTimeMessage = "";

  @override
  void initState() {
    super.initState();
    submitReport();

    // WebSocket 연결
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.40.40:8080/ws/notify'),
    );

    // WebSocket 메시지 수신
    channel.stream.listen((message) {
      // WebSocket 메시지가 오면 1회성 메시지로 처리
      setState(() {
        oneTimeMessage = message;
      });

      // 3초 후 1회성 메시지 삭제
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          oneTimeMessage = ""; // 메시지 초기화
        });
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
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

      // WebSocket을 통해 실시간 알림 전송
      if (response.statusCode == 200) {
        // 1회성 메시지 설정
        setState(() {
          oneTimeMessage = "🚨 새로운 신고가 접수되었습니다!";
        });

        // 1회성 메시지가 화면에 올라가고 사라짐
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            oneTimeMessage = "";
          });
        });

        // WebSocket을 통해 메시지 전송
        channel.sink.add("🚨 새로운 신고가 접수되었습니다!"); // 서버에 메시지 전송
      }

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
                    // 실시간 WebSocket 메시지 출력 (알림)
                    if (socketMessages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...socketMessages.map((msg) => Text("• $msg", style: TextStyle(color: Colors.black))),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // 핸드폰 화면 하단에 1회성 메시지 띄우기
      bottomSheet: oneTimeMessage.isNotEmpty
          ? Container(
        width: double.infinity, // 가로로 꽉 차게 설정
        color: Colors.orange,
        padding: EdgeInsets.all(16),
        child: Text(
          oneTimeMessage,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      )
          : SizedBox.shrink(), // 빈 공간
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
