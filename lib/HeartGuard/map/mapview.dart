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
  final Map<String, Map<String, dynamic>> _markerInfoMap = {};

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
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

  // AED 및 응급실 마커 추가
  void _addSampleMarkers() {
    final sampleData = [
      {
        'id': 'aed_bupyeong1',
        'type': 'AED',
        'name': '부평역 1번 출구 AED',
        'address': '인천 부평구 부평동',
        'lat': 37.48995,
        'lng': 126.72455,
        'image': 'assets/images/aed_marker.png', // AED 마커 이미지
      },
      {
        'id': 'aed_bupyeong2',
        'type': 'AED',
        'name': '부평 지하철역 AED',
        'address': '인천 부평구 부평동',
        'lat': 37.49100,
        'lng': 126.72500,
        'image': 'assets/images/aed_marker.png', // AED 마커 이미지
      },
      {
        'id': 'er_bupyeong1',
        'type': '응급실',
        'name': '부평병원 응급실',
        'address': '인천 부평구',
        'lat': 37.49150,
        'lng': 126.72600,
        'image': 'assets/images/h_marker.png', // 병원 마커 이미지
      },
    ];

    for (var item in sampleData) {
      final marker = NMarker(
        id: item['id'] as String,
        position: NLatLng(
          item['lat'] as double,
          item['lng'] as double,
        ),
        icon: NOverlayImage.fromAssetImage(item['image'] as String), // 마커에 이미지 추가
      );

      _markerInfoMap[item['id'] as String] = item;

      // 마커 클릭 시 상세정보 표시
      marker.setOnTapListener((NMarker tappedMarker) {
        final info = _markerInfoMap[tappedMarker.info.id]!;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // 크기 조정 가능
          builder: (context) => Container(
            height: 300, // 고정된 높이
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    info['name'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '종류: ${info['type']}',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '주소: ${info['address']}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      });

      _mapController.addOverlay(marker);
    }
  }

  @override
  Widget build(BuildContext context) {
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

              _addSampleMarkers(); // AED 및 응급실 마커 추가
            },
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
              child: Icon(
                Icons.my_location,
                size: 30,
              ),
              tooltip: '현재 위치로 이동',
            ),
          ),
        ],
      ),
    );
  }
}
