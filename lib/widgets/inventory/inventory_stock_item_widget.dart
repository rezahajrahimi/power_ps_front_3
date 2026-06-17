import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powerps/models/product_details_model.dart';
import 'package:powerps/styles/app_theme.dart';

class InventoryStockItemWidget extends StatelessWidget {
  const InventoryStockItemWidget({
    super.key,
    required this.item,
    required this.onCopy,
    this.onEdit,
    this.onDelete,
    this.compact = false,
  });

  final ProductDetails item;
  final VoidCallback onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool compact;

  bool get _isActive => item.isActive == true;

  String get _configPreview {
    final text = item.configs.trim();
    final limit = compact ? 48 : 60;
    if (text.length <= limit) return text;
    return '${text.substring(0, limit)}...';
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactCard(context);
    }
    return _buildFullCard(context);
  }

  Widget _buildFullCard(BuildContext context) {
    final categoryName =
        item.productCategory?.categoryName ?? 'بدون دسته‌بندی';
    final price = item.productCategory?.price.toString() ?? '-';
    final buyer = item.botUser?.username?.isNotEmpty == true
        ? item.botUser!.username!
        : item.accountId?.toString();

    return Container(
      margin: EdgeInsets.only(bottom: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  categoryName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              _statusChip(),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding / 2),
          Text(
            _configPreview,
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
          SizedBox(height: AppStyle.defaultPadding / 2),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _metaItem(Icons.sell_outlined, '$price تومان'),
              _metaItem(Icons.schedule, item.createdAt),
              if (!_isActive && buyer != null && buyer != '0')
                _metaItem(Icons.person_outline, 'خریدار: $buyer'),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding / 2),
          _actionRow(context),
        ],
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    final categoryName =
        item.productCategory?.categoryName ?? 'بدون دسته‌بندی';
    final price = item.productCategory?.price.toString() ?? '-';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              _statusChip(),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              _configPreview,
              textDirection: TextDirection.ltr,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$price تومان',
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          _actionRow(context, iconOnly: true),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppStyle.secondaryColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: _isActive
            ? Colors.green.withValues(alpha: 0.35)
            : Colors.orange.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _actionRow(BuildContext context, {bool iconOnly = false}) {
    if (iconOnly) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            tooltip: 'کپی',
            visualDensity: VisualDensity.compact,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: item.configs));
              onCopy();
            },
            icon: const Icon(Icons.copy, size: 18),
          ),
          if (onEdit != null)
            IconButton(
              tooltip: 'ویرایش',
              visualDensity: VisualDensity.compact,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
            ),
          if (onDelete != null)
            IconButton(
              tooltip: 'حذف',
              visualDensity: VisualDensity.compact,
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.redAccent.shade200,
              ),
            ),
        ],
      );
    }

    return Row(
      children: [
        TextButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: item.configs));
            onCopy();
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('کپی'),
        ),
        if (onEdit != null)
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('ویرایش'),
          ),
        if (onDelete != null)
          TextButton.icon(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: Colors.redAccent.shade200,
            ),
            label: Text(
              'حذف',
              style: TextStyle(color: Colors.redAccent.shade200),
            ),
          ),
      ],
    );
  }

  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (_isActive ? Colors.green : Colors.orange).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _isActive ? 'موجود' : 'فروخته‌شده',
        style: TextStyle(
          color: _isActive ? Colors.greenAccent : Colors.orangeAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
