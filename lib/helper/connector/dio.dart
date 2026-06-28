import 'package:dio/dio.dart';
import 'package:powerps/helper/env_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kBaseUrlKey = 'base_url';
const String _kLegacyBaseUrlKey = 'https://core.example.com';

String baseURL = defaultBaseUrl;
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

/// Initialize `baseURL` from SharedPreferences, then `.env`, then default.
Future<void> initBaseUrl() async {
  final prefs = await SharedPreferences.getInstance();
  var saved = prefs.getString(_kBaseUrlKey);

  if (saved == null || saved.isEmpty) {
    final legacy = prefs.getString(_kLegacyBaseUrlKey);
    if (legacy != null && legacy.isNotEmpty && legacy != '**') {
      saved = legacy;
      await prefs.setString(_kBaseUrlKey, legacy);
      await prefs.remove(_kLegacyBaseUrlKey);
    }
  }

  if (saved != null && saved.isNotEmpty && saved != '**') {
    baseURL = _normalizeUrl(saved);
  } else {
    final fromEnv = envBaseUrl();
    if (fromEnv != null) {
      baseURL = _normalizeUrl(fromEnv);
    }
  }

  imageURL = baseURL;
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
