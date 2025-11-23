import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

class ProfileRepository {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> uploadProfilePhoto(File file) async {
    try {
      final filename = file.path.split('/').last;
      final form = FormData.fromMap({
        'photo': await MultipartFile.fromFile(file.path, filename: filename),
      });
      final res = await _api.dio.post('/profile/upload', data: form, options: Options(contentType: 'multipart/form-data'));
      return {'ok': true, 'data': res.data};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }
}


