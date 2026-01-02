import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late Dio dio;
  final storage = const FlutterSecureStorage();

  ApiClient() {
    // 🔥 Auto select correct base URL
    String base = "https://bodyenergiz-backend.onrender.com:3000/api";

    if (Platform.isAndroid) {
     // base = "http://10.0.2.2:3000/api";
     base = "https://bodyenergiz-backend.onrender.com:3000/api";
    }

    dio = Dio(
      BaseOptions(
        baseUrl: base,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // 🔐 Always attach Authorization header if token exists
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: "jwt_token");
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
      ),
    );
  }
}


