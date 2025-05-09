import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardView extends StatefulWidget {
  final int? bno;
  final String? btitle;
  BoardView({this.bno, this.btitle});

  @override
  State<StatefulWidget> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  Map<String, dynamic> board = {};
  List<dynamic> comments = [];
  final dio = Dio();
  final baseUrl = "http://192.168.40.45:8080";
  bool isOwnerOrAdmin = false;
  bool isLoading = true;
  bool isAccessible = true;
  Map<String, dynamic>? userInfo;

  TextEditingController commentController = TextEditingController(
    text: "민원이 접수되었습니다. 궁금한 점이 있으시면, 해당 기관 담당자 연락처로 문의해주세요.",
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onView());
  }

  Future<void> onView() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token != null) {
        dio.options.headers['Authorization'] = "Bearer $token"; // 수정된 부분: "Bearer" 추가

        final userResponse = await dio.get("$baseUrl/user/info");

        if (userResponse.statusCode == 200) {
          userInfo = userResponse.data;
        } else {
          throw Exception('사용자 정보 불러오기 실패');
        }
      }

      final response = await dio.get("$baseUrl/board/view?bno=${widget.bno}");

      if (response.data != null) {
        final boardData = response.data;

        final isAdmin = userInfo != null && userInfo!['ustate'] == 1;
        final isAuthor = userInfo != null &&
            userInfo!['uno'].toString() == boardData['uno'].toString();
        final isPublicCategory = boardData['cno'] == 1;

        setState(() {
          board = boardData;
          isOwnerOrAdmin = isAdmin || isAuthor;
          isAccessible = isPublicCategory || isOwnerOrAdmin;
          isLoading = false;
        });

        if (isAccessible && boardData['cno'] != 1) {
          await fetchComments(widget.bno!);
        }
      } else {
        setState(() {
          isAccessible = false;
          isLoading = false;
        });
      }
    } catch (e) {
      print("오류: $e");
      setState(() {
        isAccessible = false;
        isLoading = false;
      });
    }
  }

  Future<void> fetchComments(int bno) async {
    try {
      final response = await dio.get("$baseUrl/reply/view?bno=$bno");
      setState(() {
        comments = response.data ?? [];
      });
    } catch (e) {
      print("댓글 불러오기 오류: $e");
      setState(() {
        comments = [];
      });
    }
  }

  Future<void> submitComment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null || commentController.text.trim().isEmpty) return;

      dio.options.headers['Authorization'] = "Bearer $token"; // 수정된 부분: "Bearer" 추가

      await dio.post(
        "$baseUrl/reply/post",
        data: {
          "bno": widget.bno,
          "rcontent": commentController.text.trim(),
        },
      );

      commentController.clear();
      commentController.text = "민원이 접수되었습니다. 궁금한 점이 있으시면, 해당 기관 담당자 연락처로 문의해주세요.";
      await fetchComments(widget.bno!);
    } catch (e) {
      print("댓글 등록 오류: $e");
    }
  }

  void onDelete(int bno) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) return;

      dio.options.headers['Authorization'] = "Bearer $token"; // 수정된 부분: "Bearer" 추가
      final response = await dio.delete('$baseUrl/board/delete?bno=$bno');

      if (response.data == true) {
        // 게시글 삭제 후 게시글 목록 화면으로 돌아감
        Navigator.pop(context); // 게시글 화면을 나가서 목록 화면으로 돌아가기
      } else {
        // 삭제 실패시 알림
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 삭제에 실패했습니다.')),
        );
      }
    } catch (e) {
      print("삭제 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: MyAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!isAccessible) {
      return Scaffold(
        appBar: MyAppBar(),
        body: Center(child: Text("이 게시글을 볼 수 있는 권한이 없습니다.")),
      );
    }

    final List<dynamic> images = board['images'] ?? [];

    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 게시글 제목 및 정보
            Text(
              board['btitle'] ?? "",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("작성자: ${board['bwriter']}"),
                Text("조회수: ${board['bview']}"),
              ],
            ),
            SizedBox(height: 10),
            Divider(),


            // 이미지 영역 (카테고리가 1일 때)
            if (board['cno'] == 1 && images.isNotEmpty) ...[
              SizedBox(height: 15), // 위 margin
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    String imageUrl = "$baseUrl/upload/${images[index]}";
                    return Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: ClipRRect(
                        child: Image.network(imageUrl, fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10), // 아래 margin
            ],


            // 게시글 본문
            SizedBox(width: 10),

            Text(board['bcontent'] ?? "", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            // 수정/삭제 버튼
            if (isOwnerOrAdmin)
              Row(
                children: [
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => onDelete(board['bno']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFDAE0), // 배경색
                      foregroundColor: Colors.black,      // 글자색
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 1,
                    ),
                    child: Text("삭제"),
                  ),
                ],
              ),
            SizedBox(height: 10),


            // 댓글 작성
            if (board['cno'] != 1 && userInfo != null && userInfo!['ustate'] == 1) ...[
              SizedBox(height: 20),
              Text("댓글", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: "댓글을 입력하세요",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: submitComment,
                  child: Text("댓글 등록"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFDAE0),
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],

            // 댓글 목록
            if (board['cno'] != 1) ...[
              SizedBox(height: 12),
              if (comments.isEmpty)
                Text("댓글이 없습니다."),
              ...comments.map((comment) => Card(
                margin: EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(comment['rcontent']),
                  subtitle: Text("작성자: ${comment['uname']}"),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
