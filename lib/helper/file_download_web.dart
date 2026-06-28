import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

Future<String?> saveBytesToDevice({
  required Uint8List bytes,
  required String fileName,
}) async {
  final blob = Blob(
    [bytes.toJS].toJS,
    BlobPropertyBag(type: 'text/csv'),
  );
  final url = URL.createObjectURL(blob);
  final anchor = HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';

  document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  URL.revokeObjectURL(url);
  return fileName;
}
