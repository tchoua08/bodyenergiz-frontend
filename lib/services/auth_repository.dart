import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthRepository {
  final ApiClient _api = ApiClient();

  // ----------------------------------------------------------
  // Save tokens to secure storage
  // ----------------------------------------------------------
  Future<void> _saveTokens(String? token, String? refreshToken) async {
    if (token != null) {
      await _api.storage.write(key: "jwt_token", value: token);
    }
    if (refreshToken != null) {
      await _api.storage.write(key: "refresh_token", value: refreshToken);
    }
  }

  // ----------------------------------------------------------
  // REGISTER
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final res = await _api.dio.post(
        "/auth/register",
        data: {
          "name": name,
          "email": email,
          "password": password,
        },
      );

      return {"ok": true, "data": res.data};
    } on DioException catch (e) {
      return {
        "ok": false,
        "error": e.response?.data["message"] ??
            e.response?.data ??
            e.message ??
            "Erreur inconnue"
      };
    }
  }

  // ----------------------------------------------------------
  // LOGIN
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _api.dio.post(
        "/auth/login",
        data: {
          "email": email,
          "password": password,
        },
      );

      final data = res.data;
      final token = data["token"];
      final refreshToken = data["refreshToken"];

      await _saveTokens(token, refreshToken);

      return {"ok": true, "data": data};
    } on DioException catch (e) {
      return {
        "ok": false,
        "error": e.response?.data["message"] ?? e.message
      };
    }
  }

  // ----------------------------------------------------------
  // GET AUTHENTICATED USER
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> getMe() async {
    try {
      final res = await _api.dio.get("/auth/me");

      return {"ok": true, "data": res.data};
    } on DioException catch (e) {
      return {
        "ok": false,
        "error": e.response?.data ?? e.message
      };
    }
  }

  // ----------------------------------------------------------
  // FORGOT PASSWORD (email link)
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final res = await _api.dio.post(
        "/auth/forgot-password",
        data: {"email": email},
      );

      return {"ok": true, "data": res.data};
    } on DioException catch (e) {
      return {
        "ok": false,
        "error": e.response?.data["message"] ??
            e.message ??
            "Erreur inconnue"
      };
    }
  }

  // ----------------------------------------------------------
  // RESET PASSWORD (authenticated user)
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> resetPassword(String newPassword) async {
    try {
      final res = await _api.dio.post(
        "/auth/reset-password",
        data: {"password": newPassword},
      );

      return {"ok": true, "data": res.data};
    } on DioException catch (e) {
      return {"ok": false, "error": e.response?.data ?? e.message};
    }
  }

  // ----------------------------------------------------------
  // RESET PASSWORD via token (forgot link)
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> resetPasswordWithToken(
      String token, String newPassword) async {
    try {
      final res = await _api.dio.post(
        "/auth/reset-password/$token",
        data: {"password": newPassword},
      );

      return {"ok": true, "data": res.data};
    } on DioException catch (e) {
      return {
        "ok": false,
        "error": e.response?.data["message"] ?? e.message
      };
    }
  }

  // ----------------------------------------------------------
  // CHANGE PASSWORD (user authenticated)
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    try {
      final res = await _api.dio.put(
        "/user/change-password",
        data: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        },
      );

      return {"ok": true, "data": res.data};
    } on DioException catch (e) {
      return {
        "ok": false,
        "error": e.response?.data["message"] ?? e.message
      };
    }
  }

  // ----------------------------------------------------------
  // UPLOAD PHOTO (avatar)
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    try {
      final form = FormData.fromMap({
        "avatar": await MultipartFile.fromFile(filePath),
      });

      final res = await _api.dio.post(
        "/user/upload-avatar",
        data: form,
      );

      return {"ok": true, "data": res.data};
    } on DioException catch (e) {
      return {"ok": false, "error": e.response?.data ?? e.message};
    }
  }

  // ----------------------------------------------------------
  // UPDATE PROFILE (name and photo)
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> updateProfile(
      {String? name, String? photoUrl}) async {
    try {
      final res = await _api.dio.put(
        "/user/update",
        data: {
          if (name != null) "name": name,
          if (photoUrl != null) "photoUrl": photoUrl,
        },
      );

      return {"ok": true, "data": res.data};
    } on DioException catch (e) {
      return {"ok": false, "error": e.response?.data ?? e.message};
    }
  }

  // ----------------------------------------------------------
  // REFRESH TOKEN
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> refresh() async {
    try {
      final rt = await _api.storage.read(key: "refresh_token");
      if (rt == null) {
        return {"ok": false, "error": "No refresh token"};
      }

      final res = await _api.dio.post(
        "/auth/refresh",
        data: {"refreshToken": rt},
      );

      final token = res.data["token"];
      final newRefresh = res.data["refreshToken"];

      await _saveTokens(token, newRefresh);

      return {"ok": true, "data": res.data};
    } on DioException catch (e) {
      return {"ok": false, "error": e.response?.data ?? e.message};
    }
  }

  // ----------------------------------------------------------
  // LOGOUT
  // ----------------------------------------------------------
  Future<void> logout() async {
    try {
      final rt = await _api.storage.read(key: "refresh_token");

      if (rt != null) {
        await _api.dio.post("/auth/logout", data: {"refreshToken": rt});
      }
    } catch (_) {}

    await _api.storage.delete(key: "jwt_token");
    await _api.storage.delete(key: "refresh_token");
  }

  // ----------------------------------------------------------
  // CLEAR ALL TOKENS
  // ----------------------------------------------------------
  Future<void> clearStorage() async {
    await _api.storage.deleteAll();
  }

  // ----------------------------------------------------------
// GET SUBSCRIPTION STATUS
// ----------------------------------------------------------
Future<Map<String, dynamic>> getSubscriptionStatus() async {
  try {
    final res = await _api.dio.get("/subscription/status");
    return {"ok": true, "data": res.data};
  } on DioException catch (e) {
    return {"ok": false, "error": e.response?.data ?? e.message};
  }
}

// ----------------------------------------------------------
// CREATE CHECKOUT SESSION (Stripe)
// ----------------------------------------------------------
Future<Map<String, dynamic>> createCheckoutSession({
  required String plan,
}) async {
  try {
    final res = await _api.dio.post(
      "/subscription/checkout",
      data: {"plan": plan}, // premium | premium_plus
    );

    return {"ok": true, "data": res.data};
  } on DioException catch (e) {
    return {"ok": false, "error": e.response?.data ?? e.message};
  }
}

// ----------------------------------------------------------
// CANCEL SUBSCRIPTION
// ----------------------------------------------------------
Future<Map<String, dynamic>> cancelSubscription() async {
  try {
    final res = await _api.dio.post("/subscription/cancel");
    return {"ok": true, "data": res.data};
  } on DioException catch (e) {
    return {"ok": false, "error": e.response?.data ?? e.message};
  }
}



}


