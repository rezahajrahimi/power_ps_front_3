import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/provider/agent/agent_provider.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/agent/agent_screen_shared.dart';
import 'package:provider/provider.dart';

class AgentSelectCategoryWithPriceInputWidget extends StatefulWidget {
  const AgentSelectCategoryWithPriceInputWidget({
    super.key,
    required this.item,
    required this.type,
  });

  final AgentAddCategoriyModel item;
  final String type;

  @override
  State<AgentSelectCategoryWithPriceInputWidget> createState() =>
      _AgentSelectCategoryWithPriceInputWidgetState();
}

class _AgentSelectCategoryWithPriceInputWidgetState
    extends State<AgentSelectCategoryWithPriceInputWidget> {
  final _formKey = GlobalKey<FormState>();
  final _priceInTomanController = TextEditingController();
  final _priceInDollarController = TextEditingController();

  @override
  void dispose() {
    _priceInTomanController.dispose();
    _priceInDollarController.dispose();
    super.dispose();
  }

  String get _categoryName =>
      widget.item.productCategories?.categoryName ?? '—';

  String get _tomanPrice {
    final price = widget.item.newPrice ?? widget.item.price;
    return '${thousandSeperatorFormatter(price.toString())} تومان';
  }

  String get _dollarPrice {
    final price = widget.item.newPriceInDollar ?? widget.item.priceInDollar;
    return '${thousandSeperatorFormatter(price.toString())}\$';
  }

  String? _panelLabel() {
    final pc = widget.item.productCategories;
    if (pc == null) return null;
    if (pc.pannel != null) {
      return getPannelName(name: pc.pannel!.type);
    }
    if (pc.pannelId != 0) return 'پنل ${pc.pannelId}';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final panel = _panelLabel();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (widget.type == 'add') {
            await _showActionDialog(context);
          } else {
            Provider.of<AgentProvider>(context, listen: false)
                .moveCategoryToAvailable(widget.item);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 10 : AppStyle.defaultPadding),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppStyle.primaryColor.withValues(alpha: 0.15),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                widget.type == 'add' ? Icons.add_circle_outline : Icons.remove_circle_outline,
                size: 22,
                color: widget.type == 'add' ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _categoryName,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (panel != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amberAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              panel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.amberAccent),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildMetaRow(context, isMobile),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, bool isMobile) {
    final pc = widget.item.productCategories;
    if (pc == null) return const SizedBox.shrink();

    final chips = <Widget>[
      _metaChip(context, _tomanPrice),
      _metaChip(context, _dollarPrice),
      _metaChip(context, '${pc.expireDay} روزه'),
      _metaChip(context, '${pc.volume} گیگابایت'),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.start,
      children: chips,
    );
  }

  Widget _metaChip(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
    );
  }

  Future<void> _showActionDialog(BuildContext context) async {
    _priceInDollarController.text = widget.item.priceInDollar.toString();
    _priceInTomanController.text = widget.item.price.toString();

    final formContent = StatefulBuilder(
      builder: (ctx, setDialogState) {
        return Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'قیمت اصلی: ${thousandSeperatorFormatter(widget.item.price.toString())} تومان / ${thousandSeperatorFormatter(widget.item.priceInDollar.toString())}\$',
                textAlign: TextAlign.right,
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceInTomanController,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.number,
                decoration: agentRtlInputDecoration(label: 'قیمت به تومان'),
                onChanged: (_) => setDialogState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفا قیمت را وارد کنید';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceInDollarController,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.number,
                decoration: agentRtlInputDecoration(label: 'قیمت به دلار'),
                onChanged: (_) => setDialogState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفا قیمت را به دلار وارد کنید';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Builder(builder: (context) {
                final toman = int.tryParse(_priceInTomanController.text);
                if (toman == null || widget.item.price == 0) {
                  return const SizedBox.shrink();
                }
                final diff =
                    ((widget.item.price - toman) / widget.item.price * 100);
                final label = diff >= 0
                    ? 'تخفیف: ${diff.toStringAsFixed(1)}٪'
                    : 'افزایش: ${(-diff).toStringAsFixed(1)}٪';
                return Text(
                  label,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: diff >= 0 ? Colors.greenAccent : Colors.orangeAccent,
                    fontSize: 13,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );

    final isMobile = Responsive.isMobile(context);
    final title = 'قیمت بسته «$_categoryName»';

    if (isMobile) {
      await showModalBottomSheet<void>(
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
              bottom:
                  MediaQuery.of(ctx).viewInsets.bottom + AppStyle.defaultPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 12),
                formContent,
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('لغو'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _submitPrice(ctx),
                        child: const Text('تایید'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title, textAlign: TextAlign.right),
          content: SizedBox(width: 480, child: formContent),
          actionsAlignment: MainAxisAlignment.start,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('لغو'),
            ),
            TextButton(
              onPressed: () => _submitPrice(ctx),
              child: const Text('تایید'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitPrice(BuildContext dialogContext) {
    if (_formKey.currentState!.validate()) {
      Provider.of<AgentProvider>(dialogContext, listen: false)
          .moveCategoryToAdded(
        widget.item.setNewPricesValus(
          newPrice: int.parse(_priceInTomanController.text),
          newPriceInDollar: double.parse(_priceInDollarController.text),
        ),
      );
      Navigator.pop(dialogContext);
    } else {
      showMsg(
        context: dialogContext,
        msg: 'لطفا تمام فیلدها را پر کنید',
      );
    }
  }
}
