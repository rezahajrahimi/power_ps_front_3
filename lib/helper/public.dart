import 'dart:math';

import 'package:flutter/material.dart';
import 'package:powerps/styles/app_theme.dart';
import 'dart:math' as math;
import 'dart:convert';

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

bool panelSupportsRemarkRename(String type) {
  return type == 'hiddify' || type == 'sanaei';
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
  return getMarzbanPanelBaseUrl(urlPort: adminUrl) ?? adminUrl;
}

String? getMarzbanPanelBaseUrl({String? urlPort, String? adminUrl}) {
  var url = urlPort?.trim();
  if (url == null || url.isEmpty || url.toLowerCase() == 'null') {
    url = adminUrl?.trim();
  }
  if (url == null || url.isEmpty || url.toLowerCase() == 'null') {
    return null;
  }

  url = url
      .replaceAll('/dashboard/', '/')
      .replaceAll('/dashboard', '')
      .replaceAll(RegExp(r'/+$'), '');

  final uri = Uri.tryParse(url);
  if (uri != null && uri.hasScheme) {
    if (uri.path.isEmpty || uri.path == '/') {
      return uri.origin;
    }
    return url;
  }

  return url;
}

String? resolveMarzbanUsernameFromProduct({
  required String configs,
  String? remark,
  String? panelLink,
  String? subscriptionLink,
}) {
  final configsRaw = configs.trim();
  if (configsRaw.isNotEmpty && configsRaw.toLowerCase() != 'null') {
    try {
      final decoded = jsonDecode(configsRaw);
      if (decoded is Map) {
        final username = decoded['username']?.toString().trim();
        if (username != null &&
            username.isNotEmpty &&
            username.toLowerCase() != 'null') {
          return username;
        }
      }
    } catch (_) {}
  }

  for (final candidate in [panelLink, subscriptionLink, remark]) {
    final extracted = extractUsernameFromPanelUrl(candidate);
    if (extracted != null) {
      return extracted;
    }
  }

  final normalizedRemark = remark?.trim();
  if (normalizedRemark != null &&
      normalizedRemark.isNotEmpty &&
      normalizedRemark.toLowerCase() != 'null') {
    return normalizedRemark;
  }

  return null;
}

String? extractUsernameFromPanelUrl(String? rawUrl) {
  final url = rawUrl?.trim();
  if (url == null || url.isEmpty || url.toLowerCase() == 'null') {
    return null;
  }

  final uri = Uri.tryParse(url);
  if (uri == null) {
    return null;
  }

  for (final key in const ['username', 'user', 'email', 'remark', 'client']) {
    final candidate = uri.queryParameters[key]?.trim();
    if (candidate != null &&
        candidate.isNotEmpty &&
        candidate.toLowerCase() != 'null') {
      return Uri.decodeComponent(candidate);
    }
  }

  const excludedSegments = {
    'admin',
    'panel',
    'user',
    'users',
    'client',
    'clients',
    'subscription',
    'subscriptions',
    'sub',
    'config',
    'configs',
  };
  for (final segment in uri.pathSegments.reversed) {
    final candidate = Uri.decodeComponent(segment).trim();
    if (candidate.isNotEmpty &&
        candidate.toLowerCase() != 'null' &&
        !excludedSegments.contains(candidate.toLowerCase())) {
      return candidate;
    }
  }

  return null;
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
