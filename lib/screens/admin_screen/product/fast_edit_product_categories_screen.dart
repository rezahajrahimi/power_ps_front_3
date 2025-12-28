import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/product_category/fast_editable_product_category_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class FastEditProductCategoriesScreen extends StatefulWidget {
  const FastEditProductCategoriesScreen(
      {super.key, required this.productCategoryList});
  final List<ProductCategory> productCategoryList;

  @override
  State<FastEditProductCategoriesScreen> createState() =>
      _FastEditProductCategoriesScreenState();
}

class _FastEditProductCategoriesScreenState
    extends State<FastEditProductCategoriesScreen> {
  late List<ProductCategory> _allCategories;
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    _allCategories = widget.productCategoryList;
    super.initState();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      final updatedList = await getAllProdctCategory();
      if (updatedList is List<ProductCategory>) {
        setState(() {
          _allCategories = updatedList;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<ProductCategory> get _filteredList {
    if (_searchQuery.isEmpty) return _allCategories;
    return _allCategories.where((cat) {
      final name = cat.categoryName.toLowerCase();
      final location = (cat.pannel?.location ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || location.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBarWithBackButton(
          context: context,
          title: "ویرایش سریع بسته‌ها",
          actions: [
            IconButton(
              onPressed: _refreshData,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh),
              tooltip: "بروزرسانی لیست",
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(isMobile ? 10 : AppStyle.defaultPadding),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'جستجو در نام بسته یا لوکیشن...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppStyle.secondaryColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            Expanded(
              child: _filteredList.isEmpty
                  ? const Center(child: Text("بسته‌ای یافت نشد"))
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 10 : AppStyle.defaultPadding),
                      itemCount: _filteredList.length,
                      itemBuilder: (context, index) {
                        return FastEditableProductCategoryWidget(
                          key: ValueKey(_filteredList[index].id),
                          productCategory: _filteredList[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
