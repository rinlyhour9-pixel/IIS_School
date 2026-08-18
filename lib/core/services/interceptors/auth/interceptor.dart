import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class AuthInterceptor extends Interceptor {
  final box = GetStorage();

  @override
  void onRequest(options, handler) {
    final token = box.read('token');

    if (token != null) {
      options.headers['Authorization'] = "Bearer $token";
    }

    return handler.next(options);
  }
}
