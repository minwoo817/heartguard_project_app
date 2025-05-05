import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
  String baseUrl = "http://172.30.1.72:8080 ";
  final ScrollController scrollController = ScrollController();

  final Map<int, String> categoryMap = {
    1: "공지사항",
    2: "ＡＥＤ 건의사항",
  };

  @override
  void initState() {
    super.initState();
    fetchAllBoards();
  }

  void fetchAllBoards() async {
    try {
      final response = await dio.get("$baseUrl/board/all");

      setState(() {
        allBoards = response.data['content'];
        applyCategoryFilter(); // 기본 카테고리 필터 적용
      });
    } catch (e) {
      print("에러 발생: $e");
    }
  }

  void applyCategoryFilter() {
    setState(() {
      filteredBoards = allBoards.where((board) => board['cno'] == cno).toList();
    });
  }

  void onCategoryChanged(int newCno) {
    setState(() {
      cno = newCno;
      applyCategoryFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Column(
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
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          board['btitle'],
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                      Divider(height: 1),
                    ],
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
