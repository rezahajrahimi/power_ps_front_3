import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/styles/app_theme.dart';

class AgentInfoWidget extends StatelessWidget {
  const AgentInfoWidget({
    super.key,
    required this.agent,
    this.productCount,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final User agent;
  final int? productCount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyle.defaultPadding),
        child: Container(
          margin: EdgeInsets.only(bottom: AppStyle.defaultPadding / 2),
          padding: EdgeInsets.all(AppStyle.defaultPadding),
          decoration: BoxDecoration(
            color: AppStyle.secondaryColor,
            border: Border.all(
              color: AppStyle.primaryColor.withValues(alpha: 0.15),
            ),
            borderRadius: BorderRadius.circular(AppStyle.defaultPadding),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppStyle.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.support_agent, color: AppStyle.primaryColor),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppStyle.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "شناسه تلگرام: ${agent.accountId}",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                      if (agent.userGroupName != null &&
                          agent.userGroupName!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          "گروه: ${agent.userGroupName}",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.amberAccent),
                        ),
                      ],
                      if (productCount != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          "$productCount بسته فعال",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white54),
                        ),
                      ],
                      if (agent.balanceToman != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          "موجودی: ${thousandSeperatorFormatter(agent.balanceToman.toString())} تومان",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.greenAccent),
                        ),
                      ],
                      if (agent.salesCount != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          "${agent.salesCount} فروش",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white54),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onTap != null)
                    IconButton(
                      tooltip: "جزئیات",
                      onPressed: onTap,
                      icon: const Icon(Icons.info_outline, color: Colors.tealAccent),
                    ),
                  if (onEdit != null)
                    IconButton(
                      tooltip: "ویرایش",
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, color: Colors.blue),
                    ),
                  if (onDelete != null)
                    IconButton(
                      tooltip: "حذف",
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
