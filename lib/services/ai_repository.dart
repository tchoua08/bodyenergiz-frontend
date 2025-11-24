import 'package:dio/dio.dart';
import 'api_client.dart';

class AiRepository {
  final ApiClient _api = ApiClient();

  // ----------------------------------------------------------
  // 🔮 GÉNÉRATION DE CONSEIL IA (texte)
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> generateAdvice({
    required String aura,
    required double energyScore,
    required double bpm,
  }) async {
    try {
      final res = await _api.dio.post(
        "/ai/advice",
        data: {
          "aura": aura,
          "energyScore": energyScore,
          "bpm": bpm,
        },
      );

      return {"ok": true, "data": res.data};
    } on DioError catch (e) {
      return {
        "ok": false,
        "error": e.response?.data["error"] ?? e.message
      };
    }
  }

  // ----------------------------------------------------------
  // 🎵 GÉNÉRATION DE L’AUDIO PREMIUM PLUS
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> generateAdviceAudio({
    required String aura,
    required double energyScore,
    required double bpm,
  }) async {
    try {
      final res = await _api.dio.post(
        "/ai/advice-audio",
        data: {
          "aura": aura,
          "energyScore": energyScore,
          "bpm": bpm,
        },
      );

      return {"ok": true, "data": res.data};
    } on DioError catch (e) {
      return {
        "ok": false,
        "error": e.response?.data["error"] ?? e.message
      };
    }
  }

  // ----------------------------------------------------------
  // 🌀 GÉNÉRATION ANIMATION AURA PREMIUM PLUS (OPTION)
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> generateAuraAnimation(String aura) async {
    try {
      final res = await _api.dio.post(
        "/ai/aura-animation",
        data: {"aura": aura},
      );

      return {"ok": true, "data": res.data};
    } on DioError catch (e) {
      return {
        "ok": false,
        "error": e.response?.data["error"] ?? e.message
      };
    }
  }
}


