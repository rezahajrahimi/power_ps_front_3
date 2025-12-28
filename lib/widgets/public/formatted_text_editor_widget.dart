// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/repositories/custom_text_repository.dart'
    as custom_text_repository;
import 'package:powerps/styles/app_theme.dart';
import '../../models/custom_text_model.dart';

class FormattedTextEditorWidget extends StatefulWidget {
  final CustomTextModel customTextModel;
  final Function(String) onTextChanged;
  final bool isJsonFormat;

  const FormattedTextEditorWidget({
    super.key,
    required this.customTextModel,
    required this.onTextChanged,
    this.isJsonFormat = false,
  });

  @override
  State<FormattedTextEditorWidget> createState() =>
      _FormattedTextEditorWidgetState();
}

class _FormattedTextEditorWidgetState extends State<FormattedTextEditorWidget> {
  late TextEditingController _controller;
  late CustomTextModel _customTextModel;
  bool _isPreview = false;

  @override
  void initState() {
    super.initState();
    _customTextModel = widget.customTextModel;
    String initialText = widget.customTextModel.customText.isNotEmpty
        ? widget.customTextModel.customText
        : widget.customTextModel.defaultText;

    // اگر داده JSON است، پارس کن و به مارک‌داون تبدیل کن
    if (initialText.trim().startsWith('[') &&
        initialText.trim().endsWith(']')) {
      try {
        List<Map<String, dynamic>> blocks = List<Map<String, dynamic>>.from(
            (CustomTextModel.decodeJsonBlocks(initialText)));
        _controller = TextEditingController(text: _blocksToMarkdown(blocks));
      } catch (e) {
        debugPrint('Error parsing JSON: $e');
        _controller = TextEditingController(text: initialText);
      }
    } else {
      _controller = TextEditingController(text: initialText);
    }
  }

  String _blocksToMarkdown(List<Map<String, dynamic>> blocks) {
    StringBuffer result = StringBuffer();
    for (var b in blocks) {
      switch (b['type']) {
        case 'bold':
          result.write('**${b['text'] ?? ''}**');
          break;
        case 'italic':
          result.write('*${b['text'] ?? ''}*');
          break;
        case 'code':
          result.write('`${b['text'] ?? ''}`');
          break;
        case 'link':
          result.write('[${b['text'] ?? ''}](${b['url'] ?? ''})');
          break;
        case 'newline':
          result.write('\n');
          break;
        case 'text':
        default:
          result.write(b['text'] ?? '');
          break;
      }
    }
    return result.toString();
  }

  void _insertMarkdown(String prefix, String suffix, {String? defaultText}) {
    final selection = _controller.selection;
    final text = _controller.text;

    if (selection.isValid) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix${selectedText.isEmpty ? (defaultText ?? "") : selectedText}$suffix',
      );
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start +
              prefix.length +
              (selectedText.isEmpty
                  ? (defaultText?.length ?? 0)
                  : selectedText.length) +
              suffix.length,
        ),
      );
    } else {
      final newText = '$text$prefix${defaultText ?? ""}$suffix';
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
    widget.onTextChanged(_controller.text);
    setState(() {});
  }

  void _insertVariable(String variable) {
    _insertMarkdown('{$variable}', '');
  }

  Future<void> _showLinkDialog() async {
    final selection = _controller.selection;
    String selectedText = selection.isValid
        ? _controller.text.substring(selection.start, selection.end)
        : '';

    String text = selectedText.isEmpty ? 'متن لینک' : selectedText;
    String url = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('افزودن لینک'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'متن نمایش'),
              controller: TextEditingController(text: text),
              onChanged: (v) => text = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'آدرس (URL)'),
              onChanged: (v) => url = v,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو')),
          TextButton(
            onPressed: () {
              if (url.isNotEmpty) {
                _insertMarkdown('[$text](', ')', defaultText: url);
              }
              Navigator.pop(context);
            },
            child: const Text('تایید'),
          ),
        ],
      ),
    );
  }

  void _showVariablePicker() {
    final List<String> commonVariables = [
      'user_name',
      'user_id',
      'first_name',
      'last_name',
      'order_id',
      'amount',
      'date',
      'time',
      'wallet_balance',
      'support_id',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('انتخاب متغیر',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: commonVariables
                  .map((v) => ActionChip(
                        label: Text('{$v}'),
                        onPressed: () {
                          _insertVariable(v);
                          Navigator.pop(context);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'نام متغیر دلخواه...',
                suffixIcon: Icon(Icons.add),
              ),
              onSubmitted: (v) {
                if (v.isNotEmpty) {
                  _insertVariable(v);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _togglePreview() {
    setState(() {
      _isPreview = !_isPreview;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        border:
            Border.all(width: 1, color: AppStyle.primaryColor.withAlpha(20)),
        borderRadius: BorderRadius.all(
          Radius.circular(AppStyle.defaultPadding),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.customTextModel.key,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (widget.customTextModel.description.isNotEmpty)
                      Text(
                        widget.customTextModel.description,
                        style: TextStyle(
                            fontSize: 12, color: Colors.white.withAlpha(60)),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_isPreview ? Icons.edit : Icons.visibility),
                onPressed: _togglePreview,
                tooltip: _isPreview ? 'ویرایش' : 'پیش‌نمایش',
              ),
              IconButton(
                icon: const Icon(Icons.save, color: Colors.green),
                onPressed: _saveText,
                tooltip: 'ذخیره',
              ),
            ],
          ),
          const Divider(),
          if (!_isPreview) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _toolButton(
                      Icons.format_bold,
                      () =>
                          _insertMarkdown('**', '**', defaultText: 'متن پررنگ'),
                      'پررنگ'),
                  _toolButton(
                      Icons.format_italic,
                      () => _insertMarkdown('*', '*', defaultText: 'متن مورب'),
                      'مورب'),
                  _toolButton(Icons.code,
                      () => _insertMarkdown('`', '`', defaultText: 'کد'), 'کد'),
                  _toolButton(Icons.link, _showLinkDialog, 'لینک'),
                  _toolButton(Icons.add_box, _showVariablePicker, 'متغیرها'),
                  _toolButton(Icons.keyboard_return,
                      () => _insertMarkdown('\n', ''), 'خط جدید'),
                  const SizedBox(width: 8),
                  _toolButton(Icons.restore, _resetText, 'بازنشانی',
                      color: Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 10,
              minLines: 3,
              style: const TextStyle(fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'متن خود را اینجا بنویسید...',
                fillColor: AppStyle.bgColor.withAlpha(50),
                filled: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: widget.onTextChanged,
            ),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppStyle.bgColor.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                _getPreviewText(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _toolButton(IconData icon, VoidCallback onPressed, String tooltip,
      {Color? color}) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      onPressed: onPressed,
      tooltip: tooltip,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  String _getPreviewText() {
    String markdown = _controller.text;
    // شبیه‌سازی جایگزینی متغیرها برای پیش‌نمایش
    Map<String, String> dummyVars = {
      'user_name': 'کاربر تست',
      'user_id': '12345678',
      'first_name': 'علی',
      'last_name': 'رضایی',
      'order_id': 'ORD-99',
      'amount': '50,000',
      'date': '1402/10/06',
      'time': '14:30',
      'wallet_balance': '100,000',
      'support_id': '@support',
    };

    String preview = markdown;
    dummyVars.forEach((key, value) {
      preview = preview.replaceAll('{$key}', value);
    });

    // حذف تگ‌های مارک‌داون برای نمایش ساده در پیش‌نمایش (چون ویجت نمایش مارک‌داون نداریم فعلا)
    preview =
        preview.replaceAll('**', '').replaceAll('*', '').replaceAll('`', '');
    // لینک‌ها: [text](url) -> text
    preview = preview.replaceAllMapped(
        RegExp(r'\[(.*?)\]\(.*?\)'), (match) => match.group(1)!);

    return preview;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveText() async {
    String text = _controller.text.trim();
    if (text.isEmpty) {
      EasyLoading.showError('متن خالی است');
      return;
    }

    String jsonText = CustomTextModel.convertMarkdownToJsonText(text);

    EasyLoading.show(status: 'در حال ذخیره...');
    try {
      bool success = await custom_text_repository.updateCustomText(
        key: _customTextModel.key,
        text: jsonText,
      );
      if (success) {
        EasyLoading.showSuccess('با موفقیت ذخیره شد');
      } else {
        EasyLoading.showError('خطا در ذخیره');
      }
    } catch (e) {
      EasyLoading.showError('خطای غیرمنتظره: $e');
    }
  }

  void _resetText() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('بازنشانی متن'),
        content: const Text(
            'آیا مطمئن هستید که می‌خواهید متن را به حالت پیش‌فرض برگردانید؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو')),
          TextButton(
            onPressed: () {
              String defaultText = widget.customTextModel.defaultText;
              if (defaultText.trim().startsWith('[') &&
                  defaultText.trim().endsWith(']')) {
                try {
                  List<Map<String, dynamic>> blocks =
                      List<Map<String, dynamic>>.from(
                          (CustomTextModel.decodeJsonBlocks(defaultText)));
                  _controller.text = _blocksToMarkdown(blocks);
                } catch (e) {
                  _controller.text = defaultText;
                }
              } else {
                _controller.text = defaultText;
              }
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('تایید'),
          ),
        ],
      ),
    );
  }
}
