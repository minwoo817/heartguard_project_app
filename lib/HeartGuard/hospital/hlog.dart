import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(Hlog());
}

class Hlog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartGuard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
    final token = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJob3NwaXRhbDEiLCJpYXQiOjE3NDYxNjQ5MjksImV4cCI6MTc0NjI1MTMyOX0.E8PgiPAr823twwyVh39grbOGGot0wJYuKrF0ibAtKk4";

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

  void accept(int lno) async{
    final dio = Dio();
    try{
      final response = await dio.post(
        'http://192.168.40.40:8080/log/state',
        data: {
          "lno" : lno,
          "lstate" : 1,
        },
      );
      if(response.statusCode == 200) {
        fetchLogs();
      }
    }catch(e) {
      print(e);
    }
    print("수락 버튼이 눌렸습니다.");
  }

  // 거절 버튼을 누를 때 해당 lno와 lstate만 보내기
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
        fetchLogs();  // 데이터 새로고침
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
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          var log = logs[index];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("신고 번호: ${log['lno']}", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text("위도: ${log['llat']}"),
                  Text("경도: ${log['llong']}"),
                  Text("상태: ${getStatusText(log['lsate'] ?? log['lstate'])}"),
                  Text("생성일: ${log['create_at']}"),
                  Text("전화번호: ${log['phone']}"),
                  if (log['lstate'] == 2) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,  // 버튼들을 양옆에 고르게 배치
                      children: [
                        TextButton(onPressed: () => accept(log['lno']), child: Text("수락")),
                        TextButton(onPressed: () => refuse(log['lno']), child: Text("거절"),
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