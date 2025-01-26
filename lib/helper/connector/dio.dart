import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// String baseURL = dotenv.env['BASE_URL'] ?? "http://localhost:8000";
// const String baseURL = "https://botcore.powernad.ir";
const String baseURL = "http://localhost:8002";
String imageURL = baseURL;
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
