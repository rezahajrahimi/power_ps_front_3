import 'package:flutter/material.dart';
import 'package:powerps/models/category_type_model.dart';
import 'package:powerps/repositories/category_type_repository.dart';

class CategoryTypeProvider extends ChangeNotifier {
  bool _initialized = false;
  List<CategoryTypeModel> _categoryTypeList = [];

  List<CategoryTypeModel> get categoryTypeList => _categoryTypeList;

  Future<void> init() async {
    if (_initialized) return;
    _categoryTypeList = await getAllCategoryType();
    _initialized = true;
    notifyListeners();
  }

  void setCategoryTypeList(List<CategoryTypeModel> categoryTypeList) {
    _categoryTypeList = categoryTypeList;
    notifyListeners();
  }

  void addCategoryType(CategoryTypeModel categoryType) {
    if (!_categoryTypeList.contains(categoryType)) {
      _categoryTypeList.add(categoryType);
    }
    notifyListeners();
  }

  void removeCategoryType(CategoryTypeModel categoryType) {
    if (_categoryTypeList.contains(categoryType)) {
      _categoryTypeList.remove(categoryType);
    }
    notifyListeners();
  }

  void updateCategoryType(CategoryTypeModel categoryType) {
    if (_categoryTypeList.contains(categoryType)) {
      _categoryTypeList.removeWhere((element) => element.id == categoryType.id);
      _categoryTypeList.add(categoryType);
    }
    notifyListeners();
  }
  void reFillData(){
    _initialized = false;
    init();
  }
}
