import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/models/agent_limit_usage_model.dart';
import 'package:powerps/models/agent_permisson_model.dart';
import 'package:powerps/models/ballance_model.dart';
import 'package:powerps/models/bought_product_details_model.dart';
import 'package:powerps/models/log_model.dart';

class AgentDashboard {
  Ballance? ballance;
  List<AgentAddCategoriyModel>? agentProducts;
  List<BoughtProductDetailsModel>? boughtProducts;
  List<Log>? logs = [];
  AgentPermisson? permission;
  AgentLimitUsage? limitUsage;

  AgentDashboard({
    required this.ballance,
    required this.agentProducts,
    required this.boughtProducts,
    required this.logs,
    this.permission,
    this.limitUsage,
  });
}
