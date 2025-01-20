import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/screens/admin_screen/user/bot_user_details_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';

class BotUserInfoItemCardWidget extends StatefulWidget {
  const BotUserInfoItemCardWidget({
    super.key,
    required this.item,
  });

  final BotUser item;
  @override
  State<BotUserInfoItemCardWidget> createState() =>
      _BotUserInfoItemCardWidgetState();
}

class _BotUserInfoItemCardWidgetState extends State<BotUserInfoItemCardWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BotUserDetailsScreen(
                id: widget.item.id,
              ),
            )).then((value) {});
      },
      child: Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
              width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(AppStyle.defaultPadding),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: Icon(Icons.contact_page),
            ),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.item.accountId.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.item.username!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${widget.item.firstName} ${widget.item.lastName}",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                        Text(
                          widget.item.createdAt,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
