import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/license_helper.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/advanced_setting_model.dart';
import 'package:powerps/models/bot_button_config_model.dart';
import 'package:powerps/models/main_menu_item_model.dart';
import 'package:powerps/repositories/bot_button_config_repository.dart';
import 'package:powerps/repositories/general_repository.dart';
import 'package:powerps/repositories/main_menu_item_repository.dart';
import 'package:powerps/repositories/setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class BotButtonConfigScreen extends StatefulWidget {
  const BotButtonConfigScreen({super.key});

  @override
  State<BotButtonConfigScreen> createState() => _BotButtonConfigScreenState();
}

class _BotButtonConfigScreenState extends State<BotButtonConfigScreen> {
  bool _licenseChecked = false;
  bool _isSilverOrAbove = false;
  bool _loading = true;
  String? _loadError;
  BotButtonConfig? _config;
  List<MainMenuItem> _menuItems = [];
  String _packageLayout = 'full_button';

  static const _styleLabels = {
    'primary': 'آبی (اصلی)',
    'success': 'سبز (تایید)',
    'danger': 'قرمز (لغو)',
  };

  static const _matchTypeLabels = {
    'action_prefix': 'پیشوند اکشن',
    'exact': 'دقیق',
    'callback_contains': 'شامل callback',
  };

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final license = await getLicenseType();
    if (!mounted) return;

    final allowed = LicenseHelper.isSilverOrAbove(license);
    setState(() {
      _licenseChecked = true;
      _isSilverOrAbove = allowed;
    });

    if (!allowed) {
      setState(() => _loading = false);
      return;
    }

    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final configResult = await getBotButtonConfig();
      if (!configResult.isSuccess) {
        if (!mounted) return;
        setState(() {
          _loadError = configResult.errorMessage ??
              'تنظیمات دکمه‌ها در دسترس نیست. مطمئن شوید بک‌اند به‌روز و migrate اجرا شده است.';
          _loading = false;
        });
        return;
      }

      final menuItems = await getAllMainMenuItems();

      String packageLayout = 'full_button';
      try {
        final advanced = await getBotAdvancedSetting();
        if (advanced is List) {
          for (final item in advanced) {
            if (item is AdvancedSettingModel &&
                item.name == AdvancedSettingModel.packageButtonLayoutKey) {
              packageLayout = item.value;
              break;
            }
          }
        }
      } catch (e) {
        debugPrint('advanced settings load skipped: $e');
      }

      if (!mounted) return;
      setState(() {
        _config = configResult.config;
        _menuItems = menuItems is List<MainMenuItem> ? menuItems : [];
        _packageLayout = packageLayout;
        _loading = false;
        _loadError = null;
      });
    } catch (e) {
      debugPrint('bot button config load failed: $e');
      if (!mounted) return;
      setState(() {
        _loadError = 'خطا در بارگذاری تنظیمات';
        _loading = false;
      });
    }
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  Future<void> _saveLayout() async {
    if (_config == null) return;
    EasyLoading.show();
    final updated = await updateBotButtonLayout(_config!.layoutPayload());
    EasyLoading.dismiss();
    if (!mounted) return;
    if (updated != null) {
      setState(() => _config = updated);
      showMsg(msg: 'چیدمان ذخیره شد', context: context);
    } else {
      showMsg(msg: 'خطا در ذخیره', context: context, type: 'error');
    }
  }

  Future<void> _saveStyleRules() async {
    if (_config == null) return;
    EasyLoading.show();
    final updated = await updateBotButtonStyleRules(_config!.styleRules);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (updated != null) {
      setState(() => _config = updated);
      showMsg(msg: 'قوانین استایل ذخیره شد', context: context);
    } else {
      showMsg(msg: 'خطا در ذخیره', context: context, type: 'error');
    }
  }

  Future<void> _savePackageLayout(String value) async {
    EasyLoading.show();
    final saved = await changeAdvancedSettingValue(
      name: AdvancedSettingModel.packageButtonLayoutKey,
      value: value,
    );
    EasyLoading.dismiss();
    if (!mounted) return;
    if (saved) {
      setState(() => _packageLayout = value);
      showMsg(msg: 'ذخیره شد', context: context);
    } else {
      showMsg(msg: 'خطا در ذخیره', context: context, type: 'error');
    }
  }

  Widget _lockedView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppStyle.defaultPadding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: AppStyle.deactiveStatus),
            const SizedBox(height: 16),
            const Text(
              'شخصی‌سازی دکمه‌های ربات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'این قابلیت فقط در لایسنس نقره‌ای و طلایی فعال است.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppStyle.deactiveStatus),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.25)),
      ),
      child: const Text(
        'رنگ و ایموجی دکمه‌ها در تلگرام‌های جدید (Bot API 9.4+) نمایش داده می‌شود. '
        'در نسخه‌های قدیمی‌تر، دکمه‌ها بدون استایل دیده می‌شوند.',
        style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.5),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppStyle.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  Widget _layoutSection() {
    final config = _config!;
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('چیدمان دکمه‌ها', Icons.grid_view_outlined),
          SizedBox(height: AppStyle.defaultPadding),
          _intSlider(
            label: 'ستون منوی اصلی (کیبورد پایین)',
            value: config.replyButtonsPerRow,
            min: 1,
            max: 4,
            onChanged: (v) =>
                setState(() => _config = _copyConfig(replyButtonsPerRow: v)),
          ),
          _intSlider(
            label: 'ستون دکمه‌های اینلاین',
            value: config.inlineButtonsPerRow,
            min: 1,
            max: 4,
            onChanged: (v) =>
                setState(() => _config = _copyConfig(inlineButtonsPerRow: v)),
          ),
          _intSlider(
            label: 'ستون لیست بسته‌ها',
            value: config.packageButtonsPerRow,
            min: 1,
            max: 4,
            onChanged: (v) =>
                setState(() => _config = _copyConfig(packageButtonsPerRow: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('اولین آیتم منو در ردیف جدا'),
            subtitle: const Text('مثلاً «خرید اشتراک» تمام‌عرض'),
            value: config.mainMenuFirstItemAlone,
            onChanged: (v) => setState(
                () => _config = _copyConfig(mainMenuFirstItemAlone: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('کیبورد پایین همیشه باز (is_persistent)'),
            value: config.replyKeyboardPersistent,
            onChanged: (v) => setState(
                () => _config = _copyConfig(replyKeyboardPersistent: v)),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: _saveLayout,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('ذخیره چیدمان'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _packageLayoutSection() {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('نمایش لیست بسته‌ها', Icons.view_list_outlined),
          SizedBox(height: AppStyle.defaultPadding),
          DropdownButtonFormField<String>(
            initialValue: AdvancedSettingModel.packageButtonLayoutOptions
                    .containsKey(_packageLayout)
                ? _packageLayout
                : AdvancedSettingModel.packageButtonLayoutOptions.keys.first,
            isExpanded: true,
            dropdownColor: AppStyle.secondaryColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: AdvancedSettingModel.packageButtonLayoutOptions.entries
                .map(
                  (e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) _savePackageLayout(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _styleRulesSection() {
    final rules = _config!.styleRules;
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child:
                      _sectionTitle('قوانین رنگ دکمه', Icons.palette_outlined)),
              IconButton(
                tooltip: 'افزودن قانون',
                onPressed: () {
                  setState(() {
                    _config = _copyConfig(
                      styleRules: [
                        ...rules,
                        BotButtonStyleRule(
                          match: '',
                          matchType: 'action_prefix',
                          style: 'primary',
                        ),
                      ],
                    );
                  });
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding),
          ...rules.asMap().entries.map((entry) {
            final index = entry.key;
            final rule = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: AppStyle.defaultPadding),
              padding: EdgeInsets.all(AppStyle.defaultPadding * 0.75),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppStyle.primaryColor.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: rule.match,
                    decoration: const InputDecoration(
                      labelText: 'مقدار تطبیق (مثلاً confirmBuy)',
                      isDense: true,
                    ),
                    onChanged: (v) => _updateRule(index, match: v),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue:
                              _matchTypeLabels.containsKey(rule.matchType)
                                  ? rule.matchType
                                  : 'action_prefix',
                          dropdownColor: AppStyle.secondaryColor,
                          decoration: const InputDecoration(
                            labelText: 'نوع تطبیق',
                            isDense: true,
                          ),
                          items: _matchTypeLabels.entries
                              .map((e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) _updateRule(index, matchType: v);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: rule.style,
                          dropdownColor: AppStyle.secondaryColor,
                          decoration: const InputDecoration(
                            labelText: 'رنگ',
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('بدون رنگ'),
                            ),
                            ..._styleLabels.entries.map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            ),
                          ],
                          onChanged: (v) =>
                              _updateRule(index, style: v, touchStyle: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: rule.iconCustomEmojiId ?? '',
                    decoration: const InputDecoration(
                      labelText: 'شناسه ایموجی سفارشی (اختیاری)',
                      isDense: true,
                    ),
                    onChanged: (v) => _updateRule(index, iconCustomEmojiId: v),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        final next = [...rules]..removeAt(index);
                        setState(() => _config = _copyConfig(styleRules: next));
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('حذف'),
                    ),
                  ),
                ],
              ),
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: _saveStyleRules,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('ذخیره قوانین استایل'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainMenuStyleSection() {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('استایل آیتم‌های منوی اصلی', Icons.menu_outlined),
          SizedBox(height: AppStyle.defaultPadding),
          ..._menuItems.map(_mainMenuItemTile),
        ],
      ),
    );
  }

  Widget _mainMenuItemTile(MainMenuItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: AppStyle.defaultPadding * 0.75),
      padding: EdgeInsets.all(AppStyle.defaultPadding * 0.75),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(item.aliasName,
              style: const TextStyle(fontSize: 12, color: Colors.white60)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: item.buttonStyle,
                  dropdownColor: AppStyle.secondaryColor,
                  decoration: const InputDecoration(
                    labelText: 'رنگ دکمه',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('پیش‌فرض'),
                    ),
                    ..._styleLabels.entries.map(
                      (e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ),
                    ),
                  ],
                  onChanged: (v) async {
                    item.buttonStyle = v;
                    await _saveMenuItemStyle(item);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: item.iconCustomEmojiId ?? '',
                  decoration: const InputDecoration(
                    labelText: 'ایموجی سفارشی',
                    isDense: true,
                  ),
                  onFieldSubmitted: (v) async {
                    item.iconCustomEmojiId = v.trim().isEmpty ? null : v.trim();
                    await _saveMenuItemStyle(item);
                  },
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('ردیف جداگانه'),
            value: item.soloRow,
            onChanged: (v) async {
              item.soloRow = v;
              await _saveMenuItemStyle(item);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveMenuItemStyle(MainMenuItem item) async {
    EasyLoading.show();
    final ok = await updateMainMenuButtonStyle(
      name: item.name,
      buttonStyle: item.buttonStyle,
      iconCustomEmojiId: item.iconCustomEmojiId,
      soloRow: item.soloRow,
    );
    EasyLoading.dismiss();
    if (!mounted) return;
    if (ok) {
      showMsg(msg: 'ذخیره شد', context: context);
    } else {
      showMsg(msg: 'خطا در ذخیره', context: context, type: 'error');
    }
  }

  void _updateRule(
    int index, {
    String? match,
    String? matchType,
    String? style,
    String? iconCustomEmojiId,
    bool touchStyle = false,
  }) {
    final rules = [..._config!.styleRules];
    final current = rules[index];
    rules[index] = BotButtonStyleRule(
      match: match ?? current.match,
      matchType: matchType ?? current.matchType,
      style: touchStyle ? style : current.style,
      iconCustomEmojiId: iconCustomEmojiId ?? current.iconCustomEmojiId,
    );
    setState(() => _config = _copyConfig(styleRules: rules));
  }

  BotButtonConfig _copyConfig({
    int? replyButtonsPerRow,
    int? inlineButtonsPerRow,
    int? packageButtonsPerRow,
    bool? replyKeyboardPersistent,
    bool? mainMenuFirstItemAlone,
    List<BotButtonStyleRule>? styleRules,
  }) {
    return BotButtonConfig(
      replyButtonsPerRow: replyButtonsPerRow ?? _config!.replyButtonsPerRow,
      inlineButtonsPerRow: inlineButtonsPerRow ?? _config!.inlineButtonsPerRow,
      packageButtonsPerRow:
          packageButtonsPerRow ?? _config!.packageButtonsPerRow,
      replyKeyboardPersistent:
          replyKeyboardPersistent ?? _config!.replyKeyboardPersistent,
      mainMenuFirstItemAlone:
          mainMenuFirstItemAlone ?? _config!.mainMenuFirstItemAlone,
      styleRules: styleRules ?? _config!.styleRules,
      availableStyles: _config!.availableStyles,
    );
  }

  Widget _intSlider({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            Text('$value', style: TextStyle(color: AppStyle.primaryColor)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppStyle.defaultPadding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: AppStyle.deactiveStatus),
            const SizedBox(height: 16),
            Text(
              _loadError ?? 'خطا در بارگذاری',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppStyle.deactiveStatus),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('تلاش مجدد'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null || _config == null) {
      return _errorView();
    }

    final sections = [
      _infoBanner(),
      _layoutSection(),
      SizedBox(height: AppStyle.defaultPadding),
      _packageLayoutSection(),
      SizedBox(height: AppStyle.defaultPadding),
      _styleRulesSection(),
      if (_menuItems.isNotEmpty) ...[
        SizedBox(height: AppStyle.defaultPadding),
        _mainMenuStyleSection(),
      ],
    ];

    return ListView(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      children: sections,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
            context: context,
            title: 'شخصی‌سازی دکمه‌های ربات',
          ),
          body: !_licenseChecked
              ? const Center(child: CircularProgressIndicator())
              : !_isSilverOrAbove
                  ? _lockedView()
                  : Responsive.isMobile(context)
                      ? _body()
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _body()),
                            const SizedBox(width: 16),
                            const Expanded(flex: 2, child: SizedBox()),
                          ],
                        ),
        ),
      ),
    );
  }
}
