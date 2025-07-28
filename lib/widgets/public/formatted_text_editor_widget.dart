// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/repositories/custom_text_repository.dart'
    as custom_text_repository;
import 'package:powerps/styles/app_theme.dart';
import 'dart:convert';
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
  late bool _isJsonFormat;
  late CustomTextModel _customTextModel;
  List<Map<String, dynamic>> _blocks = [];

  @override
  void initState() {
    super.initState();
    _isJsonFormat = true;
    _customTextModel = widget.customTextModel;
    String initialText = widget.customTextModel.customText.isNotEmpty
        ? widget.customTextModel.customText
        : widget.customTextModel.defaultText;

    // اگر داده JSON است، پارس کن و در _blocks بریز
    if (initialText.trim().startsWith('[') &&
        initialText.trim().endsWith(']')) {
      try {
        _blocks = List<Map<String, dynamic>>.from(
            (CustomTextModel.decodeJsonBlocks(initialText)));
        _controller = TextEditingController(text: _blocksToDisplayText());
      } catch (e) {
        debugPrint('Error parsing JSON: $e');
        _blocks = [];
        _controller = TextEditingController(text: initialText);
      }
    } else {
      // اگر متن ساده است، یک بلاک متنی بساز
      _blocks = [
        {'type': 'text', 'text': initialText}
      ];
      _controller = TextEditingController(text: initialText);
    }
  }

  void _formatSelection(String type) async {
    final TextSelection selection = _controller.selection;
    String selectedText = selection.isValid
        ? _controller.text.substring(selection.start, selection.end)
        : '';

    if (selection.isValid && selectedText.isNotEmpty) {
      // متن قبل، انتخاب‌شده و بعد را جدا کن
      String before = _controller.text.substring(0, selection.start);
      String after = _controller.text.substring(selection.end);

      // بلاک جدید با استایل مناسب بساز
      Map<String, dynamic> newBlock;
      switch (type) {
        case 'bold':
          newBlock = {'type': 'bold', 'text': selectedText};
          break;
        case 'italic':
          newBlock = {'type': 'italic', 'text': selectedText};
          break;
        case 'code':
          newBlock = {'type': 'code', 'text': selectedText};
          break;
        case 'link':
          String url = await _showLinkDialog(selectedText);
          if (url.isEmpty) return;
          newBlock = {'type': 'link', 'text': selectedText, 'url': url};
          break;
        case 'newLine':
          newBlock = {'type': 'newline'};
          break;
        default:
          return;
      }

      // بلاک‌های جدید را بساز
      List<Map<String, dynamic>> newBlocks = [];
      if (before.isNotEmpty) newBlocks.add({'type': 'text', 'text': before});
      newBlocks.add(newBlock);
      if (after.isNotEmpty) newBlocks.add({'type': 'text', 'text': after});

      setState(() {
        _blocks = newBlocks;
        _controller.text = _blocksToDisplayText();
        // کرسر را بعد از بلاک جدید قرار بده
        int cursorPos =
            before.length + _blocksToDisplayText().length - after.length;
        _controller.selection = TextSelection.collapsed(offset: cursorPos);
      });
      widget.onTextChanged(_controller.text);
    } else {
      // اگر متنی انتخاب نشده بود، بلاک جدید به انتها اضافه شود
      Map<String, dynamic> newBlock;
      switch (type) {
        case 'bold':
          newBlock = {'type': 'bold', 'text': 'متن پررنگ'};
          break;
        case 'italic':
          newBlock = {'type': 'italic', 'text': 'متن مورب'};
          break;
        case 'code':
          newBlock = {'type': 'code', 'text': 'کد'};
          break;
        case 'link':
          String url = await _showLinkDialog('لینک');
          if (url.isEmpty) return;
          newBlock = {'type': 'link', 'text': 'لینک', 'url': url};
          break;
        case 'newLine':
          newBlock = {'type': 'newline'};
          break;
        default:
          return;
      }
      setState(() {
        _blocks.add(newBlock);
        _controller.text = _blocksToDisplayText();
        _controller.selection =
            TextSelection.collapsed(offset: _controller.text.length);
      });
      widget.onTextChanged(_controller.text);
    }
  }

  Future<String> _showLinkDialog(String selectedText) async {
    String url = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('افزودن لینک'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'آدرس لینک را وارد کنید',
            labelText: 'URL',
          ),
          onChanged: (value) => url = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('تایید'),
          ),
        ],
      ),
    );
    return url;
  }

  // void _addBlock(Map<String, dynamic> block) {
  //   setState(() {
  //     _blocks.add(block);
  //   });
  // }

  String _blocksToDisplayText() {
    // فقط برای نمایش ساده، می‌توانید این را با توجه به نیاز خود تغییر دهید
    return _blocks.map((b) {
      switch (b['type']) {
        case 'bold':
          return ' **${b['text'] ?? ''}** ';
        case 'italic':
          return ' *${b['text'] ?? ''}* ';
        case 'code':
          return ' `${b['text'] ?? ''}` ';
        case 'link':
          return ' [${b['text'] ?? ''}](${b['url'] ?? ''}) ';
        case 'newline':
          return '\n';
        case 'text':
        default:
          return b['text'] ?? '';
      }
    }).join('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(
            width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
        borderRadius: BorderRadius.all(
          Radius.circular(AppStyle.defaultPadding),
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Text(
              widget.customTextModel.key,
              style: AppStyle.thirdTitleStyle,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.format_bold),
                onPressed: () => _formatSelection('bold'),
                tooltip: 'پررنگ',
              ),
              IconButton(
                icon: const Icon(Icons.format_italic),
                onPressed: () => _formatSelection('italic'),
                tooltip: 'مورب',
              ),
              IconButton(
                icon: const Icon(Icons.code),
                onPressed: () => _formatSelection('code'),
                tooltip: 'کد',
              ),
              IconButton(
                icon: const Icon(Icons.link),
                onPressed: () => _formatSelection('link'),
                tooltip: 'لینک',
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_return),
                onPressed: () => _formatSelection('newLine'),
                tooltip: 'خط جدید',
              ),
              const Spacer(),
              // IconButton(
              //   onPressed: _toggleFormat,
              //   icon: const Icon(Icons.swap_horiz),
              //   // label: Text(
              //   //     _isJsonFormat ? 'تبدیل به مارک‌داون' : 'تبدیل به JSON'),
              // ),
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _saveText(),
                tooltip: 'ذخیره',
              ),
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () => _resetText(),
                tooltip: 'متن پیش فرض',
              ),
              IconButton(
                icon: const Icon(Icons.info),
                onPressed: () => _showDescription(),
                tooltip: 'توضیحات',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'متن خود را وارد کنید...',
              ),
              onChanged: widget.onTextChanged,
            ),
          ),
        ],
      ),
    );
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
    // همیشه متن فعلی را به بلاک تبدیل کن
    List<Map<String, dynamic>> blocks = List<Map<String, dynamic>>.from(
        json.decode(CustomTextModel.convertMarkdownToJsonText(text)));
    String jsonText = CustomTextModel.encodeJsonBlocks(blocks);
    EasyLoading.show(status: 'ذخیره سازی...');
    await custom_text_repository
        .updateCustomText(key: _customTextModel.key, text: jsonText)
        .then((value) {
      if (value) {
        EasyLoading.showSuccess('متن با موفقیت ذخیره شد');
      } else {
        EasyLoading.showError('خطا در ذخیره متن');
      }
    });
  }

  void _resetText() {
    String defaultText = widget.customTextModel.defaultText;
    if (defaultText.trim().startsWith('[') &&
        defaultText.trim().endsWith(']')) {
      try {
        _blocks = List<Map<String, dynamic>>.from(
            (CustomTextModel.decodeJsonBlocks(defaultText)));
        _controller.text = _blocksToDisplayText();
      } catch (e) {
        debugPrint('Error parsing JSON: $e');
        _blocks = [];
        _controller.text = defaultText;
      }
    } else {
      _blocks = [
        {'type': 'text', 'text': defaultText}
      ];
      _controller.text = defaultText;
    }
    setState(() {});
  }

  void _showDescription() {
    // show dialog with description with close button
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.customTextModel.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }
}
