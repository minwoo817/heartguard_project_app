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
  String baseUrl = "http://172.30.1.78:8080"; // API base URL

  List<File> _images = [];
  final ImagePicker picker = ImagePicker();
  List<Map<String, dynamic>> _categories = [];
  int? selectedCategory;

  String token = "Bearer YOUR_TOKEN_HERE"; // TODO: 실제 토큰으로 교체

  @override
  void initState() {
    super.initState();
    fetchCategories(); // 카테고리 데이터 가져오기
  }

  // 카테고리 목록을 서버에서 가져오는 함수
  Future<void> fetchCategories() async {
    try {
      final response = await dio.get("$baseUrl/board/categoryall");

      if (response.statusCode == 200) {
        print("서버에서 받은 카테고리 데이터: ${response.data}");
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
      }
    } catch (e) {
      print("카테고리 불러오기 실패: $e");
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
        print("업로드 실패: ${response.data}");
      }
    } catch (e) {
      print("에러 발생: $e");
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
            // 제목 입력
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "제목",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // 내용 입력
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: "내용",
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
            ),
            SizedBox(height: 16),

            // 카테고리 드롭다운
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

            // 이미지 선택 버튼
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

            // 이미지 미리보기
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

            // 작성 완료 버튼
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
