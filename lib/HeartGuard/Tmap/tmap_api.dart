import 'package:dio/dio.dart';

class TmapApi {
  final String _baseUrl = 'https://api2.sktelecom.com/tmap';
  final Dio _dio = Dio();
  final String apiKey = 'YOUR_TMAP_API_KEY';  // API 키

  // 위치 정보 가져오기 예시 (AED 위치 등)
  Future<Response> getLocation(double latitude, double longitude) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/locations',  // Tmap API의 실제 URL로 변경해야 함
        queryParameters: {
          'version': '1',
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'apiKey': apiKey,
        },
      );
      return response;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
