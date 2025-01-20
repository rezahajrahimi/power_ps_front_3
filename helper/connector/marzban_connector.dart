import 'package:dio/dio.dart';

String marzbanURL = "";
// const String baseURL = "https://powernad.ir/public";

class MarzbanApi {
  static final BaseOptions _baseOptions = BaseOptions(
    baseUrl: marzbanURL,
    sendTimeout: const Duration(seconds: 5),
    // headers: {'accept': 'application/json', 'content-type': 'application/json'},
    responseType: ResponseType.json,
    followRedirects: false,
    validateStatus: (status) {
      return status! < 500;
    },
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  );
  static Dio dio = Dio(_baseOptions);

  static Dio dioAuth() {
    return Dio();
  }
}
