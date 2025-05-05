import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardView extends StatefulWidget {
  int? bno;
  String? btitle;
  BoardView({this.bno, this.btitle});

  @override
  State<StatefulWidget> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  Map<String, dynamic> board = {};
  List<dynamic> replies = [];
  final dio = Dio();
  final baseUrl = "http://172.30.1.72:8080"; //
  bool isOwner = false;
  bool isAdmin = false;
  bool isPublicCategory = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onView());
  }

  void onView() async {
    try {
      final response = await dio.get("$baseUrl/board/view?bno=${widget.bno}");

      if (response.data != null) {
        setState(() => board = response.data);

        isPublicCategory = board['cno'] == 1;

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString("token");

        if (token != null) {
          dio.options.headers['Authorization'] = token;
          final userRes = await dio.get("$baseUrl/user/info");

          final uid = userRes.data['uid'];
          final role = userRes.data['role'];

          setState(() {
            isOwner = uid == board['uid'];
            isAdmin = role == 'admin';
          });

          if (isOwner || isAdmin) {
            await loadReplies();
          }
        }
      }
    } catch (e) {
      print("오류 발생: $e");
    }
  }

  Future<void> loadReplies() async {
    try {
      final res = await dio.get("$baseUrl/reply/list?bno=${widget.bno}");
      setState(() => replies = res.data);
    } catch (e) {
      print("댓글 로딩 오류: $e");
    }
  }

  void onDelete(int bno) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) return;

      dio.options.headers['Authorization'] = token;
      final response = await dio.delete('$baseUrl/board/delete?bno=$bno');

      if (response.data == true) {
        print("삭제 성공");
        Navigator.pop(context);
      }
    } catch (e) {
      print("삭제 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isPublicCategory && !isOwner && !isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text("접근 제한")),
        body: Center(child: Text("이 게시글을 볼 수 있는 권한이 없습니다.")),
      );
    }

    if (board.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("게시글 상세")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<dynamic> images = board['images'] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text("게시글 상세")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              Container(
                height: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    String imageUrl = "$baseUrl/upload/${images[index]}";
                    return Padding(
                      padding: EdgeInsets.all(5),
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    );
                  },
                ),
              ),

            if (images.isNotEmpty) SizedBox(height: 24),

            Text(
              board['btitle'],
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("카테고리: ${board['cname']}"),
                Text("조회수: ${board['bview']}"),
              ],
            ),
            SizedBox(height: 10),
            Text("작성자: ${board['bwriter']}"),
            SizedBox(height: 20),
            Text("게시글 내용", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(board['bcontent']),
            SizedBox(height: 16),

            if (isOwner || isAdmin)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("댓글", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ...replies.map((reply) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text("${reply['rwriter']}: ${reply['rcontent']}"),
                  )),
                  if (isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "댓글 작성",
                        ),
                        onSubmitted: (text) async {
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString("token");
                            if (token == null) return;
                            dio.options.headers['Authorization'] = token;

                            await dio.post("$baseUrl/reply/write",
                                data: {"bno": board['bno'], "rcontent": text});

                            await loadReplies();
                          } catch (e) {
                            print("댓글 작성 오류: $e");
                          }
                        },
                      ),
                    )
                ],
              ),

            if (isOwner)
              Row(
                children: [
                  ElevatedButton(onPressed: () {}, child: Text("수정")),
                  SizedBox(width: 8),
                  ElevatedButton(
                      onPressed: () => onDelete(board['bno']),
                      child: Text("삭제")),
                ],
              )
          ],
        ),
      ),
    );
  }
}
