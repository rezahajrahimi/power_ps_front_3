import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

const String _kBaseUrlKey = 'https://core.example.com';

// default to a valid local address so Dio initialization won't fail
String baseURL = "https://core.example.com";
String imageURL = baseURL;
const String telgramApiURL = "https://api.telegram.org";
// const String baseURL = "https://powernad.ir/public";

String _normalizeUrl(String url) {
  var u = url.trim();
  if (u.endsWith("/")) u = u.substring(0, u.length - 1);
  if (!u.startsWith('http://') && !u.startsWith('https://')) {
    u = 'http://$u';
  }
  return u;
}

/// Initialize `baseURL` from SharedPreferences (if saved) and update Dio.
Future<void> initBaseUrl() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_kBaseUrlKey);
  if (saved != null && saved.isNotEmpty && saved != "**") {
    baseURL = _normalizeUrl(saved);
    imageURL = baseURL;
  }
  // ensure Dio uses the correct base URL
  GenaralApi.dio.options.baseUrl = baseURL;
}

/// Restore auth headers from persisted token (needed on web refresh).
Future<void> restoreAuthSession() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token != null && token.isNotEmpty && token != 'void') {
    GenaralApi.dio.options.headers['Authorization'] = 'Bearer $token';
    GenaralApi.dio.options.headers['x-access-token'] = token;
  }
}

/// Persist the provided [newUrl] and update global variables and Dio instance.
Future<void> saveBaseUrl(String newUrl) async {
  final normalized = _normalizeUrl(newUrl);
  baseURL = normalized;
  imageURL = normalized;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kBaseUrlKey, normalized);
  GenaralApi.dio.options.baseUrl = normalized;
}

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
    receiveTimeout: const Duration(seconds: 300),
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
