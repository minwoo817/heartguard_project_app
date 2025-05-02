import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartGuard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LogList(hno: 1), // 예시로 병원 번호를 1로 설정
    );
  }
}

class LogList extends StatefulWidget {
  final int hno; // 병원 번호

  LogList({required this.hno});

  @override
  _LogListState createState() => _LogListState();
}

class _LogListState extends State<LogList> {
  int page = 1; // 현재 페이지
  List<dynamic> logList = []; // 로그 목록 상태변수
  final dio = Dio(); // Dio 객체
  String baseUrl = "http://192.168.40.40:8080"; // 기본 자바서버 URL
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchLogs(page); // 첫 페이지 로드
    scrollController.addListener(onScroll); // 스크롤 리스너 추가
  }

  // 1. 자바서버에게 로그 자료 요청
  void fetchLogs(int currentPage) async {
    try {
      final response = await dio.get(
        "$baseUrl/view?hno=${widget.hno}&page=${currentPage}", // 병원 번호와 페이지 번호를 전달
      );
      setState(() {
        page = currentPage;
        if (page == 1) {
          logList = response.data['content']; // 첫 페이지일 경우 데이터 덮어쓰기
        } else if (page >= response.data['totalPages']) {
          page = response.data['totalPages']; // 마지막 페이지 처리
        } else {
          logList.addAll(response.data['content']); // 다음 페이지일 경우 데이터 추가
        }
      });
    } catch (e) {
      print(e);
    }
  }

  // 2. 스크롤 리스너
  void onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 150) {
      fetchLogs(page + 1); // 스크롤 바닥에 도달하면 다음 페이지 요청
    }
  }

  @override
  Widget build(BuildContext context) {
    if (logList.isEmpty) {
      return Center(child: Text("조회된 로그가 없습니다."));
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: logList.length,
      itemBuilder: (context, index) {
        final log = logList[index];

        return InkWell(
          onTap: () {
            // 로그 항목 클릭 시 상세보기 페이지로 이동 (예시로 로그 번호를 넘기기)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LogDetailPage(logId: log['id'])),
            );
          },
          child: Card(
            margin: EdgeInsets.all(12),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  // 여기에 이미지 없이 텍스트 정보만 표시
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "전화번호: ${log['phone']}",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text("위도: ${log['latitude']}", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text("경도: ${log['longitude']}", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text("상태: ${log['state']}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class LogDetailPage extends StatelessWidget {
  final int logId;

  LogDetailPage({required this.logId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("로그 상세보기"),
      ),
      body: Center(
        child: Text("로그 ID: $logId"),
      ),
    );
  }
}
