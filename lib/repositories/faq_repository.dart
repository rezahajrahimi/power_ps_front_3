import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/faq_model.dart';

List<Faq> faqsLIst = [];

String faqChangedToken = "aa";
ChangeFaqController faqNotifier = ChangeFaqController(0);

class ChangeFaqController extends ValueNotifier {
  ChangeFaqController(super.value);
  void changedfaqData() {
    value = faqChangedToken;
  }
}

Future getFaqList() async {
  try {
    Response response = await GenaralApi.dio.get("/api/getFaqList",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      faqsLIst.clear();
      var data = response.data;
      for (var i in data) {
        faqsLIst.add(Faq.fromJson(i));
      }

      return faqsLIst;
    } else if (response.statusCode == 201) {
      return null;
    } else if (response.statusCode == 401) {
      return null;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future getFacById({required int id}) async {
  try {
    Response response = await GenaralApi.dio.get("/api/getFaqById/$id",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      Faq faq = Faq.fromJson(response.data);

      return faq;
    } else if (response.statusCode == 201) {
      return null;
    } else if (response.statusCode == 401) {
      return null;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future deleteFacById({required int id}) async {
  try {
    Response response = await GenaralApi.dio.get("/api/deleteFacById/$id",
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      return true;
    } else if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 401) {
      return null;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future createNewFac({required Faq faq}) async {
  // try {
  Response response = await GenaralApi.dio.post("/api/createNewFac",
      data: {
        "question": faq.question,
        "answer": faq.answer,
      },
      options: Options(headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        "Content-Type": "application/json;charset=UTF-8",
        "Charset": "utf-8",
        'Access-Control-Allow-Origin': '*'
      }));
  debugPrint(response.data);
  debugPrint(response.statusMessage);
  debugPrint(response.statusCode.toString());
  if (response.statusCode == 200 && response.data != null) {
    return true;
  } else if (response.statusCode == 201) {
    return true;
  } else if (response.statusCode == 401) {
    return null;
  } else if (response.statusCode == 500) {
    return null;
  } else {
    return null;
  }
  // } on DioException catch (e) {
  //   debugPrint(e.message.toString());
  //   return null;
  // }
}

Future updateFac({required Faq faq}) async {
  try {
    Response response = await GenaralApi.dio.post("/api/updateFac",
        data: {
          "id": int.parse(faq.id),
          "question": faq.question,
          "answer": faq.answer,
        },
        options: Options(headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8",
          'Access-Control-Allow-Origin': '*'
        }));

    if (response.statusCode == 200 && response.data != null) {
      return true;
    } else if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 401) {
      return null;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}
