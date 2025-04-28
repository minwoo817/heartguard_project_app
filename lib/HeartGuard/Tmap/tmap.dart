import 'package:flutter/material.dart';
import 'package:dio/dio.dart';  // Dio 패키지 사용
import 'tmap_api.dart';  // tmap_api.dart 임포트

class MyMapPage extends StatefulWidget {
  @override
  _MyMapPageState createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
  final TmapApi tmapApi = TmapApi();  // TmapApi 인스턴스 생성

  @override
  void initState() {
    super.initState();
    _fetchLocation();  // 위치 정보 가져오기
  }

  // 위치 정보 가져오는 함수
  Future<void> _fetchLocation() async {
    double latitude = 37.5665;  // 서울 위도
    double longitude = 126.9780;  // 서울 경도
    try {
      var response = await tmapApi.getLocation(latitude, longitude);
      print(response.data);  // 응답 데이터 출력
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tmap 지도 예시")),
      body: Center(child: Text("위치 정보 로딩 중...")),
    );
  }
}
