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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppStyle.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.people_alt_rounded,
                        color: AppStyle.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
              if (widget.botUsers.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppStyle.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${widget.botUsers.length} نفر",
                    style: TextStyle(
                      color: AppStyle.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding * 1.5),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.5,
                  context: context,
                  importedList: botUserItemList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 3.0,
                  crossAxisCount: 2,
                  importedList: botUserItemList),
              desktop: widgetsGridview(
                  context: context,
                  importedList: botUserItemList,
                  childAspectRatio: 4.2,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }
}
