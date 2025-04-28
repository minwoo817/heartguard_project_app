import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:url_launcher/url_launcher.dart';

class MainApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainAppState();
  }
}

class _MainAppState extends State<MainApp> {
  NaverMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HeartGuard | AED 및 응급실 위치'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: NaverMap(
              options: const NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(37.5666805, 126.9784147), // 서울 시청 좌표
                  zoom: 14,
                ),
              ),
              onMapReady: (controller) {
                setState(() {
                  _mapController = controller;
                });
                // 지도 로드 완료 후 마커 등을 추가할 수 있음
                _addSampleMarkers();
              },
            ),
          ),
          // 하단 메뉴 또는 정보 표시 영역 (필요시)
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.local_hospital),
                  label: Text('AED 위치'),
                  onPressed: () {
                    // AED 마커만 표시하는 기능
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.emergency),
                  label: Text('응급실'),
                  onPressed: () {
                    // 응급실 마커만 표시하는 기능
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 샘플 마커 추가 (테스트용)
  void _addSampleMarkers() {
    // AED 샘플 마커
    final aedMarker = NMarker(
      id: 'aed_1',
      position: NLatLng(37.564, 126.975),
    );
    aedMarker.setCaption(NOverlayCaption(text: 'AED 1'));

    // 응급실 샘플 마커
    final hospitalMarker = NMarker(
      id: 'hospital_1',
      position: NLatLng(37.570, 126.980),
    );
    hospitalMarker.setCaption(NOverlayCaption(text: '서울대병원'));

    // 마커 클릭 이벤트 설정
    aedMarker.setOnTapListener((marker) {
      _onMarkerTap(marker);
    });

    hospitalMarker.setOnTapListener((marker) {
      _onMarkerTap(marker);
    });

    // 마커 추가
    _mapController?.addOverlay(aedMarker);
    _mapController?.addOverlay(hospitalMarker);
  }

  // 마커 클릭 이벤트 처리
  void _onMarkerTap(NMarker marker) {
    // 추가 정보 표시 또는 다이얼로그 등을 여기서 구현
    _showLocationDetail(marker.info.id);
  }

  // 위치 상세 정보 표시
  void _showLocationDetail(String markerId) {
    // 마커 ID 기반으로 상세 정보 표시
    // 실제 구현 시에는 데이터베이스에서 해당 ID의 정보를 조회

    String title = markerId.startsWith('aed') ? 'AED 정보' : '응급실 정보';
    String detail = markerId.startsWith('aed')
        ? '위치: xx빌딩 1층\n이용시간: 24시간\n상태: 정상'
        : '병원명: 서울대병원\n전화: 02-2072-2473\n운영시간: 24시간';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(detail),
            SizedBox(height: 16),
            // 내비게이션 버튼
            ElevatedButton.icon(
              icon: Icon(Icons.directions),
              label: Text('길 안내'),
              onPressed: () {
                // 티맵 또는 다른 내비게이션 앱으로 연결
                _launchNavigation(markerId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기'),
          ),
        ],
      ),
    );
  }

  // 내비게이션 앱 실행 (티맵 예시)
  void _launchNavigation(String markerId) async {
    // 실제 구현 시에는 마커 ID에 해당하는 위도/경도 정보를 가져옴
    double lat = 37.564;
    double lng = 126.975;
    String name = markerId.startsWith('aed') ? 'AED 위치' : '서울대병원';

    // 티맵 URL 스킴
    final tmapScheme = 'tmap://route?goalname=$name&goalx=$lng&goaly=$lat';
    final uri = Uri.parse(tmapScheme);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // 티맵이 설치되어 있지 않은 경우
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('알림'),
            content: Text('티맵 앱이 설치되어 있지 않습니다. 앱 스토어로 이동하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  final appStoreLink = Theme.of(context).platform == TargetPlatform.iOS
                      ? 'https://apps.apple.com/kr/app/티맵/id431589174'
                      : 'market://details?id=com.skt.tmap.ku';
                  await launchUrl(Uri.parse(appStoreLink));
                  if (mounted) Navigator.pop(context);
                },
                child: Text('이동'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Failed to launch Tmap: $e');
    }
  }
}