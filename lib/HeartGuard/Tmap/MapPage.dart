// import 'package:flutter/material.dart';
// import 'package:tmap_ui_sdk/tmap_ui_sdk.dart'; // Tmap UI SDK
//
// class MapPage extends StatefulWidget {
//   @override
//   _MapPageState createState() => _MapPageState();
// }
//
// class _MapPageState extends State<MapPage> {
//   late TmapViewController _controller; // TmapController 선언
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Tmap 지도 예시")),
//       body: TmapView(
//         initialPosition: TmapLatLng(37.5665, 126.9780), // 서울의 위도, 경도 (서울 시청 근처)
//         zoomLevel: 13, // 초기 줌 레벨
//         onMapCreated: (controller) {
//           _controller = controller;
//
//           // 서울에 핀을 찍기 위한 마커 추가
//           _controller.addMarker(
//             TmapMarker(
//               position: TmapLatLng(37.5665, 126.9780), // 서울의 위도, 경도
//               title: '서울',
//               snippet: '서울 시청',
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
