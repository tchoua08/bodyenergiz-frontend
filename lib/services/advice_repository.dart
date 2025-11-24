import 'package:dio/dio.dart';
import 'api_client.dart';

class AdviceRepository {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> saveAdvice(Map<String, dynamic> payload) async {
    try {
      final res = await _api.dio.post("/ai/save-advice", data: payload);
      return {"ok": true, "data": res.data};
    } on DioError catch (e) {
      return {"ok": false, "error": e.response?.data ?? e.message};
    }
  }

  Future<Map<String, dynamic>> getHistory() async {
    try {
      final res = await _api.dio.get("/ai/history");
      return {"ok": true, "data": res.data};
    } on DioError catch (e) {
      return {"ok": false, "error": e.response?.data ?? e.message};
    }
  }
}


