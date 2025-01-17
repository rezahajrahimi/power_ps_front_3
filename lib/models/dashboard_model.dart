import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/models/details_info.dart';
import 'package:powerps/models/log_model.dart';
import 'package:powerps/models/product_details_model.dart';
import 'package:powerps/models/transaction_model.dart';

class Dashboard {
  List<BotUser> users;
  List<Log> logs;
  List<Transaction> conTransactions;
  List<Transaction> unConTransactions;
  List<DetailsInfoItem> mostSelledProductCategory;
  List<ProductDetails> last10ProductSelled;
  Dashboard(
      {required this.users,
      required this.logs,
      required this.conTransactions,
      required this.unConTransactions,
      required this.mostSelledProductCategory,
      required this.last10ProductSelled});
}
