import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
  bool _isLoading = false;
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
              onPressed: _isLoading
                  ? null
                  : () async {
                      showMsg(
                          msg: "در حال پشتیبان‌گیری از اطلاعات...",
                          context: context);
                      setState(() => _isLoading = true);
                      await createBackup().then((val) {
                        if (val != null) {
                          // open val in browser
                          launchUrl(Uri.parse(val));
                          setState(() => _isLoading = false);
                        } else {
                          if (!mounted) return;
                          showMsg(
                              msg: "خطایی رخ داده است",
                              context: context,
                              type: "error");
                          setState(() => _isLoading = false);
                        }
                      });
                    },
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
              'بازیابی اطلاعات از آخرین نسخه پشتیبان',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _uploadBackup,
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
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() => _isLoading = true);
                            // TODO: اضافه کردن منطق بازیابی
                            await Future.delayed(
                                const Duration(seconds: 2)); // شبیه‌سازی
                            setState(() => _isLoading = false);
                          },
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.restore),
                    label: Text(_isLoading ? 'در حال بازیابی...' : 'بازیابی'),
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

  _uploadBackup() async {
    // select file from storage witch extension is .sql
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      debugPrint("file=>${file.path}");
      // upload file to server
      // create a form data
      FormData formData = FormData.fromMap({
        "backup_file": await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
      });
      setState(() => _isLoading = true);

      // upload file to server
      restoreBackup(formData: formData).then((val) {
        if (!mounted) return;
        if (val != false) {
          showMsg(msg: "بازیابی انجام شد", context: context);
        } else {
          showMsg(msg: "خطایی رخ داده است", context: context, type: "error");
        }
      });
    }
    setState(() => _isLoading = false);
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
}
