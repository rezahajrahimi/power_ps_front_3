import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/repositories/custom_text_repository.dart'
    as custom_text_repository;
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

  @override
  void initState() {
    super.initState();
    _isJsonFormat = widget.isJsonFormat;
    String initialText = widget.customTextModel.customText.isNotEmpty
        ? widget.customTextModel.customText
        : widget.customTextModel.defaultText;

    // اضافه کردن تشخیص خودکار فرمت JSON
    if (initialText.startsWith('[') && initialText.endsWith(']')) {
      try {
        initialText = CustomTextModel(
          id: BigInt.from(0),
          defaultText: '',
          key: '',
          customText: initialText,
        ).parseFormattedText({});
        _isJsonFormat = false;
      } catch (e) {
        // در صورت خطا، متن اصلی را نمایش می‌دهیم
        debugPrint('Error parsing JSON: $e');
      }
    }

    _controller = TextEditingController(text: initialText);
  }

  void _formatSelection(String type) {
    final TextSelection selection = _controller.selection;
    if (!selection.isValid) return;

    String selectedText = _controller.text.substring(
      selection.start,
      selection.end,
    );
    String newText;

    switch (type) {
      case 'bold':
        newText = '**$selectedText**';
        break;
      case 'italic':
        newText = '*$selectedText*';
        break;
      case 'code':
        newText = '`$selectedText`';
        break;
      case 'link':
        _showLinkDialog(selectedText);
        return;
      case 'newLine':
        newText = '\n';
        break;
      default:
        return;
    }

    final int cursorPosition = selection.start;
    _controller.text = _controller.text.replaceRange(
      selection.start,
      selection.end,
      newText,
    );

    // تنظیم موقعیت کرسر بعد از فرمت‌گذاری
    _controller.selection = TextSelection(
      baseOffset: cursorPosition,
      extentOffset: cursorPosition + newText.length,
    );

    widget.onTextChanged(_controller.text);
  }

  Future<void> _showLinkDialog(String selectedText) async {
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
              final String newText = '[$selectedText]($url)';
              final TextSelection selection = _controller.selection;
              _controller.text = _controller.text.replaceRange(
                selection.start,
                selection.end,
                newText,
              );
              widget.onTextChanged(_controller.text);
            },
            child: const Text('تایید'),
          ),
        ],
      ),
    );
  }

  void _toggleFormat() {
    setState(() {
      if (_isJsonFormat) {
        // تبدیل JSON به مارک‌داون
        try {
          final String markdownText = CustomTextModel(
            id: BigInt.from(0),
            defaultText: '',
            key: '',
            customText: _controller.text,
          ).parseFormattedText({});
          _controller.text = markdownText;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطا در تبدیل فرمت JSON')),
          );
          return;
        }
      } else {
        // تبدیل مارک‌داون به JSON
        try {
          final String jsonText =
              CustomTextModel.convertMarkdownToJsonText(_controller.text);
          _controller.text = jsonText;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطا در تبدیل فرمت مارک‌داون')),
          );
          return;
        }
      }
      _isJsonFormat = !_isJsonFormat;
      widget.onTextChanged(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
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
              TextButton.icon(
                onPressed: _toggleFormat,
                icon: const Icon(Icons.swap_horiz),
                label: Text(
                    _isJsonFormat ? 'تبدیل به مارک‌داون' : 'تبدیل به JSON'),
              ),
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
            ],
          ),
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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveText() async {
    if (_controller.text.isEmpty) {
      EasyLoading.showError('متن خالی است');
      return;
    }
    // chcek is json format
    if (_isJsonFormat) {
      // make _controller.text json valid
      _controller.text =
          CustomTextModel.convertMarkdownToJsonText(_controller.text);
    }
    EasyLoading.show(status: 'ذخیره سازی...');
    await custom_text_repository
        .updateCustomText(
            key: widget.customTextModel.key, text: _controller.text)
        .then((value) {
      if (value) {
        EasyLoading.showSuccess('متن با موفقیت ذخیره شد');
      } else {
        EasyLoading.showError('خطا در ذخیره متن');
      }
    });
  }

  void _resetText() {
    _controller.text = widget.customTextModel.defaultText;
  }
}
