import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:heartguard_project_app/HeartGuard/board/boardcreate.dart';
import 'package:heartguard_project_app/HeartGuard/board/boardview.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';

class Board extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BoardState();
  }
}

class _BoardState extends State<Board> {
  int cno = 1; // 기본 카테고리
  bool _isInitialCategorySet = false; // arguments 적용 여부
  List<dynamic> allBoards = [];
  List<dynamic> filteredBoards = [];
  final dio = Dio();
  String baseUrl = "http://192.168.40.13:8080";
  final ScrollController scrollController = ScrollController();

  final Map<int, String> categoryMap = {
    1: "공지사항",
    2: "AED 건의사항",
  };

  @override
  void initState() {
    super.initState();
    fetchAllBoards();
  }

  Future<void> fetchAllBoards() async {
    try {
      final response = await dio.get("$baseUrl/board/all");

      if (response.data != null && response.data['content'] != null) {
        setState(() {
          allBoards = response.data['content'];
          applyCategoryFilter();
        });
      } else {
        print("게시글이 없습니다.");
      }
    } catch (e) {
      print("에러 발생: $e");
    }
  }

  void applyCategoryFilter() {
    setState(() {
      filteredBoards = allBoards
          .where((board) => board['cno'] == cno)
          .toList();

      filteredBoards.sort((a, b) {
        DateTime dateA = DateTime.parse(a['createAt']);
        DateTime dateB = DateTime.parse(b['createAt']);
        return dateB.compareTo(dateA);
      });
    });
  }

  void onCategoryChanged(int newCno) {
    setState(() {
      cno = newCno;
      applyCategoryFilter();
    });
  }

  Future<bool> hasReplies(int bno) async {
    try {
      final response = await dio.get("$baseUrl/reply/view", queryParameters: {"bno": bno});
      return response.data != null && response.data.isNotEmpty;
    } catch (e) {
      print("댓글 조회 에러: $e");
      return false;
    }
  }

  Future<void> _onRefresh() async {
    await fetchAllBoards();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (!_isInitialCategorySet && args != null && args.containsKey("category")) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          cno = args["category"];
          applyCategoryFilter();
          _isInitialCategorySet = true;
        });
      });
    }

    return Scaffold(
      appBar: MyAppBar(),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text("카테고리: "),
                  SizedBox(width: 10),
                  DropdownButton<int>(
                    value: cno,
                    items: categoryMap.entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onCategoryChanged(value);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredBoards.isEmpty
                  ? Center(child: Text("해당 카테고리의 게시글이 없습니다."))
                  : ListView.builder(
                itemCount: filteredBoards.length,
                itemBuilder: (context, index) {
                  final board = filteredBoards[index];

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoardView(bno: board['bno']),
                        ),
                      );
                    },
                    child: FutureBuilder<bool>(
                      future: hasReplies(board['bno']),
                      builder: (context, snapshot) {
                        String statusMessage = '';
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(); // 로딩 중일 때는 빈 위젯
                        }
                        if (snapshot.hasData && cno == 2) {
                          statusMessage = snapshot.data! ? "접수완료" : "접수대기";
                        }

                        return Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  Text(
                                    board['btitle'],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (statusMessage.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        statusMessage,
                                        style: TextStyle(
                                          color: statusMessage == "접수완료"
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text("작성자: ${board['bwriter']}", style: TextStyle(fontSize: 14)),
                                  Text("작성일: ${board['createAt'].split("T")[0]}", style: TextStyle(fontSize: 14)),
                                  Text("조회수: ${board['bview']}", style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            ),
                            Divider(),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BoardCreatePage(),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.black),
        backgroundColor: Color(0xFFFFDAE0),
      ),
    );
  }
}
