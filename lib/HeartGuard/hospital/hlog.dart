import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/layout/hospitalmyappbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class Hlog extends StatefulWidget {
  @override
  _HlogState createState() => _HlogState();
}

class _HlogState extends State<Hlog> {
  List<dynamic> logs = [];
  bool isLoading = true;
  String errorMessage = '';
  WebSocketChannel? channel;
  List<String> socketMessages = [];  // WebSocket으로 받은 메시지 저장 리스트

  @override
  void initState() {
    super.initState();
    initializeWebSocket();
    fetchLogs();
  }

  @override
  void dispose() {
    // WebSocket 연결 종료
    channel?.sink.close(status.normalClosure);
    super.dispose();
  }

  void initializeWebSocket() async {

    try {
      // WebSocket 채널 초기화
      channel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.40.45:8080/ws/hospital'),
      );
      print('WebSocket에 입장 완료');

      // WebSocket으로 메시지 수신
      channel?.stream.listen((message) {
        if (!mounted) return;

        // 새로운 로그 재호출
        fetchLogs();

        setState(() {
          socketMessages.add(message); // 수신된 메시지를 리스트에 추가
        });
        // SnackBar 알림
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


  Future<void> fetchLogs() async {
    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final response = await dio.get(
        'http://192.168.40.45:8080/log/view',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          logs = response.data;
          logs.sort((a, b) => b['lno'].compareTo(a['lno']));
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = '로그를 불러오는 데 실패했습니다.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '오류 발생: $e';
        isLoading = false;
      });
    }
  }

  String getStatusText(dynamic state) {
    switch (state.toString()) {
      case '0':
        return '거절';
      case '1':
        return '수락';
      case '2':
        return '대기중';
      default:
        return '알 수 없음';
    }
  }

  Color getStatusColor(dynamic state) {
    switch (state.toString()) {
      case '0':
        return Colors.red;
      case '1':
        return Colors.green;
      case '2':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  void accept(int lno) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        'http://192.168.40.45:8080/log/state',
        data: {"lno": lno, "lstate": 1},
      );
      if (response.statusCode == 200) fetchLogs();
    } catch (e) {
      print(e);
    }
  }

  void refuse(int lno) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        'http://192.168.40.45:8080/log/state',
        data: {"lno": lno, "lstate": 0},
      );
      if (response.statusCode == 200) fetchLogs();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HospitalMyAppbar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(errorMessage,
            style: TextStyle(color: Colors.red)),
      )
          : Column(
        children: [
          // 신고 로그 목록
          Expanded(
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                var log = logs[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("신고 번호: ${log['lno']}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.blue),
                            SizedBox(width: 6),
                            Text(
                                "위도: ${log['llat']}, 경도: ${log['llong']}"),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Colors.orange),
                            SizedBox(width: 6),
                            Text("생성일: ${log['create_at']}"),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.phone,
                                color: Colors.green),
                            SizedBox(width: 6),
                            Text("전화번호: ${log['phone']}"),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          "상태: ${getStatusText(log['lstate'])}",
                          style: TextStyle(
                            color: getStatusColor(log['lstate']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        if (log['lstate'] == 2)
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    accept(log['lno']),
                                child: Text("수락"),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Colors.green),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () =>
                                    refuse(log['lno']),
                                child: Text("거절"),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
