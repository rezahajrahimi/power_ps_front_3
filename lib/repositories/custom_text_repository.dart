import 'package:dio/dio.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/custom_text_model.dart';

Future<List<CustomTextModel>> getCustomTexts() async {
  Response response = await GenaralApi.dio.get("/api/get-all-texts");
  if (response.statusCode == 200 && response.data != null) {
    return response.data.map((e) => CustomTextModel.fromJson(e)).toList();
  }
  return [];
}

Future<CustomTextModel> getCustomText(String key) async {
  Response response = await GenaralApi.dio.get("/api/get-text/$key");
  if (response.statusCode == 200 && response.data != null) {
    return CustomTextModel.fromJson(response.data);
  }
  return CustomTextModel(
      id: BigInt.zero, defaultText: "", key: "", customText: "");
}

Future<bool> updateCustomText(CustomTextModel customText) async {
  Response response = await GenaralApi.dio.post(
      "/api/set-text/${customText.customText}",
      data: customText.toJson());
  return response.statusCode == 200;
}
