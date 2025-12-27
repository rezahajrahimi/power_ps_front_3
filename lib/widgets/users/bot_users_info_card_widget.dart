import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:powerps/widgets/users/bot_user_info_item_widget.dart';

class BotUsersInfoCardWidget extends StatefulWidget {
  const BotUsersInfoCardWidget(
      {super.key, required this.title, required this.botUsers});
  final List<BotUser> botUsers;
  final String title;

  @override
  State<BotUsersInfoCardWidget> createState() => _BotUsersInfoCardWidgetState();
}

class _BotUsersInfoCardWidgetState extends State<BotUsersInfoCardWidget> {
  final List<BotUserInfoItemCardWidget> _botUserItemList = [];

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    _botUserItemList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final Size size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_outline, color: AppStyle.primaryColor),
              const SizedBox(width: 10),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: _botUserItemList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 3.2,
                  crossAxisCount: 2,
                  importedList: _botUserItemList),
              desktop: widgetsGridview(
                  context: context,
                  importedList: _botUserItemList,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  void _fillData() {
    if (mounted) {
      setStateIfMounted(() {
        for (var i in widget.botUsers) {
          _botUserItemList.add(BotUserInfoItemCardWidget(
            item: i,
          ));
        }
      });
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }
}
