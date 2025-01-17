import 'package:flutter/material.dart';
import 'package:powerps/models/hiffify_config_model.dart';

class PannelChangeController extends ChangeNotifier {
  bool _changed = false;

  bool get changed => _changed;
  final List<HiddifyConfig> _obtinedConfigList = [];
  List<HiddifyConfig> get obtinedConfigList => _obtinedConfigList;
  void rebuildPanelData(bool changed) {
    _changed = changed;
    notifyListeners(); // Notify listeners of the state change
  }

  bool addNewConfig(HiddifyConfig config) {
    _obtinedConfigList.add(config);
    notifyListeners(); // Notify listeners of the state change
    return true;
  }

  bool removeConfig(HiddifyConfig config) {
    _obtinedConfigList.remove(config);
    notifyListeners(); // Notify listeners of the state change
    return true;
  }

  bool checkIsConfigExist(HiddifyConfig config) {
    if (_obtinedConfigList.contains(config)) {
      return true;
    } else {
      return false;
    }
  }

  bool clearConfigList() {
    _obtinedConfigList.clear();
    notifyListeners(); // Notify listeners of the state change
    return true;
  }
}
