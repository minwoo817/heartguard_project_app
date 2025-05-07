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
  int cno = 1; // 선택된 카테고리
  List<dynamic> allBoards = []; // 전체 게시글
  List<dynamic> filteredBoards = []; // 분류한 게시글
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
    fetchAllBoards(); // 처음에 모든 게시글을 불러옴
  }

  // 게시글 전체 불러오기
  Future<void> fetchAllBoards() async {
    try {
      final response = await dio.get("$baseUrl/board/all");
      setState(() {
        allBoards = response.data['content'];
        applyCategoryFilter(); // 카테고리 필터 적용
      });
    } catch (e) {
      print("에러 발생: $e");
    }
  }

  // 카테고리 필터 적용
  void applyCategoryFilter() {
    setState(() {
      filteredBoards = allBoards
          .where((board) => board['cno'] == cno)
          .toList();

      // 작성일 기준으로 내림차순 정렬
      filteredBoards.sort((a, b) {
        DateTime dateA = DateTime.parse(a['createAt']);
        DateTime dateB = DateTime.parse(b['createAt']);
        return dateB.compareTo(dateA);
      });
    });
  }

  // 카테고리 변경 처리
  void onCategoryChanged(int newCno) {
    setState(() {
      cno = newCno;
      applyCategoryFilter();
    });
  }

  // 댓글이 있는지 확인
  Future<bool> hasReplies(int bno) async {
    try {
      final response = await dio.get("$baseUrl/reply/view", queryParameters: {"bno": bno});
      return response.data.isNotEmpty;
    } catch (e) {
      print("댓글 조회 에러: $e");
      return false;
    }
  }

  // 새로 고침 처리
  Future<void> _onRefresh() async {
    await fetchAllBoards(); // 게시글 새로 고침
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefresh, // 새로 고침 처리
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
                          return Container();
                        }
                        if (snapshot.hasData && cno == 2) {
                          if (snapshot.data!) {
                            statusMessage = "접수완료";
                          } else {
                            statusMessage = "접수대기";
                          }
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
          // 글 작성 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BoardCreatePage(),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white, // 아이콘 색상은 하얀색으로 설정
        ),
        backgroundColor: Color(0xFFFFDAE0), // 배경 색상 핑크로 변경
      ),
    );
  }
}
