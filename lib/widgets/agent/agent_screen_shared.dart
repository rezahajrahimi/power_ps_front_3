import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/styles/app_theme.dart';

double agentContentMaxWidth(BuildContext context) {
  if (Responsive.isDesktop(context)) return double.infinity;
  if (Responsive.isTablet(context)) return double.infinity;
  return double.infinity;
}

EdgeInsets agentScreenPadding(BuildContext context) {
  final base = AppStyle.defaultPadding;
  if (Responsive.isMobile(context)) {
    return EdgeInsets.all(base);
  }
  return EdgeInsets.all(base);
}

BoxDecoration agentCardDecoration({double radius = 12}) {
  return BoxDecoration(
    color: AppStyle.secondaryColor,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
  );
}

Widget agentCenteredContent(BuildContext context, {required Widget child}) {
  return SizedBox(width: double.infinity, child: child);
}

class AgentSectionCard extends StatelessWidget {
  const AgentSectionCard({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: agentCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding),
          ...children,
        ],
      ),
    );
  }
}

class AgentRtlRow extends StatelessWidget {
  const AgentRtlRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration agentRtlInputDecoration({
  required String label,
  String? hint,
  Widget? suffixIcon,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    alignLabelWithHint: true,
    suffixIcon: suffixIcon,
    prefixIcon: prefixIcon,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

Future<bool?> showAgentConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'تایید',
  String cancelLabel = 'لغو',
  bool destructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(title, textAlign: TextAlign.right),
        content: SingleChildScrollView(
          child: Text(
            message,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: destructive ? Colors.redAccent : null,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<T?> showAgentBottomSheetDialog<T>({
  required BuildContext context,
  required String title,
  required Widget child,
  List<Widget>? actions,
}) {
  final isMobile = Responsive.isMobile(context);
  if (isMobile) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyle.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppStyle.defaultPadding,
            right: AppStyle.defaultPadding,
            top: AppStyle.defaultPadding,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppStyle.defaultPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              Flexible(child: child),
              if (actions != null) ...[
                const SizedBox(height: 12),
                Row(children: actions),
              ],
            ],
          ),
        ),
      ),
    );
  }

  return showDialog<T>(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(title, textAlign: TextAlign.right),
        content: SizedBox(
          width: 480,
          child: child,
        ),
        actions: actions,
      ),
    ),
  );
}

Widget agentScrollableList({
  required BuildContext context,
  required int itemCount,
  required IndexedWidgetBuilder itemBuilder,
  double? maxHeight,
}) {
  if (itemCount == 0) {
    return const SizedBox.shrink();
  }

  final height = maxHeight ??
      (Responsive.isMobile(context)
          ? 320
          : Responsive.isTablet(context)
              ? 420
              : 520);

  return _AgentScrollableList(
    maxHeight: height,
    itemCount: itemCount,
    itemBuilder: itemBuilder,
    showScrollbar: itemCount > 6,
  );
}

class _AgentScrollableList extends StatefulWidget {
  const _AgentScrollableList({
    required this.maxHeight,
    required this.itemCount,
    required this.itemBuilder,
    required this.showScrollbar,
  });

  final double maxHeight;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool showScrollbar;

  @override
  State<_AgentScrollableList> createState() => _AgentScrollableListState();
}

class _AgentScrollableListState extends State<_AgentScrollableList> {
  late final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listView = ListView.separated(
      controller: _controller,
      primary: false,
      padding: EdgeInsets.zero,
      itemCount: widget.itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: widget.itemBuilder,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      child: widget.showScrollbar
          ? Scrollbar(
              controller: _controller,
              thumbVisibility: true,
              child: listView,
            )
          : listView,
    );
  }
}

int agentGridColumns(BuildContext context) {
  if (Responsive.isDesktop(context)) return 2;
  if (Responsive.isTablet(context)) return 2;
  return 1;
}
