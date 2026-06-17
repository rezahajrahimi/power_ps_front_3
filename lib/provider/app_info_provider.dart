import 'package:flutter/material.dart';
import 'package:powerps/helper/shared_prefrencess.dart';
import 'package:powerps/models/app_info_model.dart';
import 'package:powerps/repositories/app_info_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class AppInfoProvider extends ChangeNotifier {
  AppInfoModel? _appInfo;
  bool _isLoading = true;

  AppInfoModel? get appInfo => _appInfo;
  bool get isLoading => _isLoading;

  String get displayTitle {
    final info = _appInfo;
    if (info == null) return 'PowerPS';
    final title = info.panelTitle?.trim();
    if (title != null && title.isNotEmpty) return title;
    return info.name.isNotEmpty ? info.name : 'PowerPS';
  }

  AppInfoProvider() {
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    _isLoading = true;
    notifyListeners();

    AppInfoModel? info;
    try {
      info = await fetchAppInfo();
    } catch (_) {
      info = await AppInfoPreference().getAppInfo();
    }

    info ??= AppInfoModel(
      name: 'Power Proxy Seller',
      version: '6.7.0',
      image: '',
    );

    _appInfo = info;
    _applyBranding(info);
    await AppInfoPreference().saveAppInfo(info);

    _isLoading = false;
    notifyListeners();
  }

  void _applyBranding(AppInfoModel info) {
    AppStyle.applyBranding(
      primaryHex: info.primaryColor,
      secondaryHex: info.secondaryColor,
      backgroundHex: info.backgroundColor,
    );
  }

  Future<void> refresh() async {
    await _loadAppInfo();
  }
}
