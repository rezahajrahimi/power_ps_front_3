import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/repositories/setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class AdvancedSettingChoiceWidget extends StatefulWidget {
  const AdvancedSettingChoiceWidget({
    super.key,
    required this.description,
    required this.name,
    required this.value,
    required this.options,
  });

  final String description;
  final String name;
  final String value;
  final Map<String, String> options;

  @override
  State<AdvancedSettingChoiceWidget> createState() =>
      _AdvancedSettingChoiceWidgetState();
}

class _AdvancedSettingChoiceWidgetState extends State<AdvancedSettingChoiceWidget> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.options.containsKey(widget.value)
        ? widget.value
        : widget.options.keys.first;
  }

  Future<void> _save(String newValue) async {
    EasyLoading.show();
    final saved = await changeAdvancedSettingValue(
      name: widget.name,
      value: newValue,
    );
    EasyLoading.dismiss();

    if (!mounted) return;

    if (saved) {
      setState(() => _selectedValue = newValue);
      showMsg(msg: 'ذخیره شد', context: context);
    } else {
      showMsg(msg: 'خطا در ذخیره سازی', context: context, type: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          width: 1,
          color: AppStyle.primaryColor.withValues(alpha: 0.1),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppStyle.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.view_list_outlined,
                  color: AppStyle.primaryColor,
                  size: 20,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppStyle.defaultPadding,
                  ),
                  child: Text(
                    widget.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding),
          DropdownButtonFormField<String>(
            value: _selectedValue,
            isExpanded: true,
            dropdownColor: AppStyle.secondaryColor,
            selectedItemBuilder: (context) => widget.options.entries
                .map(
                  (entry) => Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      entry.value,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
                .toList(),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppStyle.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppStyle.primaryColor.withValues(alpha: 0.2),
                ),
              ),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            items: widget.options.entries
                .map(
                  (entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null || value == _selectedValue) return;
              _save(value);
            },
          ),
        ],
      ),
    );
  }
}
