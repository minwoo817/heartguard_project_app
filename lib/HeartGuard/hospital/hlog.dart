import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart'; // MyAppBar import

class Hlog extends StatefulWidget {
  @override
  _HlogState createState() => _HlogState();
}

class _HlogState extends State<Hlog> {
  List<dynamic> logs = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final response = await dio.get(
        'http://192.168.40.40:8080/log/view',
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
        errorMessage = '오류가 발생했습니다: $e';
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
        return Colors.red; // 거절은 빨간색
      case '1':
        return Colors.green; // 수락은 초록색
      case '2':
        return Colors.orange; // 대기중은 주황색
      default:
        return Colors.black; // 기본 색상 (에러나 다른 상태에 대비)
    }
  }

  void accept(int lno) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        'http://192.168.40.40:8080/log/state',
        data: {
          "lno": lno,
          "lstate": 1,
        },
      );
      if (response.statusCode == 200) {
        fetchLogs();
      }
    } catch (e) {
      print(e);
    }
  }

  void refuse(int lno) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        'http://192.168.40.40:8080/log/state',
        data: {
          "lno": lno,
          "lstate": 0,
        },
      );
      if (response.statusCode == 200) {
        fetchLogs();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(), // MyAppBar 사용
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
          : ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          var log = logs[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            elevation: 5,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("신고 번호: ${log['lno']}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue),
                      SizedBox(width: 6),
                      Text("위도: ${log['llat']}, 경도: ${log['llong']}",
                          style: TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.orange),
                      SizedBox(width: 6),
                      Text("생성일: ${log['create_at']}",
                          style: TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.green),
                      SizedBox(width: 6),
                      Text("전화번호: ${log['phone']}",
                          style: TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                  // 상태 항목을 제일 마지막으로 이동
                  SizedBox(height: 10),
                  Text(
                    "상태: ${getStatusText(log['lsate'] ?? log['lstate'])}",
                    style: TextStyle(
                      fontSize: 14,
                      color: getStatusColor(log['lsate'] ?? log['lstate']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  if (log['lstate'] == 2) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 수락 버튼
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () => accept(log['lno']),
                            child: Text("수락", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SizedBox(width: 10),
                        // 거절 버튼
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () => refuse(log['lno']),
                            child: Text("거절", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
