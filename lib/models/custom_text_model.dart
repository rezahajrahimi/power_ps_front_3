// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CustomTextModel {
  /// تبدیل لیست بلاک‌ها به رشته JSON
  static String encodeJsonBlocks(List<Map<String, dynamic>> blocks) {
    return json.encode(blocks);
  }

  /// تبدیل رشته JSON به لیست بلاک‌ها
  static List<Map<String, dynamic>> decodeJsonBlocks(String text) {
    final decoded = json.decode(text);
    if (decoded is List) {
      return List<Map<String, dynamic>>.from(
        decoded.map((e) => Map<String, dynamic>.from(e)),
      );
    } else {
      throw FormatException('JSON is not a List');
    }
  }

  BigInt id;
  String defaultText;
  String key;
  String customText;
  String description;

  CustomTextModel({
    required this.id,
    required this.defaultText,
    required this.key,
    required this.customText,
    required this.description,
  });

  factory CustomTextModel.fromJson(Map<String, dynamic> json) {
    return CustomTextModel(
      id: BigInt.parse(json['id'].toString()),
      defaultText: json['default_text'],
      key: json['key'],
      customText: json['custom_text'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id.toString(),
      'default_text': defaultText,
      'key': key,
      'custom_text': customText,
      'description': description,
    };
  }

  factory CustomTextModel.fromMap(Map<String, dynamic> map) {
    return CustomTextModel(
      id: BigInt.parse(map['id'].toString()),
      defaultText: map['default_text'] as String,
      key: map['key'] as String,
      customText: map['custom_text'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  String parseFormattedText(Map<String, dynamic> variables) {
    try {
      // اگر متن JSON باشد، آن را پردازش می‌کنیم
      List<dynamic> blocks = json.decode(customText);
      StringBuffer result = StringBuffer();

      for (var block in blocks) {
        String text = block['text'] ?? '';

        // جایگزینی متغیرها
        variables.forEach((key, value) {
          text = text.replaceAll('{$key}', value.toString());
        });

        // اعمال فرمت‌بندی بر اساس نوع بلوک
        switch (block['type']) {
          case 'bold':
            result.write('**$text**');
            break;
          case 'italic':
            result.write('*$text*');
            break;
          case 'link':
            result.write('[$text](${block['url']})');
            break;
          case 'newline':
            result.write('\n');
            break;
          case 'code':
            result.write('`$text`');
            break;
          case 'text':
          default:
            result.write(text);
            break;
        }
      }
      return result.toString();
    } catch (e) {
      // اگر متن JSON نباشد، متن اصلی را برمی‌گردانیم
      String text = customText;
      variables.forEach((key, value) {
        text = text.replaceAll('{$key}', value.toString());
      });
      return text;
    }
  }

  static String convertMarkdownToJsonText(String markdownText) {
    List<Map<String, dynamic>> blocks = [];
    RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    RegExp italicPattern = RegExp(r'\*(.*?)\*');
    RegExp linkPattern = RegExp(r'\[(.*?)\]\((.*?)\)');
    RegExp codePattern = RegExp(r'`(.*?)`');

    // متن را بر اساس خط جدید تقسیم می‌کنیم
    List<String> lines = markdownText.split('\n');

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      if (line.isEmpty) {
        blocks.add({'type': 'newline'});
        continue;
      }

      String remainingText = line;

      // پیدا کردن تمام الگوهای فرمت در خط
      while (remainingText.isNotEmpty) {
        // بررسی برای متن پررنگ
        Match? boldMatch = boldPattern.firstMatch(remainingText);
        // بررسی برای متن مورب
        Match? italicMatch = italicPattern.firstMatch(remainingText);
        // بررسی برای لینک
        Match? linkMatch = linkPattern.firstMatch(remainingText);
        // بررسی برای کد
        Match? codeMatch = codePattern.firstMatch(remainingText);

        Match? firstMatch;
        String type = '';
        int matchStart = remainingText.length;

        // پیدا کردن اولین الگوی منطبق
        if (boldMatch != null && boldMatch.start < matchStart) {
          firstMatch = boldMatch;
          type = 'bold';
          matchStart = boldMatch.start;
        }
        if (italicMatch != null && italicMatch.start < matchStart) {
          firstMatch = italicMatch;
          type = 'italic';
          matchStart = italicMatch.start;
        }
        if (linkMatch != null && linkMatch.start < matchStart) {
          firstMatch = linkMatch;
          type = 'link';
          matchStart = linkMatch.start;
        }
        if (codeMatch != null && codeMatch.start < matchStart) {
          firstMatch = codeMatch;
          type = 'code';
          matchStart = codeMatch.start;
        }

        // اگر متن قبل از الگو وجود دارد، آن را به عنوان متن ساده اضافه می‌کنیم
        if (firstMatch != null && firstMatch.start > 0) {
          blocks.add({
            'type': 'text',
            'text': remainingText.substring(0, firstMatch.start)
          });
        }

        if (firstMatch != null) {
          switch (type) {
            case 'bold':
              blocks.add({'type': 'bold', 'text': firstMatch.group(1)!});
              break;
            case 'italic':
              blocks.add({'type': 'italic', 'text': firstMatch.group(1)!});
              break;
            case 'link':
              blocks.add({
                'type': 'link',
                'text': firstMatch.group(1)!,
                'url': firstMatch.group(2)!
              });
              break;
            case 'code':
              blocks.add({'type': 'code', 'text': firstMatch.group(1)!});
              break;
          }
          remainingText = remainingText.substring(firstMatch.end);
        } else {
          // اگر هیچ الگویی پیدا نشد، کل متن باقیمانده را به عنوان متن ساده اضافه می‌کنیم
          if (remainingText.isNotEmpty) {
            blocks.add({'type': 'text', 'text': remainingText});
          }
          break;
        }
      }

      // اضافه کردن خط جدید بعد از هر خط به جز خط آخر
      if (i < lines.length - 1) {
        blocks.add({'type': 'newline'});
      }
    }

    return json.encode(blocks);
  }
}
