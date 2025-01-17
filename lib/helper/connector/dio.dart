import 'package:dio/dio.dart';

// const String baseURL = "https://laravel-rq3qi6.chbk.run";
const String baseURL = "http://localhost:8000";
const String telgramApiURL = "https://api.telegram.org";
// const String baseURL = "https://powernad.ir/public";

class GenaralApi {
  static final BaseOptions _baseOptions = BaseOptions(
    baseUrl: baseURL,
    headers: {'accept': 'application/json', 'content-type': 'application/json'},
    responseType: ResponseType.json,
    followRedirects: false,
    validateStatus: (status) {
      return status! < 500;
    },
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  );
  static Dio dio = Dio(_baseOptions);

  static Dio dioAuth() {
    return Dio();
  }
}

class TelegramApi {
  static final BaseOptions _baseOptions = BaseOptions(
    baseUrl: telgramApiURL,
    headers: {'accept': 'application/json', 'content-type': 'application/json'},
    responseType: ResponseType.json,
    followRedirects: false,
    validateStatus: (status) {
      return status! < 500;
    },
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  );
  static Dio dio = Dio(_baseOptions);

  static Dio dioAuth() {
    return Dio();
  }
}
