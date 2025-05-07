import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';

class BoardCreatePage extends StatefulWidget {
  @override
  _BoardCreatePageState createState() => _BoardCreatePageState();
}

class _BoardCreatePageState extends State<BoardCreatePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final Dio dio = Dio();

  // ✅ 에뮬레이터용 로컬 서버 주소
  String baseUrl = "http://192.168.40.13:8080";

  List<File> _images = [];
  final ImagePicker picker = ImagePicker();
  List<Map<String, dynamic>> _categories = [];
  int? selectedCategory;

  // ✅ JWT 토큰 (공백 제거)
  final String rawToken =
      "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhYmMxMjMiLCJpYXQiOjE3NDY1OTA0NTksImV4cCI6MTc0NjY3Njg1OX0.fDY4ncxwcshpvW7rBPCtBEo8gPnxQ6UCME_B3jd1-DQ";
  late final String token;

  @override
  void initState() {
    super.initState();
    token = "${rawToken.trim()}";
    print("[DEBUG] JWT 토큰: '$token'"); // 공백 확인
    fetchCategories(); // 카테고리 불러오기
  }

  // 카테고리 불러오기
  Future<void> fetchCategories() async {
    try {
      final response = await dio.get(
        "$baseUrl/board/category",
        options: Options(headers: {
          'Authorization': token,
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData = response.data;
        setState(() {
          _categories = responseData
              .map((cat) => {
            'cno': cat['cno'],
            'cname': cat['cname'],
          })
              .toList();
          selectedCategory = _categories.isNotEmpty ? _categories[0]['cno'] : null;
        });
      } else {
        print("카테고리 요청 실패: ${response.statusCode} - ${response.data}");
      }
    } catch (e) {
      if (e is DioError) {
        print("DioError (카테고리): ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        print("Unexpected error (카테고리): $e");
      }
    }
  }

  // 이미지 선택
  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((xfile) => File(xfile.path)).toList();
      });
    }
  }

  // 게시글 생성
  Future<void> createPost() async {
    try {
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('btitle', titleController.text),
        MapEntry('bcontent', contentController.text),
        MapEntry('cno', selectedCategory.toString()),
      ]);

      for (var file in _images) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(file.path),
        ));
      }

      final response = await dio.post(
        "$baseUrl/board/post",
        data: formData,
        options: Options(headers: {
          'Authorization': token,
          'Content-Type': 'multipart/form-data',
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        print("업로드 실패: ${response.statusCode} - ${response.data}");
      }
    } catch (e) {
      if (e is DioError) {
        print("DioError (게시글 작성): ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        print("Unexpected error (게시글 작성): $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
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
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: "내용",
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
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
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              decoration: InputDecoration(
                labelText: "카테고리 선택",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: Icon(Icons.image),
              label: Text("이미지 여러 장 첨부"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFDAE0),
                foregroundColor: Colors.white,
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
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: createPost,
                child: Text("작성 완료"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFDAE0),
                  foregroundColor: Colors.white,
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
