import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:powerps/widgets/users/bot_user_info_item_widget.dart';

class BotUsersInfoCardWidget extends StatefulWidget {
  const BotUsersInfoCardWidget({
    super.key,
    required this.title,
    required this.botUsers,
    required this.selectedUserAccountIds,
    required this.onUserSelected,
  });
  final List<BotUser> botUsers;
  final String title;
  final Set<String> selectedUserAccountIds;
  final Function(String accountId, bool selected) onUserSelected;

  @override
  State<BotUsersInfoCardWidget> createState() => _BotUsersInfoCardWidgetState();
}

class _BotUsersInfoCardWidgetState extends State<BotUsersInfoCardWidget> {
  @override
  Widget build(BuildContext context) {
    final List<BotUserInfoItemCardWidget> botUserItemList = widget.botUsers
        .map(
          (user) => BotUserInfoItemCardWidget(
            item: user,
            isSelected: widget.selectedUserAccountIds
                .contains(user.accountId.toString()),
            onSelectedChanged: (selected) {
              widget.onUserSelected(
                  user.accountId.toString(), selected ?? false);
            },
          ),
        )
        .toList();

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
                  importedList: botUserItemList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 3.2,
                  crossAxisCount: 2,
                  importedList: botUserItemList),
              desktop: widgetsGridview(
                  context: context,
                  importedList: botUserItemList,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }
}
