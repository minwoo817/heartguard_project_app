import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:heartguard_project_app/HeartGuard/layout/adminappbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManagePage extends StatefulWidget {
  @override
  _UserManagePageState createState() => _UserManagePageState();
}

class _UserManagePageState extends State<UserManagePage> {
  List<dynamic> userList = [];
  String token = "";
  int currentPage = 1;
  int totalPages = 1;
  String searchKeyword = "";

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTokenAndFetchUsers();
  }

  void loadTokenAndFetchUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token') ?? '';
    if (savedToken.isEmpty) return;

    setState(() {
      token = savedToken;
    });

    fetchUsers();
  }

  void fetchUsers({int page = 1, String keyword = ""}) async {
    try {
      Dio dio = Dio();
      dio.options.headers['Authorization'] = token;

      final response = await dio.get(
        "http://192.168.40.37:8080/user/all",
        queryParameters: {"page": page, "keyword": keyword},
      );

      final resultData = response.data;
      setState(() {
        currentPage = resultData['number'] + 1;
        totalPages = resultData['totalPages'];
        userList = resultData['content'];
      });
    } catch (e) {
      print("회원 목록 불러오기 실패: $e");
    }
  }

  void confirmDelete(int uno) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("회원 삭제"),
          content: Text("정말로 이 회원을 삭제하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: Text("취소"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFfd4b85),
                foregroundColor: Colors.white,
              ),
              child: Text("예"),
              onPressed: () {
                Navigator.of(context).pop();
                deleteUser(uno);
              },
            ),
          ],
        );
      },
    );
  }

  void deleteUser(int uno) async {
    try {
      Dio dio = Dio();
      dio.options.headers['Authorization'] = token;

      final response = await dio.delete(
        "http://192.168.40.37:8080/user/deleteUser",
        queryParameters: {"uno": uno},
      );

      if (response.statusCode == 204) {
        fetchUsers(page: currentPage, keyword: searchKeyword); // 새로고침
      } else {
        showErrorDialog("삭제 실패: ${response.data}");
      }
    } catch (e) {
      showErrorDialog("삭제 실패: ${e.toString()}");
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("오류"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onSearch() {
    setState(() {
      searchKeyword = searchController.text;
    });
    fetchUsers(page: 1, keyword: searchKeyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 검색 필드
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "이름으로 검색",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFfd4b85),
                    foregroundColor: Colors.white,
                  ),
                  child: Text("검색"),
                ),
              ],
            ),
            SizedBox(height: 20),

            // 📋 회원 목록
            Expanded(
              child: userList.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Color(0xFFfd4b85)),
                  headingTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  columns: [
                    DataColumn(label: Text("사용자번호")),
                    DataColumn(label: Text("아이디")),
                    DataColumn(label: Text("이름")),
                    DataColumn(label: Text("전화번호")),
                    DataColumn(label: Text("탈퇴")),
                  ],
                  rows: userList.map((user) {
                    return DataRow(cells: [
                      DataCell(Text(user['uno'].toString())),
                      DataCell(Text(user['uid'] ?? '')),
                      DataCell(Text(user['uname'] ?? '')),
                      DataCell(Text(user['uphone'] ?? '')),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Color(0xFFfd4b85),
                          onPressed: () => confirmDelete(user['uno']),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),

            // ⏮️⏭️ 페이지 이동
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: currentPage > 1
                      ? () => fetchUsers(page: currentPage - 1, keyword: searchKeyword)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFfd4b85),
                    foregroundColor: Colors.white,
                  ),
                  child: Text("이전"),
                ),
                SizedBox(width: 10),
                Text("페이지 $currentPage / $totalPages"),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: currentPage < totalPages
                      ? () => fetchUsers(page: currentPage + 1, keyword: searchKeyword)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFfd4b85),
                    foregroundColor: Colors.white,
                  ),
                  child: Text("다음"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
