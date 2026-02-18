import 'package:powerps/models/ballance_model.dart';
import 'package:powerps/models/log_model.dart';
import 'package:powerps/models/product_category_model.dart';

class UserDashboard {
  Ballance? ballance;
  List<ProductCategory>? prdoducts;
  List<Log>? logs = [];
  UserDashboard(
      {required this.ballance, required this.prdoducts, required this.logs});
}
