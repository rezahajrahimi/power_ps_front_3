import 'package:flutter/material.dart';
import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/models/agent_dashboard_model.dart';

class AgentProvider extends ChangeNotifier {
  bool _changed = false;
  bool get changed => _changed;

  List<AgentAddCategoriyModel> _agentCategories = [];
  List<AgentAddCategoriyModel> get agentCategories => _agentCategories;

  List<AgentAddCategoriyModel> _agentCategoriesAdded = [];
  List<AgentAddCategoriyModel> get agentCategoriesAdded =>
      _agentCategoriesAdded;
  AgentDashboard _agentDashboard = AgentDashboard(
      ballance: null, agentProducts: null, boughtProducts: null, logs: null);
  AgentDashboard get agentDashboard => _agentDashboard;
  void setChanged(bool change) {
    _changed = change;
    notifyListeners();
  }

  setAgentCategories(List<AgentAddCategoriyModel> agentCategories) {
    _agentCategories = agentCategories;
    _changed = true;
    notifyListeners();
  }

  getAgentCategories() {
    return _agentCategories;
  }

  clearAgentCategories() {
    _agentCategories = [];
    _changed = true;
    notifyListeners();
  }

  addNewProductAgent(AgentAddCategoriyModel productCategory) {
    _agentCategories.add(productCategory);
    _changed = true;
    notifyListeners();
  }

  removeProductAgent(AgentAddCategoriyModel productCategory) {
    final index = _agentCategories.indexOf(productCategory);
    _agentCategories.removeAt(index);

    _changed = true;
    notifyListeners();
  }

  updateProductAgent(AgentAddCategoriyModel productCategory) {
    _agentCategories[_agentCategories.indexOf(productCategory)] =
        productCategory;
    _changed = true;
    notifyListeners();
  }

  setAgentCategoriesAdded(List<AgentAddCategoriyModel> agentCategoriesAdded) {
    _agentCategoriesAdded = agentCategoriesAdded;
    _changed = true;
    notifyListeners();
  }

  getAgentCategoriesAdded() {
    return _agentCategoriesAdded;
  }

  clearAgentCategoriesAdded() {
    _agentCategoriesAdded = [];
    _changed = true;
    notifyListeners();
  }

  addNewProductAgentAded(AgentAddCategoriyModel productCategory) {
    _agentCategoriesAdded.add(productCategory);
    _changed = true;
    notifyListeners();
  }

  removeProductAgentAded(AgentAddCategoriyModel productCategory) {
    final index = _agentCategoriesAdded.indexOf(productCategory);
    _agentCategoriesAdded.removeAt(index);

    _changed = true;
    notifyListeners();
  }

  updateProductAgentAded(AgentAddCategoriyModel productCategory) {
    _agentCategoriesAdded[_agentCategoriesAdded.indexOf(productCategory)] =
        productCategory;
    _changed = true;
    notifyListeners();
  }

  setNewAgentDashboardData(AgentDashboard agentDashboard) {
    _agentDashboard = agentDashboard;
    notifyListeners();
  }
}
