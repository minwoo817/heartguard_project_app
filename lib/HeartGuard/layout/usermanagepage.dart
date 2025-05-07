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

  void fetchUsers() async {
    try {
      Dio dio = Dio();
      dio.options.headers['Authorization'] = token;

      final response = await dio.get(
        "http://192.168.40.37:8080/user/all",
        queryParameters: {"page": 1},
      );
      final resultData = response.data;
      setState(() {
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
              child: Text("예", style: TextStyle(color: Colors.red)),
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
        setState(() {
          userList.removeWhere((user) => user['uno'] == uno);
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userList.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
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
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => confirmDelete(user['uno']),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
