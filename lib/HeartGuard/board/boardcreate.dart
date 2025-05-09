import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:heartguard_project_app/HeartGuard/layout/adminappbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';

class BoardCreatePage extends StatefulWidget {
  @override
  _BoardCreatePageState createState() => _BoardCreatePageState();
}

class _BoardCreatePageState extends State<BoardCreatePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final Dio dio = Dio();

  String baseUrl = "http://192.168.40.45:8080"; // 서버 주소
  List<File> _images = [];
  final ImagePicker picker = ImagePicker();

  List<Map<String, dynamic>> _categories = [];
  int? selectedCategory;
  String? token;
  int? ustate;
  String? uid; // 로그인된 사용자 UID

  @override
  void initState() {
    super.initState();
    loadTokenAndInit();
  }

  Future<void> loadTokenAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");

    if (token == null) {
      print("로그인이 필요합니다.");
      return;
    }

    await fetchUserInfo();
    await fetchCategories();
  }

  Future<void> fetchUserInfo() async {
    try {
      final response = await dio.get(
        "$baseUrl/user/info",
        options: Options(headers: {'Authorization': token}),
      );

      if (response.statusCode == 200) {
        setState(() {
          ustate = response.data['ustate'];
          print("[DEBUG] ustate: $ustate");
        });
      } else {
        print("유저 정보 불러오기 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("유저 정보 오류: $e");
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await dio.get(
        "$baseUrl/board/category",
        options: Options(headers: {'Authorization': token}),
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData = response.data;

        setState(() {
          _categories = responseData.map((cat) => {
            'cno': cat['cno'],
            'cname': cat['cname'],
          }).toList();

          if (ustate == 0) {
            _categories = _categories.where((cat) => cat['cno'] == 2).toList();
          } else if (ustate == 1) {
            _categories = _categories.where((cat) => cat['cno'] == 1).toList();
          }

          selectedCategory = _categories.isNotEmpty ? _categories[0]['cno'] : null;
        });
      } else {
        print("카테고리 요청 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("카테고리 요청 오류: $e");
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((xfile) => File(xfile.path)).toList();
      });
    }
  }

  Future<void> createPost() async {
    if (token == null) {
      print("로그인이 필요합니다.");
      return;
    }

    try {
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('btitle', titleController.text),
        MapEntry('bcontent', contentController.text),
        MapEntry('cno', selectedCategory.toString()),
      ]);

      // 관리자(ustate == 1)일 때만 이미지 첨부
      if (ustate == 1) {
        for (var file in _images) {
          formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
          ));
        }
      }

      final response = await dio.post(
        "$baseUrl/board/post",
        data: formData,
        options: Options(
          headers: {
            'Authorization': token,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        print("게시글 등록 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("게시글 작성 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: uid == 'admin' ? AdminAppBar() : MyAppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "제목",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedCategory,
              items: _categories
                  .map((cat) => DropdownMenuItem<int>(
                value: cat['cno'] as int,
                child: Text(cat['cname'] as String),
              ))
                  .toList(),
              onChanged: null,
              decoration: InputDecoration(
                labelText: "카테고리",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: "내용",
                border: OutlineInputBorder(

                ),
              ),
              maxLines: 10,
            ),

            // 관리자일 경우에만 이미지 첨부 UI 표시
            if (ustate == 1) ...[
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: Icon(Icons.image),
                label: Text("이미지 첨부"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFDAE0),
                  foregroundColor: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              _images.isEmpty
                  ? Text("선택된 이미지 없음")
                  : Wrap(
                spacing: 8,
                children: _images
                    .map((img) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    img,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ))
                    .toList(),
              ),
            ],

            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: createPost,
                child: Text("작성 완료"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFDAE0),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
