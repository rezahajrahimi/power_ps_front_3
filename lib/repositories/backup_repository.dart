import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';

class BackupCreateResult {
  const BackupCreateResult({
    required this.url,
    required this.filename,
  });

  final String url;
  final String filename;
}

Future<BackupCreateResult?> createBackup() async {
  try {
    final response = await GenaralApi.dio.get(
      "/api/createBackup",
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json;charset=UTF-8",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*'
      }),
    );
    debugPrint("response=>${response.data}");
    if (response.statusCode == 200 && response.data is Map) {
      final data = Map<String, dynamic>.from(response.data as Map);
      final url = data['url']?.toString();
      if (url == null || url.isEmpty) {
        return null;
      }
      final filename = (data['filename']?.toString().isNotEmpty == true)
          ? data['filename'].toString()
          : url.split('/').last;
      return BackupCreateResult(url: url, filename: filename);
    }
    debugPrint(response.data.toString());
    return null;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

/// Authenticated download used by Flutter Web (blob save).
/// Falls back to the public storage URL if the dedicated API is unavailable.
Future<Uint8List?> downloadBackupBytes({
  required String backupUrl,
  required String filename,
}) async {
  try {
    final response = await GenaralApi.dio.get(
      "/api/downloadBackup/$filename",
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    if (response.statusCode == 200 && response.data != null) {
      return Uint8List.fromList(List<int>.from(response.data));
    }
    debugPrint(
      'downloadBackup API failed (${response.statusCode}), trying public URL',
    );
  } catch (e) {
    debugPrint('downloadBackup API error: $e');
  }

  try {
    final response = await GenaralApi.dio.get(
      backupUrl,
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    if (response.statusCode == 200 && response.data != null) {
      return Uint8List.fromList(List<int>.from(response.data));
    }
  } catch (e) {
    debugPrint('public backup URL download error: $e');
  }

  return null;
}

Future<bool> restoreBackup({required FormData formData}) async {
  try {
    final response = await GenaralApi.dio.post(
      "/api/restoreBackup",
      data: formData,
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    if (response.statusCode == 200 && response.data != null) {
      if (response.data is Map && response.data['status'] == 'error') {
        return false;
      }
      return true;
    }
    return false;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}
