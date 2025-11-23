import 'api_client.dart';

class ScanRepository {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> saveScan({
    required double bpm,
    required double movement,
    required double energyScore,
    required String auraColor,
  }) async {
    try {
      final res = await _api.dio.post('/scan/save', data: {
        'bpm': bpm,
        'movement': movement,
        'energyScore': energyScore,
        'auraColor': auraColor,
      });
      return {'ok': true, 'data': res.data};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> history() async {
    try {
      final res = await _api.dio.get('/scan/history');
      return {'ok': true, 'data': res.data};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }
}


