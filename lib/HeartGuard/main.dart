import 'package:flutter/cupertino.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:heartguard_project_app/HeartGuard/layout/myapp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 네이버 맵 초기화
  await NaverMapSdk.instance.initialize(
      clientId: 'fo1nlo8f10', // 클라이언트 ID
      onAuthFailed: (error) {
        print('네이버 지도 인증 실패: $error');
      }
  );

  runApp(MyApp());
}