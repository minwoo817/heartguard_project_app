import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';

class MapView extends StatefulWidget {
  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late NaverMapController _mapController;
  NLatLng? _currentPosition; // GPS 위치
  NMarker? _currentMarker; // GPS 위치 마커
  final dio = Dio();
  final Map<String, Map<String, dynamic>> _markerInfoMap = {};
  String? _selectedMarkerId; // 선택된 마커 ID

  @override
  void initState() {
    super.initState();
    _requestLocationPermission(); // 권한 요청
    getHospital(); // 지도 로드시 병원 데이터 불러오기
    //getAed(); // AED 데이터 불러오기
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else if (status.isDenied) {
      print('위치 권한이 거부됨');
    } else if (status.isPermanentlyDenied) {
      openAppSettings(); // 설정 화면으로 이동
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = NLatLng(pos.latitude, pos.longitude);
      });

      if (_mapController != null && _currentPosition != null) {
        _mapController.updateCamera(
          NCameraUpdate.scrollAndZoomTo(
            target: _currentPosition!,
            zoom: 15,
          ),
        );

        // GPS 위치 마커만 처음 한 번만 생성
        if (_currentMarker == null && _currentPosition != null) {
          final marker = NMarker(
            id: 'current_location_marker',
            position: _currentPosition!,
            // 기본 마커는 아이콘 없이도 자동으로 생성됨
          );
          _currentMarker = marker;
          _mapController.addOverlay(marker);
        }
      }
    } catch (e) {
      print('위치 가져오기 실패: $e');
    }
  }

  void getHospital() async {
    try {
      final response = await dio.get("http://192.168.40.45:8080/map/gethospital");
      print("[getHospital] 응답 수신 완료");

      final List<dynamic> hospitalList = response.data;

      for (var hospital in hospitalList) {
        final marker = NMarker(
          id: 'hospital_${hospital["hno"]}',
          position: NLatLng(hospital["hlat"], hospital["hlong"]),
          icon: await NOverlayImage.fromAssetImage('assets/images/h_marker.png'),
        );

        _mapController.addOverlay(marker);

        // 마커 클릭 시 정보창 표시
        marker.setOnTapListener((NMarker tappedMarker) {
          // setState(() {
          //   _selectedMarkerId = tappedMarker.id; // 클릭한 마커 ID를 저장
          // });
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              padding: EdgeInsets.all(16),
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("종류: ${hospital["type"]}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text("병원명: ${hospital["name"]}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text("응급 연락처: ${hospital["emgTel"]}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text("주소: ${hospital["address"]}", style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          );
        });
      }
    } catch (e) {
      print("[getHospital] 오류 발생: $e");
    }
  }

  // void getAed() async {
  //   try {
  //     final response = await dio.get("http://192.168.40.45:8080/heart/api1");
  //     print("[getAed] AED 데이터 응답 수신 완료");
  //
  //     final List<dynamic> aedList = response.data;
  //
  //     // AED 리스트가 제대로 넘어왔는지 확인
  //     print("[getAed] 데이터 개수: ${aedList.length}");
  //
  //     for (var aed in aedList) {
  //       final double? lat = double.tryParse(aed["wgs84Lat"] ?? '');
  //       final double? lon = double.tryParse(aed["wgs84Lon"] ?? '');
  //
  //       if (lat == null || lon == null) {
  //         print("[getAed] 유효하지 않은 좌표: $lat, $lon");
  //         continue;
  //       }
  //
  //       for (int i = 0; i < aedList.length; i++) {
  //         final aed = aedList[i];
  //         final double? lat = double.tryParse(aed["wgs84Lat"] ?? '');
  //         final double? lon = double.tryParse(aed["wgs84Lon"] ?? '');
  //
  //         if (lat == null || lon == null) continue;
  //
  //         final markerId = 'aed_$i'; // 인덱스를 ID로 사용
  //
  //
  //         //print("[getAed] 추가할 마커 ID: $markerId");
  //
  //         final marker = NMarker(
  //           id: markerId, // 마커 고유 ID
  //           position: NLatLng(lat, lon),
  //           icon: await NOverlayImage.fromAssetImage(
  //               'assets/images/aed_marker.png'),
  //         );
  //
  //         // // 마커가 정상적으로 추가되었는지 확인
  //         // print("[getAed] 마커 추가됨: $markerId");
  //
  //         _mapController.addOverlay(marker);
  //
  //         // 마커 클릭 리스너 추가
  //         marker.setOnTapListener((NMarker tappedMarker) {
  //           print("[getAed] 마커 클릭됨: $markerId");
  //           showModalBottomSheet(
  //             context: context,
  //             builder: (context) =>
  //                 Container(
  //                   padding: EdgeInsets.all(16),
  //                   height: 200,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text("설치 장소: ${aed["buildPlace"]}",
  //                           style: TextStyle(fontSize: 18)),
  //                       SizedBox(height: 8),
  //                       Text("관리 기관: ${aed["org"]}",
  //                           style: TextStyle(fontSize: 16)),
  //                       SizedBox(height: 8),
  //                       Text("관리자 연락처: ${aed["clerkTel"]}",
  //                           style: TextStyle(fontSize: 16)),
  //                     ],
  //                   ),
  //                 ),
  //           );
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     print("[getAed] 오류 발생: $e");
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    final selectedInfo = _selectedMarkerId != null ? _markerInfoMap[_selectedMarkerId!] : null;

    return Scaffold(
      appBar: MyAppBar(),
      body: Stack(
        children: [
          NaverMap(
            onMapReady: (controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                _mapController.updateCamera(
                  NCameraUpdate.scrollAndZoomTo(
                    target: _currentPosition!,
                    zoom: 15,
                  ),
                );
              }
              getHospital();
              //getAed();
            },
          ),
          if (selectedInfo != null)
            Positioned.fill( // 전체 화면 덮기
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center( // 이게 핵심! 진짜 화면 가운데 정렬
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("병원 정보", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text("종류: ${selectedInfo['type']}"),
                        Text("이름: ${selectedInfo['name']}"),
                        Text("응급전화: ${selectedInfo['emgTel']}"),
                        Text("주소: ${selectedInfo['address']}"),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedMarkerId = null;
                            });
                          },
                          child: Text("닫기"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // 신고하기 버튼
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, "/report"),
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFFF0000),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "신고하기",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF08da76),
              elevation: 6,
              mini: true,
              child: Icon(Icons.my_location, size: 30),
              tooltip: '현재 위치로 이동',
            ),
          ),
        ],
      ),
    );
  }
}
