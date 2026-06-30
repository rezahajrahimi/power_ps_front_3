import 'dart:math';

import 'package:flutter/material.dart';
import 'package:powerps/styles/app_theme.dart';
import 'dart:math' as math;

removeZeroChars(String number) {
  try {
    if (number.isNotEmpty && number != "null") {
      double n = double.parse(number);
      return n.toString().replaceFirst(RegExp(r'(?<=\.\d*)(0+$)|(\.0+$)'), '');
    } else {
      return;
    }
  } catch (e) {
    return;
  }
}

String thousandSeperatorFormatter(String price) {
  if (price != "0.00" && price != "null" && price.isNotEmpty) {
    // String price = "1000000000";
    String priceInText = "";
    int counter = 0;
    var i = price.indexOf(".");
    String subPrice = price;
    String dem = "";
    if (i != 0 && i != -1) {
      subPrice = price.substring(0, i);
      dem = price.substring(i, price.length);
    }

    for (int i = (subPrice.length - 1); i >= 0; i--) {
      counter++;
      String str = subPrice[i];
      if ((counter % 3) != 0 && i != 0) {
        priceInText = "$str$priceInText";
      } else if (i == 0) {
        priceInText = "$str$priceInText";
      } else {
        priceInText = ",$str$priceInText";
      }
    }
    return priceInText.trim() + dem;
  } else {
    return price;
  }
}

String formatPrice(String price) => thousandSeperatorFormatter(price);

showMsg(
    {required String msg,
    required BuildContext context,
    String type = "info"}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      msg,
      textDirection: TextDirection.rtl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 3),
    backgroundColor: type == "info" ? AppStyle.primaryColor : Colors.redAccent,
    margin: const EdgeInsets.all(20),
  ));
}

String getPannelName({required String name, String type = "main"}) {
  String str = "دیگر";
  if (type == "main") {
    switch (name) {
      case "custome":
        str = "دیگر";
        break;
      case "hiddify":
        str = "Hiddify";
        break;
      case "sanaei":
        str = "Sanaei";
        break;
      case "marzban":
        str = "Marzban";
        break;
      case "pasarguard":
        str = "PasarGuard";
        break;
      default:
        str = "دیگر";
    }
  } else {
    switch (name) {
      case "دیگر":
        str = "custome";
        break;
      case "Hiddify":
        str = "hiddify";
        break;
      case "Sanaei":
        str = "sanaei";
        break;
      case "Marzban":
        str = "marzban";
        break;
      case "PasarGuard":
        str = "pasarguard";
        break;
      default:
        str = "custome";
    }
  }
  return str;
}

bool isMarzbanCompatiblePanel(String type) {
  return type == 'marzban' || type == 'pasarguard';
}

bool isMarzbanPanel(String type) {
  return type == 'marzban';
}

bool isPasarguardPanel(String type) {
  return type == 'pasarguard';
}

bool isInventoryPanelType(String type) {
  return type == 'custome';
}

bool panelSupportsGroupOperations(String type) {
  return type == 'hiddify' ||
      type == 'sanaei' ||
      isMarzbanCompatiblePanel(type);
}

String getPanelTypeFromDropdownLabel(String panelDropdownValue) {
  if (panelDropdownValue.isEmpty) {
    return '';
  }

  final parts = panelDropdownValue.split(':');
  if (parts.length < 2) {
    return '';
  }

  final label = parts[1].trim().split(' - ').first.trim();
  return getPannelName(name: label, type: 'reverse');
}

bool panelDropdownSupportsConfigToggle(String panelDropdownValue) {
  final panelType = getPanelTypeFromDropdownLabel(panelDropdownValue);
  return panelType == 'sanaei' || isMarzbanCompatiblePanel(panelType);
}

String getMarzbanCompatiblePanelLabel(String type) {
  return type == 'pasarguard' ? 'PasarGuard' : 'Marzban';
}

String getHiddifyUserUUIDbySubscriptionLInk({required String pannelLink}) {
  pannelLink = pannelLink.substring(0, pannelLink.length - 1);
  List<String> list = pannelLink.split("/");
  return list[list.length - 1];
}

String getHiddifyConfigApiUrl({required String adminUrl}) {
  return adminUrl.replaceFirst("/admin/", '');
}

String getMarzbanConfigApiUrl({required String adminUrl}) {
  Uri ur = Uri.parse(adminUrl);
  return ur.origin;
}

Color randomColorGenerator() {
  final rnd = math.Random();

  return Color(rnd.nextInt(0xffffffff));
}

bool checkIsGiftCardString({required String str}) {
  if (str.startsWith("giftcard-")) {
    return true;
  }
  return false;
}

String getFileSizeString({required int bytes, int decimals = 0}) {
  const suffixes = ["b", "kb", "mb", "gb", "tb"];
  if (bytes == 0) return '0${suffixes[0]}';
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}
