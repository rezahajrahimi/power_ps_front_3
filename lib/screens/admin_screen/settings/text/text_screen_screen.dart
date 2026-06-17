import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/custom_text_model.dart';
import 'package:powerps/repositories/custom_text_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/formatted_text_editor_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class TextScreenScreen extends StatefulWidget {
  final String? initialSearch;

  const TextScreenScreen({super.key, this.initialSearch});

  @override
  State<TextScreenScreen> createState() => _TextScreenScreenState();
}

class _TextScreenScreenState extends State<TextScreenScreen> {
  bool _showData = false;
  List<CustomTextModel> _customTextModelList = [];
  late String _searchQuery;
  late final TextEditingController _searchController;
  bool _loading = false;

  @override
  void initState() {
    _searchQuery = widget.initialSearch ?? '';
    _searchController = TextEditingController(text: _searchQuery);
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fillData() async {
    try {
      setState(() {
        _loading = true;
        _showData = false;
      });
      final value = await getCustomTexts();
      if (mounted) {
        setState(() {
          _customTextModelList = value;
          _showData = true;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _showData = true;
        });
      }
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

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      );

  Widget _searchField() {
    return TextField(
      controller: _searchController,
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
    );
  }

  Widget _list() {
    if (_loading && _customTextModelList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_filteredList.isEmpty) {
      return const Center(child: Text('موردی یافت نشد'));
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
      itemCount: _filteredList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppStyle.defaultPadding),
          child: FormattedTextEditorWidget(
            key: ValueKey(_filteredList[index].id),
            customTextModel: _filteredList[index],
            onTextChanged: (String newText) {},
          ),
        );
      },
    );
  }

  Widget _operationCard() {
    final total = _customTextModelList.length;
    final filtered = _filteredList.length;
    final isFiltering = _searchQuery.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: AppStyle.primaryColor),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'عملیات',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'به‌روزرسانی',
                onPressed: _loading ? null : _fillData,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            'کل پیام‌ها: $total',
            style: TextStyle(color: AppStyle.deactiveStatus),
          ),
          Text(
            isFiltering ? 'نتایج فیلتر: $filtered' : 'نمایش همه موارد',
            style: TextStyle(color: AppStyle.deactiveStatus),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: isFiltering
                ? () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  }
                : null,
            icon: const Icon(Icons.clear),
            label: const Text('پاک کردن فیلتر'),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppStyle.bgColor.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'نکته: کلیدها را دقیق و یکنواخت نگه دارید تا نگهداری ربات ساده‌تر شود.',
              style: TextStyle(color: AppStyle.deactiveStatus, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    final content = Column(
      children: [
        Padding(
          padding: EdgeInsets.all(AppStyle.defaultPadding),
          child: _searchField(),
        ),
        Expanded(child: _list()),
      ],
    );

    if (Responsive.isMobile(context)) return content;

    return Padding(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Container(
              decoration: _cardDecoration,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppStyle.defaultPadding),
                    child: _searchField(),
                  ),
                  Expanded(child: _list()),
                ],
              ),
            ),
          ),
          SizedBox(width: AppStyle.defaultPadding),
          Expanded(flex: 2, child: _operationCard()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
              context: context, title: "مدیریت پیام‌های ربات"),
          body: _showData ? _body(context) : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
