import 'package:flutter/foundation.dart';
import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/models/agent_dashboard_model.dart';
import 'package:powerps/models/bought_product_details_model.dart';

class AgentProvider extends ChangeNotifier {
  bool _notifyPending = false;

  /// همیشه اعلان را به microtask بعد از build فعلی موکول می‌کند.
  void _notify() {
    if (_notifyPending) return;
    _notifyPending = true;
    Future.microtask(() {
      _notifyPending = false;
      if (hasListeners) super.notifyListeners();
    });
  }

  bool _changed = false;
  bool get changed => _changed;

  List<AgentAddCategoriyModel> _agentCategories = [];
  List<AgentAddCategoriyModel> get agentCategories =>
      List.unmodifiable(_agentCategories);

  List<AgentAddCategoriyModel> _agentCategoriesAdded = [];
  List<AgentAddCategoriyModel> get agentCategoriesAdded =>
      List.unmodifiable(_agentCategoriesAdded);

  AgentDashboard _agentDashboard = AgentDashboard(
    ballance: null,
    agentProducts: null,
    boughtProducts: null,
    logs: null,
    permission: null,
  );
  AgentDashboard get agentDashboard => _agentDashboard;

  void setChanged(bool change) {
    _changed = change;
    _notify();
  }

  /// بارگذاری یک‌جای فرم بدون چند notify پشت‌سرهم
  void setFormCategories({
    required List<AgentAddCategoriyModel> available,
    required List<AgentAddCategoriyModel> added,
  }) {
    _agentCategories = List<AgentAddCategoriyModel>.from(available);
    _agentCategoriesAdded = List<AgentAddCategoriyModel>.from(added);
    _notify();
  }

  void resetFormCategories() {
    _agentCategories = [];
    _agentCategoriesAdded = [];
    _notify();
  }

  List<AgentAddCategoriyModel> getAgentCategories() => _agentCategories;

  List<AgentAddCategoriyModel> getAgentCategoriesAdded() =>
      _agentCategoriesAdded;

  void moveCategoryToAdded(AgentAddCategoriyModel item) {
    final index = _agentCategories.indexOf(item);
    if (index != -1) _agentCategories.removeAt(index);
    _agentCategoriesAdded.add(item);
    _notify();
  }

  void moveCategoryToAvailable(AgentAddCategoriyModel item) {
    final index = _agentCategoriesAdded.indexOf(item);
    if (index != -1) _agentCategoriesAdded.removeAt(index);
    _agentCategories.add(item.removeNewPricesValus());
    _notify();
  }

  void selectAllCategoriesWithDefaultPrice() {
    final toMove = List<AgentAddCategoriyModel>.from(_agentCategories);
    _agentCategories.clear();
    for (final item in toMove) {
      _agentCategoriesAdded.add(
        item.setNewPricesValus(
          newPrice: item.price,
          newPriceInDollar: item.priceInDollar,
        ),
      );
    }
    _notify();
  }

  /// به‌روزرسانی یک‌جای داشبورد
  void updateDashboard({
    required AgentDashboard dashboard,
    bool clearChanged = true,
  }) {
    _agentDashboard = dashboard;
    if (clearChanged) _changed = false;
    _notify();
  }

  void setBougthProductsToAgent(List<BoughtProductDetailsModel> boughtProducts) {
    _agentDashboard.boughtProducts = boughtProducts;
    _notify();
  }

  // --- متدهای قدیمی برای سازگاری؛ همه از _notify استفاده می‌کنند ---

  void setAgentCategories(List<AgentAddCategoriyModel> agentCategories) {
    _agentCategories = List<AgentAddCategoriyModel>.from(agentCategories);
    _notify();
  }

  void clearAgentCategories() {
    _agentCategories = [];
    _notify();
  }

  void addNewProductAgent(AgentAddCategoriyModel productCategory) {
    _agentCategories.add(productCategory);
    _notify();
  }

  void removeProductAgent(AgentAddCategoriyModel productCategory) {
    final index = _agentCategories.indexOf(productCategory);
    if (index == -1) return;
    _agentCategories.removeAt(index);
    _notify();
  }

  void updateProductAgent(AgentAddCategoriyModel productCategory) {
    final index = _agentCategories.indexOf(productCategory);
    if (index == -1) return;
    _agentCategories[index] = productCategory;
    _notify();
  }

  void setAgentCategoriesAdded(List<AgentAddCategoriyModel> agentCategoriesAdded) {
    _agentCategoriesAdded =
        List<AgentAddCategoriyModel>.from(agentCategoriesAdded);
    _notify();
  }

  void clearAgentCategoriesAdded() {
    _agentCategoriesAdded = [];
    _notify();
  }

  void addNewProductAgentAded(AgentAddCategoriyModel productCategory) {
    _agentCategoriesAdded.add(productCategory);
    _notify();
  }

  void removeProductAgentAded(AgentAddCategoriyModel productCategory) {
    final index = _agentCategoriesAdded.indexOf(productCategory);
    if (index == -1) return;
    _agentCategoriesAdded.removeAt(index);
    _notify();
  }

  void updateProductAgentAded(AgentAddCategoriyModel productCategory) {
    final index = _agentCategoriesAdded.indexOf(productCategory);
    if (index == -1) return;
    _agentCategoriesAdded[index] = productCategory;
    _notify();
  }

  @Deprecated('Use updateDashboard instead')
  void setNewAgentDashboardData(AgentDashboard agentDashboard) {
    updateDashboard(dashboard: agentDashboard, clearChanged: false);
  }
}
