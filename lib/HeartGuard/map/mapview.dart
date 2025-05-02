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
  NLatLng? _currentPosition;
  NMarker? _currentMarker;

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
        desiredAccuracy: LocationAccuracy.high, // 좌표 가져오기
      );

      setState(() {
        _currentPosition = NLatLng(pos.latitude, pos.longitude); // 위도 경도
      });

      // 비동기 필수



      if (_mapController != null && _currentPosition != null) {
        _mapController!.updateCamera(
          NCameraUpdate.scrollAndZoomTo(
            target: _currentPosition!,
            zoom: 15,
          ),
        );
        // 처음 한 번만 마커 생성
        if (_currentMarker == null) {
          final marker = NMarker(
            id: 'current_location_marker',
            position: _currentPosition!,
          );
          _currentMarker = marker;
          _mapController.addOverlay(marker);
        }
      }
    } catch (e) {
      print('위치 가져오기 실패: $e');
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
                _mapController!.updateCamera(
                  NCameraUpdate.scrollAndZoomTo(
                    target: _currentPosition!,
                    zoom: 15,
                  ),
                );
              }
            },
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white, // 배경색
              foregroundColor: Color(0xFFfd4b85),  // 아이콘 색
              elevation: 6,
              mini: true,
              child: Icon(
                Icons.my_location,
                size: 30,
              ),
              tooltip: '현재 위치로 이동',
            ),
          )
        ],
      ),
    );
  }
}
