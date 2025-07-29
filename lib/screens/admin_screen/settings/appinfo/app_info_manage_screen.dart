import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:powerps/models/app_info_model.dart';
import 'package:powerps/repositories/app_info_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class AppInfoManageScreen extends StatefulWidget {
  const AppInfoManageScreen({super.key});

  @override
  State<AppInfoManageScreen> createState() => _AppInfoManageScreenState();
}

class _AppInfoManageScreenState extends State<AppInfoManageScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _versionController;
  String? _imageUrl;
  Uint8List? _imageBytes;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _versionController = TextEditingController();
    _fetchAppInfo();
  }

  Future<void> _fetchAppInfo() async {
    setState(() => _loading = true);
    try {
      final info = await fetchAppInfo();
      _nameController.text = info.name;
      _versionController.text = info.version;
      _imageUrl = info.image;
    } catch (e) {
      if (!mounted) return;
      _nameController.text = '';
      _versionController.text = '';
      _imageUrl = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در دریافت اطلاعات اپلیکیشن')),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      String imageField = _imageUrl ?? '';
      // اگر تصویر جدید انتخاب شده، باید آپلود شود یا به صورت base64 ذخیره شود
      if (_imageBytes != null) {
        imageField = 'data:image/png;base64,${base64Encode(_imageBytes!)}';
      }
      final appInfo = AppInfoModel(
        name: _nameController.text,
        version: _versionController.text,
        image: imageField,
      );
      final result = await updateAppInfo(appInfo);
      if (!mounted) return;
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('اطلاعات با موفقیت ذخیره شد')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ذخیره اطلاعات')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ذخیره اطلاعات')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('مدیریت اطلاعات اپلیکیشن')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 420,
                    minWidth: 280,
                  ),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration:
                                  InputDecoration(labelText: 'نام اپلیکیشن'),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'نام را وارد کنید'
                                  : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _versionController,
                              decoration: InputDecoration(labelText: 'نسخه'),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'نسخه را وارد کنید'
                                  : null,
                            ),
                            SizedBox(height: 16),
                            Text('تصویر اپلیکیشن:',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            SizedBox(height: 8),
                            Center(
                              child: _imageBytes != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(_imageBytes!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover),
                                    )
                                  : (_imageUrl != null && _imageUrl!.isNotEmpty)
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(_imageUrl!,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Icon(
                                                  Icons.broken_image,
                                                  size: 80)),
                                        )
                                      : Icon(Icons.image, size: 80),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: Icon(Icons.upload),
                              label: Text('انتخاب تصویر'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                textStyle: TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(height: 24),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _saving ? null : _save,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _saving
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : Text('ذخیره',
                                        style: TextStyle(fontSize: 17)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
