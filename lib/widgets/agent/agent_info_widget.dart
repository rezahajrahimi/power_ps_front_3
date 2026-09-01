import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/styles/app_theme.dart';

class AgentInfoWidget extends StatelessWidget {
  const AgentInfoWidget({
    super.key,
    required this.agent,
    this.productCount,
    this.compact = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final User agent;
  final int? productCount;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(compact ? 12 : AppStyle.defaultPadding),
          decoration: BoxDecoration(
            color: AppStyle.secondaryColor,
            border: Border.all(
              color: AppStyle.primaryColor.withValues(alpha: 0.15),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: compact ? _buildCompactLayout(context) : _buildWideLayout(context),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _avatar(),
            const SizedBox(width: 12),
            Expanded(child: _titleBlock(context)),
            _actionsMenu(context),
          ],
        ),
        const SizedBox(height: 8),
        _statsWrap(context),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titleBlock(context),
              const SizedBox(height: 8),
              _statsWrap(context),
            ],
          ),
        ),
        _actionButtons(context),
      ],
    );
  }

  Widget _avatar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppStyle.primaryColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.support_agent, color: AppStyle.primaryColor, size: 22),
    );
  }

  Widget _titleBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          agent.adminAlias?.isNotEmpty == true ? agent.adminAlias! : agent.name,
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (agent.adminAlias?.isNotEmpty == true) ...[
          const SizedBox(height: 2),
          Text(
            agent.name,
            textAlign: TextAlign.right,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 4),
        Text(
          "شناسه تلگرام: ${agent.accountId}",
          textAlign: TextAlign.right,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _statsWrap(BuildContext context) {
    final chips = <Widget>[];

    if (agent.userGroupName != null && agent.userGroupName!.isNotEmpty) {
      chips.add(_chip(context, agent.userGroupName!, Colors.amberAccent));
    }
    if (productCount != null) {
      chips.add(_chip(context, "$productCount بسته", Colors.white54));
    }
    if (agent.balanceToman != null) {
      chips.add(_chip(
        context,
        "${thousandSeperatorFormatter(agent.balanceToman.toString())} تومان",
        Colors.greenAccent,
      ));
    }
    if (agent.salesCount != null) {
      chips.add(_chip(context, "${agent.salesCount} فروش", Colors.white54));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.start,
      children: chips,
    );
  }

  Widget _chip(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
      ),
    );
  }

  Widget _actionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: "عملیات",
      onSelected: (value) {
        switch (value) {
          case 'detail':
            onTap?.call();
          case 'edit':
            onEdit?.call();
          case 'delete':
            onDelete?.call();
        }
      },
      itemBuilder: (_) => [
        if (onTap != null)
          const PopupMenuItem(value: 'detail', child: Text('جزئیات')),
        if (onEdit != null)
          const PopupMenuItem(value: 'edit', child: Text('ویرایش')),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Text('حذف', style: TextStyle(color: Colors.redAccent)),
          ),
      ],
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Row(
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
    );
  }
}
