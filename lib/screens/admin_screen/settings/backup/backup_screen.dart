import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  File? _file;
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
    // select file from storage witch extension is .sql
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
      // _file  = File(result.files.single.path!);
      // debugPrint("file=>${_file!.path}");
      // upload file to server
      // create a form data
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
    if (_file == null) {
      showMsg(msg: "فایل پشتیبان را انتخاب کنید", context: context);
      return;
    }
    EasyLoading.show();
    setState(() => _isUploading = true);
    FormData formData = FormData.fromMap({
      "backup_file": await MultipartFile.fromFile(_file!.path,
          filename: _file!.path.split('/').last),
    });

    // upload file to server
    restoreBackup(formData: formData).then((val) {
      if (!mounted) return;
      EasyLoading.dismiss();

      if (val != false) {
        showMsg(msg: "بازیابی انجام شد", context: context);
      } else {
        showMsg(msg: "خطایی رخ داده است", context: context, type: "error");
      }
    });
    setState(() => _isUploading = false);
  }
}
