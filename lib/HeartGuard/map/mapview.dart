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
      openAppSettings(); // 설정 화면
    }
  }

  Future<void> _getCurrentLocation() async {
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
      // 마커
      final marker = NMarker(
        id: 'current_location_marker',
        position: _currentPosition!,
      );

      _mapController.addOverlay(marker);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: NaverMap(
        onMapReady: (controller) {
          _mapController = controller;
          if (_mapController != null && _currentPosition != null) {
            _mapController.updateCamera(
              NCameraUpdate.scrollAndZoomTo(
                target: _currentPosition!,
                zoom: 15,
              ),
            );
          }
        },
      ),
    );
  }
}
