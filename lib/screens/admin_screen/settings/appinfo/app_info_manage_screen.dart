import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/helper/constes.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/app_info_model.dart';
import 'package:powerps/provider/app_info_provider.dart';
import 'package:powerps/repositories/app_info_repository.dart';
import 'package:powerps/repositories/general_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

class AppInfoManageScreen extends StatefulWidget {
  const AppInfoManageScreen({super.key});

  @override
  State<AppInfoManageScreen> createState() => _AppInfoManageScreenState();
}

class _AppInfoManageScreenState extends State<AppInfoManageScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _versionController;
  late TextEditingController _panelTitleController;
  late TextEditingController _primaryColorController;
  late TextEditingController _secondaryColorController;
  late TextEditingController _backgroundColorController;
  late TextEditingController _footerTextController;
  String? _imageUrl;
  Uint8List? _imageBytes;
  bool _loading = true;
  bool _saving = false;
  bool _showPowerpsCredit = true;
  bool _licenseChecked = false;
  bool _isGoldLicense = false;

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _versionController = TextEditingController(text: projectVersion);
    _panelTitleController = TextEditingController();
    _primaryColorController = TextEditingController(text: '#2697FF');
    _secondaryColorController = TextEditingController(text: '#2A2D3E');
    _backgroundColorController = TextEditingController(text: '#212332');
    _footerTextController = TextEditingController();
    _checkLicenseAndLoad();
  }

  Future<void> _checkLicenseAndLoad() async {
    final license = (await getLicenseType()).toLowerCase();
    if (!mounted) return;
    if (license != 'gold') {
      setState(() {
        _licenseChecked = true;
        _isGoldLicense = false;
        _loading = false;
      });
      return;
    }
    setState(() {
      _licenseChecked = true;
      _isGoldLicense = true;
    });
    await _fetchAppInfo();
  }

  Future<void> _fetchAppInfo() async {
    setState(() => _loading = true);
    try {
      final info = await fetchAppInfo();
      _nameController.text = info.name;
      _versionController.text = resolveAppVersion(info.version);
      _panelTitleController.text = info.panelTitle ?? '';
      _primaryColorController.text = info.primaryColor ?? '#2697FF';
      _secondaryColorController.text = info.secondaryColor ?? '#2A2D3E';
      _backgroundColorController.text = info.backgroundColor ?? '#212332';
      _footerTextController.text = info.footerText ?? '';
      _showPowerpsCredit = info.showPowerpsCredit;
      _imageUrl = imageURL + info.image;
    } catch (e) {
      if (!mounted) return;
      _nameController.text = '';
      _versionController.text = projectVersion;
      _imageUrl = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در دریافت اطلاعات اپلیکیشن')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _imageBytes = result.files.single.bytes;
          _imageUrl = null;
        });
      }
    } else {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageUrl = null;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ابتدا یک تصویر انتخاب کنید.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final result = await uploadImage(imageBytes: _imageBytes!);
      if (!mounted) return;
      if (result) {
        await _fetchAppInfo();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تصویر با موفقیت آپلود شد.')),
        );
        setState(() => _imageBytes = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در آپلود تصویر')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در آپلود تصویر')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final appInfo = AppInfoModel(
        name: _nameController.text,
        version: _versionController.text,
        image: _imageUrl ?? '',
        panelTitle: _panelTitleController.text,
        primaryColor: _primaryColorController.text,
        secondaryColor: _secondaryColorController.text,
        backgroundColor: _backgroundColorController.text,
        footerText: _footerTextController.text,
        showPowerpsCredit: _showPowerpsCredit,
      );
      final result = await updateAppInfo(appInfo: appInfo);
      if (!mounted) return;
      if (result) {
        await fetchAppInfo();
        if (mounted) {
          context.read<AppInfoProvider>().refresh();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اطلاعات با موفقیت ذخیره شد')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در ذخیره اطلاعات')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در ذخیره اطلاعات')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    _panelTitleController.dispose();
    _primaryColorController.dispose();
    _secondaryColorController.dispose();
    _backgroundColorController.dispose();
    _footerTextController.dispose();
    super.dispose();
  }

  Widget _colorPreview(String hex) {
    Color? color;
    try {
      final value = hex.replaceFirst('#', '');
      if (value.length == 6) {
        color = Color(int.parse('FF$value', radix: 16));
      }
    } catch (_) {}
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color ?? Colors.grey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
    );
  }

  Widget _colorField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Padding(
          padding: const EdgeInsets.all(8),
          child: _colorPreview(controller.text),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _imageSection({bool compact = false}) {
    final imageSize = compact ? 120.0 : 160.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'تصویر اپلیکیشن',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Center(
          child: _imageBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _imageBytes!,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                  ),
                )
              : (_imageUrl != null && _imageUrl!.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _imageUrl!,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            Icon(Icons.broken_image, size: imageSize * 0.6),
                      ),
                    )
                  : Icon(Icons.image, size: imageSize * 0.6),
        ),
        const SizedBox(height: 16),
        Responsive(
          mobile: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload),
                  label: const Text('انتخاب تصویر'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_imageBytes != null && !_saving) ? _uploadImage : null,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('آپلود تصویر'),
                ),
              ),
            ],
          ),
          desktop: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload),
                  label: const Text('انتخاب تصویر'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (_imageBytes != null && !_saving) ? _uploadImage : null,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('آپلود تصویر'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _formFields({required bool twoColumn}) {
    final nameVersion = twoColumn
        ? Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'نام اپلیکیشن'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'نام را وارد کنید' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _versionController,
                  decoration: const InputDecoration(labelText: 'نسخه'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'نسخه را وارد کنید' : null,
                ),
              ),
            ],
          )
        : Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'نام اپلیکیشن'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'نام را وارد کنید' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _versionController,
                decoration: const InputDecoration(labelText: 'نسخه'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'نسخه را وارد کنید' : null,
              ),
            ],
          );

    final colors = twoColumn
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _colorField(
                  controller: _primaryColorController,
                  label: 'رنگ اصلی (#RRGGBB)',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _colorField(
                  controller: _secondaryColorController,
                  label: 'رنگ ثانویه (#RRGGBB)',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _colorField(
                  controller: _backgroundColorController,
                  label: 'رنگ پس‌زمینه (#RRGGBB)',
                ),
              ),
            ],
          )
        : Column(
            children: [
              _colorField(
                controller: _primaryColorController,
                label: 'رنگ اصلی (#RRGGBB)',
              ),
              const SizedBox(height: 16),
              _colorField(
                controller: _secondaryColorController,
                label: 'رنگ ثانویه (#RRGGBB)',
              ),
              const SizedBox(height: 16),
              _colorField(
                controller: _backgroundColorController,
                label: 'رنگ پس‌زمینه (#RRGGBB)',
              ),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        nameVersion,
        const SizedBox(height: 16),
        TextFormField(
          controller: _panelTitleController,
          decoration: const InputDecoration(labelText: 'عنوان پنل'),
        ),
        const SizedBox(height: 16),
        colors,
        const SizedBox(height: 16),
        TextFormField(
          controller: _footerTextController,
          decoration: const InputDecoration(labelText: 'متن فوتر'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('نمایش برند PowerPS'),
          value: _showPowerpsCredit,
          onChanged: (v) => setState(() => _showPowerpsCredit = v),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyle.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('ذخیره', style: TextStyle(fontSize: 17)),
          ),
        ),
      ],
    );
  }

  Widget _content(BuildContext context) {
    final twoColumn = !Responsive.isMobile(context);

    if (Responsive.isMobile(context)) {
      return ListView(
        padding: Responsive.adminPagePadding(context),
        children: [
          Container(
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            decoration: _cardDecoration,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _formFields(twoColumn: false),
                  const Divider(height: 32),
                  _imageSection(compact: true),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: Responsive.adminPagePadding(context),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: EdgeInsets.all(AppStyle.defaultPadding),
          decoration: _cardDecoration,
          child: Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _formFields(twoColumn: twoColumn),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(AppStyle.defaultPadding),
                    decoration: BoxDecoration(
                      color: AppStyle.bgColor.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _imageSection(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
              'برندینگ پنل (White-label)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'این بخش فقط برای لایسنس طلایی فعال است.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppStyle.deactiveStatus),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: AppStyle.bgColor,
      appBar: appBarWithBackButton(
        context: context,
        title: 'مدیریت اطلاعات اپلیکیشن',
      ),
      body: !_licenseChecked
          ? const Center(child: CircularProgressIndicator())
          : !_isGoldLicense
              ? _lockedView()
              : _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _content(context),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Responsive.isMobile(context) ? SafeArea(child: scaffold) : scaffold,
    );
  }
}
