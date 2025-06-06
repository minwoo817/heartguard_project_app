import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myappbar.dart';
import 'package:url_launcher/url_launcher.dart';

class MapView extends StatefulWidget {
  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  NaverMapController? _mapController;
  NLatLng? _currentPosition; // GPS 위치
  NMarker? _currentMarker; // GPS 위치 마커
  final dio = Dio();

  // 모든 병원/AED 데이터를 저장
  List<Map<String, dynamic>> _allHospitals = [];
  List<Map<String, dynamic>> _allAeds = [];

  // 현재 화면에 표시된 마커들
  final Map<String, NMarker> _visibleMarkers = {};
  bool _isUpdatingMarkers = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  // 권한 요청
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

  // GPS
  Future<void> _getCurrentLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = NLatLng(pos.latitude, pos.longitude);
      });

      if (_currentPosition != null && _mapController != null) {
        _mapController!.updateCamera(
          NCameraUpdate.scrollAndZoomTo(
            target: _currentPosition!,
            zoom: 15,
          ),
        );

        // GPS 위치 마커만 처음 한 번만 생성
        if (_currentMarker == null) {
          final marker = NMarker(
            id: 'current_location_marker',
            position: _currentPosition!,
          );
          _currentMarker = marker;
          _mapController!.addOverlay(marker);
        } else {
          // 기존 마커 삭제하고 새로 생성
          try {
            if (_mapController != null) {
              await _mapController!.deleteOverlay(
                  NOverlayInfo(type: NOverlayType.marker, id: 'current_location_marker')
              );
            }
          } catch (e) {
            print("기존 위치 마커 삭제 중 오류: $e");
          }

          final marker = NMarker(
            id: 'current_location_marker',
            position: _currentPosition!,
          );
          _currentMarker = marker;
          if (_mapController != null) {
            _mapController!.addOverlay(marker);
          }
        }
      }
    } catch (e) {
      print('위치 가져오기 실패: $e');
    }
  }

  // 병원 데이터를 가져와서 저장 (한 번만 실행)
  Future<void> _loadHospitalData() async {
    try {
      final response = await dio.get("http://192.168.40.45:8080/map/gethospital");

      if (response.data is List) {
        _allHospitals = List<Map<String, dynamic>>.from(response.data);
      } else if (response.data is Map) {
        _allHospitals = [Map<String, dynamic>.from(response.data)];
      } else {
        print("[_loadHospitalData] 오류 : ${response.data.runtimeType}");
        _allHospitals = [];
      }
    } catch (e) {
      print("[_loadHospitalData] 오류 발생: $e");
      _allHospitals = [];
    }
  }

  // AED 데이터를 가져와서 저장 (한 번만 실행)
  Future<void> _loadAedData() async {
    try {
      final response = await dio.get("http://192.168.40.45:8080/heart/api1");
      _allAeds = List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print("[_loadAedData] 오류 발생: $e");
    }
  }

  // 현재 화면 범위 내의 마커만 표시
  Future<void> _updateMarkersBasedOnViewport() async {
    if (_mapController == null || _isUpdatingMarkers) return;

    _isUpdatingMarkers = true;

    try {
      // 현재 화면 범위 가져오기
      final bounds = await _mapController!.getContentBounds();
      final centerPosition = await _mapController!.getCameraPosition();

      // 화면 크기의 70% 영역 계산
      final latitudeDelta = (bounds.northEast.latitude - bounds.southWest.latitude) * 0.7;
      final longitudeDelta = (bounds.northEast.longitude - bounds.southWest.longitude) * 0.7;

      final viewportBounds = NLatLngBounds(
        southWest: NLatLng(
          centerPosition.target.latitude - latitudeDelta / 2,
          centerPosition.target.longitude - longitudeDelta / 2,
        ),
        northEast: NLatLng(
          centerPosition.target.latitude + latitudeDelta / 2,
          centerPosition.target.longitude + longitudeDelta / 2,
        ),
      );

      // 새로운 마커 집합
      final Map<String, NMarker> newVisibleMarkers = {};

      // 화면 범위 내의 병원 마커 확인 및 추가
      int hospitalCount = 0;
      int hospitalInBounds = 0;
      int hospitalMarkerAdded = 0;

      for (int i = 0; i < _allHospitals.length; i++) {
        try {
          final hospital = _allHospitals[i];

          // 다양한 데이터 타입에 대한 처리
          final dynamic hlatValue = hospital["hlat"];
          final dynamic hlongValue = hospital["hlong"];

          double lat;
          double lon;

          if (hlatValue is double) {
            lat = hlatValue;
          } else if (hlatValue is String) {
            lat = double.parse(hlatValue);
          } else if (hlatValue is num) {
            lat = hlatValue.toDouble();
          } else {
            if (i < 2) print("위도 파싱 실패: $hlatValue (${hlatValue.runtimeType})");
            continue;
          }

          if (hlongValue is double) {
            lon = hlongValue;
          } else if (hlongValue is String) {
            lon = double.parse(hlongValue);
          } else if (hlongValue is num) {
            lon = hlongValue.toDouble();
          } else {
            if (i < 2) print("경도 파싱 실패: $hlongValue (${hlongValue.runtimeType})");
            continue;
          }

          final position = NLatLng(lat, lon);
          hospitalCount++;

          bool isInBounds = _isPositionInBounds(position, viewportBounds);

          if (isInBounds) {
            hospitalInBounds++;
            final markerId = 'hospital_${hospital["hno"]}';
            if (i < 2) print("마커 ID: $markerId");

            if (_visibleMarkers.containsKey(markerId)) {
              if (i < 2) print("기존 마커 재사용");
              newVisibleMarkers[markerId] = _visibleMarkers[markerId]!;
            } else {
              if (i < 2) print("새 마커 생성");
              // 새 마커 생성
              final marker = NMarker(
                id: markerId,
                position: position,
                icon: await NOverlayImage.fromAssetImage('assets/images/h_marker2.png'),
              );

              if (_mapController != null) {
                _mapController!.addOverlay(marker);
              }
              newVisibleMarkers[markerId] = marker;
              hospitalMarkerAdded++;

              // 마커 클릭 리스너 설정
              marker.setOnTapListener((NMarker tappedMarker) {
                _showHospitalDialog(hospital);
              });
              if (i < 2) print("마커 생성 완료");
            }
          }

        } catch (e) {
          print("병원 $i 처리 중 오류: $e");
          print("문제 병원 데이터: ${_allHospitals[i]}");
        }
      }

      // 화면 범위 내의 AED 마커 확인 및 추가
      for (int i = 0; i < _allAeds.length; i++) {
        final aed = _allAeds[i];
        final double? lat = double.tryParse(aed["wgs84Lat"]?.toString() ?? '');
        final double? lon = double.tryParse(aed["wgs84Lon"]?.toString() ?? '');

        if (lat == null || lon == null) continue;

        final position = NLatLng(lat, lon);

        if (_isPositionInBounds(position, viewportBounds)) {
          final markerId = 'aed_$i';

          if (_visibleMarkers.containsKey(markerId)) {
            // 이미 있는 마커는 재사용
            newVisibleMarkers[markerId] = _visibleMarkers[markerId]!;
          } else {
            // 새 마커 생성
            final marker = NMarker(
              id: markerId,
              position: position,
              icon: await NOverlayImage.fromAssetImage('assets/images/aed_marker2.png'),
            );

            if (_mapController != null) {
              _mapController!.addOverlay(marker);
            }
            newVisibleMarkers[markerId] = marker;

            // 마커 클릭 리스너 설정
            marker.setOnTapListener((NMarker tappedMarker) {
              _showAedDialog(aed);
            });
          }
        }
      }

      // 더 이상 보이지 않는 마커 제거
      for (final entry in _visibleMarkers.entries) {
        if (!newVisibleMarkers.containsKey(entry.key) &&
            !entry.key.startsWith('current_location_marker')) {
          try {
            if (_mapController != null) {
              await _mapController!.deleteOverlay(NOverlayInfo(type: NOverlayType.marker, id: entry.key));
            }
          } catch (e) {
            print("마커 삭제 중 오류 발생 (${entry.key}): $e");
          }
        }
      }

      // 현재 마커를 GPS 마커와 함께 저장
      if (_currentMarker != null) {
        newVisibleMarkers['current_location_marker'] = _currentMarker!;
      }

      _visibleMarkers.clear();
      _visibleMarkers.addAll(newVisibleMarkers);

    } catch (e) {
      print("마커 업데이트 중 오류 발생: $e");
    } finally {
      _isUpdatingMarkers = false;
    }
  }

  // 위치가 범위 내에 있는지 확인
  bool _isPositionInBounds(NLatLng position, NLatLngBounds bounds) {
    return position.latitude >= bounds.southWest.latitude &&
        position.latitude <= bounds.northEast.latitude &&
        position.longitude >= bounds.southWest.longitude &&
        position.longitude <= bounds.northEast.longitude;
  }

  // 병원 정보 중앙 다이얼로그 표시
  void _showHospitalDialog(Map<String, dynamic> hospital) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "병원 정보",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              Divider(height: 40, thickness: 1),
              SizedBox(height: 10),
              _buildInfoRow("🏥 종류", hospital["type"]),
              SizedBox(height: 10),
              _buildInfoRow("🏣 병원명", hospital["name"], maxLines: 2),
              SizedBox(height: 10),
              _buildInfoRow("📞 연락처", hospital["emgTel"]),
              SizedBox(height: 10),
              _buildInfoRow("📍 주소", hospital["address"], maxLines: 3),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 9),
                  ElevatedButton(
                    onPressed: () {
                      // 전화 걸기 기능
                      final phoneNumber = hospital["emgTel"];
                      if (phoneNumber != null && phoneNumber != '정보 없음') {
                        final url = 'tel:$phoneNumber';
                        launchUrl(Uri.parse(url));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFfd4b85),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("전화 연결"),
                  ),
                  SizedBox(width: 9),
                  ElevatedButton(
                    onPressed: () {
                      _openNaverMap(hospital["hlat"], hospital["hlong"], hospital["name"]);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("경로 안내"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // AED 정보 중앙 다이얼로그 표시
  void _showAedDialog(Map<String, dynamic> aed) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, // Dialog 자체는 투명하게
        child: Material(
          color: Colors.white, // 흰색 배경
          borderRadius: BorderRadius.circular(20), // 둥근 테두리
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "AED 정보",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFfd4b85),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                Divider(height: 40, thickness: 1),
                SizedBox(height: 10),
                _buildInfoRow("🏢 관리기관", aed["org"] ?? '정보 없음', maxLines: 2),
                SizedBox(height: 10),
                _buildInfoRow("📍 설치장소", aed["buildPlace"] ?? '정보 없음', maxLines: 2),
                SizedBox(height: 10),
                _buildInfoRow("📞 연락처", aed["clerkTel"] ?? '정보 없음'),
                if (aed["buildAddress"] != null) ...[
                  SizedBox(height: 10),
                  _buildInfoRow("🗺️ 주소", aed["buildAddress"], maxLines: 3),
                ],
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // 전화 걸기 기능
                        final phoneNumber = aed["clerkTel"];
                        if (phoneNumber != null && phoneNumber != '정보 없음') {
                          final url = 'tel:$phoneNumber';
                          launchUrl(Uri.parse(url));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFfd4b85),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("전화 연결"),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final double? lat = double.tryParse(aed["wgs84Lat"]?.toString() ?? '');
                        final double? lon = double.tryParse(aed["wgs84Lon"]?.toString() ?? '');
                        if (lat != null && lon != null) {
                          _openNaverMap(lat, lon, aed["buildPlace"] ?? 'AED 위치');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("경로 안내"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  // 정보 행을 위한 위젯
  Widget _buildInfoRow(String label, String? value, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value ?? '정보 없음',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }



  // 네이버 지도 앱 열기 (자동차 경로 표시)
  void _openNaverMap(double lat, double lon, String name) async {
    double fixedLat = _currentPosition!.latitude;
    double fixedLon = _currentPosition!.longitude;
    const String fixedLocationName = "더조은아카데미";
    try {
      final url = 'nmap://route/car?'
          'slat=$fixedLat&slng=$fixedLon&sname=${Uri.encodeComponent(fixedLocationName)}'
          '&dlat=$lat&dlng=$lon&dname=${Uri.encodeComponent(name)}'
          '&appname=com.example.heartguard';
      bool canLaunchNmap = await canLaunchUrl(Uri.parse(url));
      if (canLaunchNmap) {
        bool launched = await launchUrl(Uri.parse(url),
            mode: LaunchMode.externalApplication);
        if (launched) return;
      }
      List<String> storeUrls = [
        'market://details?id=com.nhn.android.nmap',
        'https://play.google.com/store/apps/details?id=com.nhn.android.nmap',
        'market://search?q=naver+map',
      ];
      for (String storeUrl in storeUrls) {
        try {
          bool canLaunchStore = await canLaunchUrl(Uri.parse(storeUrl));
          if (canLaunchStore) {
            bool launched = await launchUrl(
              Uri.parse(storeUrl),
              mode: LaunchMode.externalApplication,
            );
          }
        } catch (e) {
          print('플레이 스토어 URL 오류 ($storeUrl): $e');
        }
      }
    } catch (e) {
      print('전체 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Stack(
        children: [
          NaverMap(
            onMapReady: (controller) async {
              _mapController = controller;

              // 데이터 로딩
              await _loadHospitalData();
              await _loadAedData();

              // 첫 화면 설정
              if (_currentPosition != null && _mapController != null) {
                await _mapController!.updateCamera(
                  NCameraUpdate.scrollAndZoomTo(
                    target: _currentPosition!,
                    zoom: 15,
                  ),
                );
              }

              // 초기 마커 업데이트
              await _updateMarkersBasedOnViewport();
            },
            onCameraChange: (position, reason) async {
              // 카메라 변경시 마커 업데이트 (딜레이 추가로 성능 최적화)
              // 너무 자주 호출되지 않도록 debounce 효과
              await Future.delayed(Duration(milliseconds: 300));
              _updateMarkersBasedOnViewport();
            },
            onCameraIdle: () {
              // 카메라 이동이 완전히 끝났을 때 마커 업데이트
              if (_mapController != null) {
                _updateMarkersBasedOnViewport();
              }
            }
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