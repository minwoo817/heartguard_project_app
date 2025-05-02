import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(Hlog());
}

class Hlog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartGuard',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: LogList(),
    );
  }
}

class LogList extends StatefulWidget {
  @override
  _LogListState createState() => _LogListState();
}

class _LogListState extends State<LogList> {
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
    final token = "your_jwt_token_here";

    try {
      final response = await dio.get(
        'http://192.168.40.40:8080/log/view',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          logs = response.data;
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

  void accept(int lno) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        'http://192.168.40.40:8080/log/state',
        data: {
          "lno": lno,
          "lstate": 1, // 수락 상태
        },
      );
      if (response.statusCode == 200) {
        fetchLogs(); // 데이터 새로고침
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
          "lstate": 0, // 거절 상태
        },
      );
      if (response.statusCode == 200) {
        fetchLogs(); // 데이터 새로고침
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('신고내역'),
        backgroundColor: Colors.redAccent, // AppBar 색상 변경: FF5252FF 색상 사용
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.redAccent)) // 로딩 인디케이터 색상
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage, style: TextStyle(fontSize: 18, color: Colors.redAccent)))
            : ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            var log = logs[index];

            return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text(
                      "신고 번호: ${log['lno']}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Divider(height: 20, thickness: 1),
                    buildInfoRow(Icons.location_on, "위치", "${log['llat']}, ${log['llong']}"),
                    buildInfoRow(Icons.access_time, "생성일", log['create_at']),
                    buildInfoRow(Icons.phone, "전화번호", log['phone']),
                    buildInfoRow(Icons.info, "상태", getStatusText(log['lstate'] ?? log['lsate'])),
                    SizedBox(height: 16),
                    if (log['lstate'] == 2) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => accept(log['lno']),
                            child: Text("수락" , style: TextStyle(color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => refuse(log['lno']),
                            child: Text("거절", style: TextStyle(color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent, // 거절 버튼 색상
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
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}