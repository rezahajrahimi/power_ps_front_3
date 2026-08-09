import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/file_download.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/repositories/backup_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  Uint8List? _fileBytes;
  String? _fileName;
  bool _isLoading = false;
  bool _isUploading = false;
  _content(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16.0,
                    children: [
                      // کارت پشتیبان‌گیری
                      _createBackuopInfoWidget(),
                      // کارت بازیابی
                      _restoreInfoWidget(),
                    ],
                  ),
                ],
              ),
            ),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
            // On Mobile means if the screen is less than 850 we dont want to show it
            if (!Responsive.isMobile(context)) // side windows
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        )
      ],
    );
  }

  Future<void> _createBackup() async {
    showMsg(msg: "در حال پشتیبان‌گیری از اطلاعات...", context: context);
    setState(() => _isLoading = true);

    try {
      final result = await createBackup();
      if (!mounted) return;

      if (result == null) {
        showMsg(
          msg: "ایجاد فایل پشتیبان ناموفق بود",
          context: context,
          type: "error",
        );
        return;
      }

      final fileName = result.filename;
      final url = result.url;

      // Prefer authenticated byte download (required for web; safer for mobile).
      final bytes = await downloadBackupBytes(
        backupUrl: url,
        filename: fileName,
      );
      if (!mounted) return;

      if (bytes != null && bytes.isNotEmpty) {
        final saved = await saveBytesToDevice(
          bytes: bytes,
          fileName: fileName,
          mimeType: 'application/sql',
        );
        if (!mounted) return;

        if (saved != null) {
          showMsg(
            msg: kIsWeb
                ? "فایل پشتیبان دانلود شد"
                : "فایل پشتیبان ذخیره شد",
            context: context,
            type: "success",
          );
          return;
        }
      }

      if (kIsWeb) {
        showMsg(
          msg: "دانلود فایل پشتیبان در وب ناموفق بود",
          context: context,
          type: "error",
        );
        return;
      }

      // Mobile/desktop fallback: open public storage URL.
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!mounted) return;

      if (!launched) {
        showMsg(
          msg: "باز کردن لینک دانلود ناموفق بود",
          context: context,
          type: "error",
        );
      } else {
        showMsg(
          msg: "لینک دانلود باز شد",
          context: context,
          type: "success",
        );
      }
    } catch (_) {
      if (!mounted) return;
      showMsg(
        msg: "خطا در پشتیبان‌گیری",
        context: context,
        type: "error",
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Card _createBackuopInfoWidget() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'پشتیبان‌گیری از اطلاعات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'یک نسخه پشتیبان از تمام اطلاعات برنامه ایجاد کنید',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createBackup,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.backup),
              label: Text(
                  _isLoading ? 'در حال پشتیبان‌گیری...' : 'تهیه نسخه پشتیبان'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _restoreInfoWidget() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'بازیابی اطلاعات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'بازیابی از فایل .sql یا بکاپ روزانه .sql.zip',
              style: TextStyle(color: Colors.grey),
            ),
            if (_fileName != null) ...[
              const SizedBox(height: 8),
              Text(
                'فایل انتخاب‌شده: $_fileName',
                style: const TextStyle(fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUploading == false ? _selectBackupFile : null,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('انتخاب فایل'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadBackup,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.restore),
                    label: Text(_isUploading ? 'در حال بازیابی...' : 'بازیابی'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _selectBackupFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['sql', 'zip'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _fileBytes = result.files.single.bytes;
        _fileName = result.files.single.name;
      });
    } else {
      if (!mounted) return;
      showMsg(msg: "فایل پشتیبان را انتخاب کنید", context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('پشتیبان‌گیری و بازیابی'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _content(context),
                ],
              ),
            ),
          )),
    );
  }

  _uploadBackup() async {
    if (_fileBytes == null || _fileName == null) {
      showMsg(msg: "فایل پشتیبان را انتخاب کنید", context: context);
      return;
    }
    EasyLoading.show();
    setState(() => _isUploading = true);
    try {
      FormData formData = FormData.fromMap({
        "backup_file": MultipartFile.fromBytes(
          _fileBytes!,
          filename: _fileName,
        ),
      });

      final val = await restoreBackup(formData: formData);
      if (!mounted) return;

      if (val) {
        showMsg(msg: "بازیابی انجام شد", context: context);
      } else {
        showMsg(msg: "خطایی رخ داده است", context: context, type: "error");
      }
    } catch (_) {
      if (!mounted) return;
      showMsg(msg: "خطایی رخ داده است", context: context, type: "error");
    } finally {
      EasyLoading.dismiss();
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
}
