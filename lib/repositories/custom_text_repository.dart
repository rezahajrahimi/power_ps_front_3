import 'package:dio/dio.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/custom_text_model.dart';

Future<List<CustomTextModel>> getCustomTexts() async {
  Response response = await GenaralApi.dio.get("/api/get-all-texts");
  if (response.statusCode == 200 && response.data != null) {
    List<CustomTextModel> customTexts = [];
    for (var i in response.data) {
      customTexts.add(CustomTextModel.fromJson(i));
    }
    return customTexts;
  }
  return [];
}

Future<CustomTextModel> getCustomText(String key) async {
  Response response = await GenaralApi.dio.get("/api/get-text/$key");
  if (response.statusCode == 200 && response.data != null) {
    return CustomTextModel.fromJson(response.data);
  }
  return CustomTextModel(
      id: BigInt.zero,
      defaultText: "",
      key: "",
      customText: "",
      description: "");
}

Future<bool> updateCustomText(
    {required String key, required String text}) async {
  // Route::post('/set-text/{key}/{text}', [CustomTextController::class, 'setText']);

  Response response = await GenaralApi.dio.post("/api/set-text/$key/$text");
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}
