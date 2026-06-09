import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/screens/admin_screen/user/bot_user_details_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';

class BotUserInfoItemCardWidget extends StatefulWidget {
  const BotUserInfoItemCardWidget({
    super.key,
    required this.item,
    this.isSelected = false,
    this.onSelectedChanged,
  });

  final BotUser item;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectedChanged;

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
            ));
      },
      child: Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isSelected
                ? AppStyle.primaryColor
                : Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
          gradient: widget.isSelected
              ? LinearGradient(
                  colors: [
                    AppStyle.primaryColor.withValues(alpha: 0.1),
                    AppStyle.primaryColor.withValues(alpha: 0.02),
                  ],
                )
              : null,
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: AppStyle.primaryColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            if (widget.onSelectedChanged != null)
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: widget.isSelected,
                  onChanged: widget.onSelectedChanged,
                  activeColor: AppStyle.primaryColor,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppStyle.primaryColor.withValues(alpha: 0.25),
                    AppStyle.primaryColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppStyle.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(Icons.person_rounded,
                  color: AppStyle.primaryColor, size: 24),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.accountId.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.item.adminAlias != null &&
                                  widget.item.adminAlias!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.label_outline,
                                          size: 12, color: Colors.amberAccent),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          widget.item.adminAlias!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.amberAccent,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            if (widget.item.panelUser?.role == 'user')
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (widget.item.panelUser!.isVerified
                                          ? Colors.greenAccent
                                          : Colors.orangeAccent)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.item.panelUser!.isVerified
                                      ? 'تایید شده'
                                      : 'تایید نشده',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: widget.item.panelUser!.isVerified
                                        ? Colors.greenAccent
                                        : Colors.orangeAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (widget.item.username != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppStyle.primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "@${widget.item.username}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppStyle.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${widget.item.firstName ?? ''} ${widget.item.lastName ?? ''}"
                              .trim()
                              .isEmpty
                          ? "کاربر بدون نام"
                          : "${widget.item.firstName ?? ''} ${widget.item.lastName ?? ''}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.4)),
                        const SizedBox(width: 5),
                        Text(
                          widget.item.createdAt,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}
