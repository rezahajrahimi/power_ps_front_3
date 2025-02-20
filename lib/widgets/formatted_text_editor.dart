import 'package:flutter/material.dart';
import '../models/custom_text_model.dart';

class FormattedTextEditor extends StatefulWidget {
  final String initialText;
  final Function(String) onTextChanged;
  final bool isJsonFormat;

  const FormattedTextEditor({
    super.key,
    this.initialText = '',
    required this.onTextChanged,
    this.isJsonFormat = false,
  });

  @override
  State<FormattedTextEditor> createState() => _FormattedTextEditorState();
}

class _FormattedTextEditorState extends State<FormattedTextEditor> {
  late TextEditingController _controller;
  late bool _isJsonFormat;

  @override
  void initState() {
    super.initState();
    _isJsonFormat = widget.isJsonFormat;
    _controller = TextEditingController(text: widget.initialText);
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
        // نمایش دیالوگ برای دریافت URL
        _showLinkDialog(selectedText);
        return;
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
              const Spacer(),
              TextButton.icon(
                onPressed: _toggleFormat,
                icon: const Icon(Icons.swap_horiz),
                label: Text(
                    _isJsonFormat ? 'تبدیل به مارک‌داون' : 'تبدیل به JSON'),
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
}
