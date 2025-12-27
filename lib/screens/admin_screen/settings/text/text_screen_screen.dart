import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/custom_text_model.dart';
import 'package:powerps/repositories/custom_text_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/formatted_text_editor_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class TextScreenScreen extends StatefulWidget {
  const TextScreenScreen({super.key});

  @override
  State<TextScreenScreen> createState() => _TextScreenScreenState();
}

class _TextScreenScreenState extends State<TextScreenScreen> {
  bool _showData = false;
  List<CustomTextModel> _customTextModelList = [];
  String _searchQuery = '';

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  void _fillData() async {
    try {
      final value = await getCustomTexts();
      if (mounted) {
        setState(() {
          _customTextModelList = value;
          _showData = true;
        });
      }
    } catch (e) {
      debugPrint('Error fetching texts: $e');
    }
  }

  List<CustomTextModel> get _filteredList {
    if (_searchQuery.isEmpty) return _customTextModelList;
    return _customTextModelList
        .where((element) =>
            element.key.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            element.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBarWithBackButton(
            context: context, title: "مدیریت پیام‌های ربات"),
        body: SafeArea(
          child: _showData
              ? Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(AppStyle.defaultPadding),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'جستجو در کلیدها یا توضیحات...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppStyle.secondaryColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _filteredList.isEmpty
                          ? const Center(child: Text('موردی یافت نشد'))
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppStyle.defaultPadding),
                              itemCount: _filteredList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: AppStyle.defaultPadding),
                                  child: FormattedTextEditorWidget(
                                    key: ValueKey(_filteredList[index].id),
                                    customTextModel: _filteredList[index],
                                    onTextChanged: (String newText) {},
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
