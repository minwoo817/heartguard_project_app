import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/layout/adminappbar.dart';
import 'package:heartguard_project_app/HeartGuard/layout/hospitalmyappbar.dart';

class Hospitallog extends StatefulWidget {
  @override
  _HospitallogState createState() => _HospitallogState();
}

class _HospitallogState extends State<Hospitallog> {
  List<dynamic> hospitalLogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHospitalLogs();
  }

  Future<void> fetchHospitalLogs() async {
    try {
      final response = await Dio().get('http://192.168.40.45:8080/hospital/all');
      if (response.statusCode == 200) {
        setState(() {
          hospitalLogs = response.data ?? []; // null이면 빈 리스트로 초기화
          isLoading = false;
        });
      } else {
        throw Exception('데이터를 불러오지 못했습니다');
      }
    } catch (e) {
      print("에러 발생: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: hospitalLogs.length,
        itemBuilder: (context, index) {
          final hospital = hospitalLogs[index];

          // null 체크를 추가하여 각 항목을 안전하게 출력
          String name = hospital['hname'] ?? '이름 없음';
          String lat = hospital['llat']?.toString() ?? '정보 없음';
          String long = hospital['llong']?.toString() ?? '정보 없음';
          String phone = hospital['phone'] ?? '전화번호 없음';
          String createAt = hospital['create_at'] != null
              ? hospital['create_at'].toString().split("T")[0]
              : '등록일 없음';

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.local_hospital, color: Colors.red),
              title: Text(name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('위도: $lat / 경도: $long'),
                  Text('전화번호: $phone'),
                  Text('등록일: $createAt'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
