import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/repositories/setting_repository.dart';

Future getImageSrcFromTelegram({required String botfile}) async {
  try {
    String url = await getBotToken().then((botToken) async {
      Response response =
          await TelegramApi.dio.get("/$botToken/getFile?file_id=$botfile",
              options: Options(headers: {
                'Accept': 'application/json',
                'Connection': 'keep-alive',
                "Content-Type": "application/json;charset=UTF-8",
                "Charset": "utf-8",
                'Access-Control-Allow-Origin': '*'
              }));

      if (response.statusCode == 200 && response.data["ok"] == true) {
        var data = response.data["result"];
        String filePath = data["file_path"];
        // if (kIsWeb) {
        //   String url = "$telgramApiURL/file/$botToken/$filePath.jpg";
        //   debugPrint('aaaaaaaaaaa : $url');
        //   return url;
        // } else {
        String url = "$telgramApiURL/file/$botToken/$filePath";

        debugPrint('aaaaaaaaaaa : $url');
        return url;
        // }
      } else if (response.statusCode == 201) {
        return "";
      } else if (response.statusCode == 401) {
        return "";
      } else if (response.statusCode == 500) {
        return "";
      } else {
        return "";
      }
    });
    return url;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}
