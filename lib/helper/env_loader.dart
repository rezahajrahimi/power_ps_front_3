import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String defaultBaseUrl = 'https://core.example.com';

/// Load `assets/.env` into [dotenv].
///
/// On web, the server-deployed `assets/.env` (written by install.sh) is fetched
/// first so each customer install can set [defaultBaseUrl] without rebuilding.
/// Falls back to the bundled asset when the fetch fails (e.g. local dev).
Future<void> loadAppEnv() async {
  if (kIsWeb && await _tryLoadEnvFromWeb()) {
    return;
  }

  await dotenv.load(fileName: 'assets/.env', isOptional: true);
}

Future<bool> _tryLoadEnvFromWeb() async {
  try {
    final uri = Uri.base.resolve('assets/.env');
    final client = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      responseType: ResponseType.plain,
    ));
    final response = await client.get<String>(uri.toString());
    final body = response.data?.trim() ?? '';
    if (response.statusCode == 200 && body.isNotEmpty) {
      dotenv.testLoad(fileInput: body);
      return true;
    }
  } catch (_) {
    // Fall back to bundled asset.
  }
  return false;
}

String? envBaseUrl() {
  if (!dotenv.isInitialized) return null;
  final value = dotenv.maybeGet('BASE_URL')?.trim();
  if (value == null || value.isEmpty) return null;
  return value;
}
