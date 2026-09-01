import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<String?> saveBytesToDevice({
  required Uint8List bytes,
  required String fileName,
  String mimeType = 'application/octet-stream',
}) async {
  Directory directory;
  try {
    directory = await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
  } catch (_) {
    directory = await getTemporaryDirectory();
  }

  final savePath = '${directory.path}/$fileName';
  await File(savePath).writeAsBytes(bytes, flush: true);
  return savePath;
}
