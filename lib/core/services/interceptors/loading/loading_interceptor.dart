import 'package:dio/dio.dart' as dio;
import 'package:schoolapp/core/core.dart';

class LoadingInterceptor extends dio.Interceptor {
  LoadingInterceptor({required this.isShow});

  final bool isShow;

  @override
  void onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) {
    if (isShow) {
      DialogManager.showLoadingDialog();
    }
    super.onRequest(options, handler);
  }
}
