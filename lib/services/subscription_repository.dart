import 'package:dio/dio.dart';
import '../services/api_client.dart';

class SubscriptionRepository {
  final ApiClient _api = ApiClient();

  // ----------------------------------------------------------
  // CHECK SUBSCRIPTION STATUS (User.me() ↓)
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final res = await _api.dio.get("/subscription/status");
      return {"ok": true, "data": res.data};
    } on DioError catch (e) {
      return {
        "ok": false,
        "error": e.response?.data["message"] ?? e.message
      };
    }
  }

  // ----------------------------------------------------------
  // IS PREMIUM ?
  // ----------------------------------------------------------
  Future<bool> isPremium() async {
    final res = await getSubscriptionStatus();
    if (!res["ok"]) return false;

    return res["data"]["subscriptionLevel"] == "premium" ||
        res["data"]["subscriptionLevel"] == "premium_plus";
  }

  // ----------------------------------------------------------
  // IS PREMIUM PLUS ?
  // ----------------------------------------------------------
  Future<bool> isPremiumPlus() async {
    final res = await getSubscriptionStatus();
    if (!res["ok"]) return false;

    return res["data"]["subscriptionLevel"] == "premium_plus";
  }

  // ----------------------------------------------------------
  // SUBSCRIBE (premium OR premium_plus)
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> subscribe(String plan) async {
    try {
      final res = await _api.dio.post(
        "/subscription/subscribe",
        data: {"plan": plan}, // premium | premium_plus
      );

      return {"ok": true, "data": res.data};
    } on DioError catch (e) {
      return {
        "ok": false,
        "error": e.response?.data["message"] ?? e.message
      };
    }
  }

  // ----------------------------------------------------------
  // CANCEL SUBSCRIPTION
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> cancel() async {
    try {
      final res = await _api.dio.post("/subscription/cancel");

      return {"ok": true, "data": res.data};
    } on DioError catch (e) {
      return {"ok": false, "error": e.response?.data ?? e.message};
    }
  }
}


