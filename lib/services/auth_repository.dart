import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late Dio dio;
  final storage = const FlutterSecureStorage();

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://127.0.0.1:3000/api",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
      ),
    );

    // Attach token to every request
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) async {
        final token = await storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      }),
    );
  }
}

class AuthRepository {
  final ApiClient _api = ApiClient();

  // ----------------------------------------------------------
  // SAVE TOKENS
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
        data: {"name": name, "email": email, "password": password},
      );

      return {"ok": true, "data": res.data};
    } on DioError catch (e) {
      return {
        "ok": false,
        "error": e.response?.data["message"] ?? e.message,
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
        data: {"email": email, "password": password},
      );

      final data = res.data;
      await _saveTokens(data["token"], data["refreshToken"]);

      return {"ok": true, "data": data};
    } on DioError catch (e) {
      return {"ok": false, "error": e.response?.data["message"] ?? e.message};
    }
  }

  // ----------------------------------------------------------
  // GET USER DETAILS (from JWT)
  // ----------------------------------------------------------
  Future<dynamic> getMe() async {
    try {
      final res = await _api.dio.get("/auth/me");
      return res.data;
    } catch (e) {
      return null;
    }
  }
  // ----------------------------------------------------------
// FORGOT PASSWORD
// ----------------------------------------------------------
Future<Map<String, dynamic>> forgotPassword(String email) async {
  try {
    final res = await _api.dio.post(
      "/auth/forgot-password",
      data: {"email": email},
    );

    return {"ok": true, "data": res.data};
  } on DioError catch (e) {
    return {
      "ok": false,
      "error": e.response?.data["message"] ??
          e.message ??
          "Erreur inconnue",
    };
  }
}

 // ---------------------------------------------------------- 
 // Reset password via JWT (authenticated user) 
 // ---------------------------------------------------------- 
 Future<Map<String, dynamic>> resetPassword(String newPassword) async { 
   try { 
    final res = await _api.dio.post( 
      "/auth/reset-password",
       data: {"password": newPassword}, 
       ); 

    return {"ok": true, "data": res.data}; 
    } on DioError catch (e) { 
    return {"ok": false, "error": e.response?.data ?? e.message}; 
    } 
    
  }

  // ----------------------------------------------------------
  // CHANGE PASSWORD
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final res = await _api.dio.put(
        "/auth/change-password",
        data: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        },
      );

      return {"ok": true, "data": res.data};
    } on DioError catch (e) {
      return {
        "ok": false,
        "error": e.response?.data["message"] ?? e.message,
      };
    }
  }

  // ----------------------------------------------------------
  // UPLOAD AVATAR (multipart)
  // ----------------------------------------------------------
  Future<String?> uploadAvatar(File file) async {
    try {
      final token = await _api.storage.read(key: "jwt_token");
      if (token == null) return null;

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("http://127.0.0.1:3000/api/auth/upload-avatar"),
      );

      request.headers["Authorization"] = "Bearer $token";
      request.files.add(await http.MultipartFile.fromPath('avatar', file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);

      if (data["ok"] == true) {
        return data["url"];
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // ----------------------------------------------------------
  // UPDATE PROFILE (name, avatar)
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? avatar,
  }) async {
    try {
      final res = await _api.dio.put(
        "/auth/update-profile",
        data: {
          if (name != null) "name": name,
          if (avatar != null) "avatar": avatar,
        },
      );

      return {"ok": true, "data": res.data};
    } on DioError catch (e) {
      return {
        "ok": false,
        "error": e.response?.data["message"] ?? e.message,
      };
    }
  }

  // ----------------------------------------------------------
  // LOGOUT
  // ----------------------------------------------------------
  Future<void> logout() async {
    // Optionally notify backend
    try {
      final rt = await _api.storage.read(key: "refresh_token");
      if (rt != null) {
        await _api.dio.post("/auth/logout", data: {"refreshToken": rt});
      }
    } catch (_) {}

    await _api.storage.delete(key: "jwt_token");
    await _api.storage.delete(key: "refresh_token");
  }
}


