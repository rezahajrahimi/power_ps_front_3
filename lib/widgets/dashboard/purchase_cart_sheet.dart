import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/provider/purchase_cart_provider.dart';
import 'package:powerps/repositories/webapp_user_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/dashboard/purchase_flow_helper.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:provider/provider.dart';

class PurchaseCartSheet {
  static Future<void> show(
    BuildContext context, {
    required String userRole,
    required VoidCallback onCheckoutComplete,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyle.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PurchaseCartSheetBody(
        userRole: userRole,
        onCheckoutComplete: onCheckoutComplete,
      ),
    );
  }
}

class _PurchaseCartSheetBody extends StatefulWidget {
  const _PurchaseCartSheetBody({
    required this.userRole,
    required this.onCheckoutComplete,
  });

  final String userRole;
  final VoidCallback onCheckoutComplete;

  @override
  State<_PurchaseCartSheetBody> createState() => _PurchaseCartSheetBodyState();
}

class _PurchaseCartSheetBodyState extends State<_PurchaseCartSheetBody> {
  final _promoController = TextEditingController();
  final _remarkControllers = <int, TextEditingController>{};
  Map<String, dynamic>? _promoPreview;
  bool _checkingOut = false;

  TextEditingController _remarkController(int productId, String initial) {
    return _remarkControllers.putIfAbsent(
      productId,
      () => TextEditingController(text: initial),
    );
  }

  void _syncRemarkControllers(PurchaseCartProvider cart) {
    final activeIds = cart.items.map((e) => e.product.id).toSet();
    for (final id in _remarkControllers.keys.toList()) {
      if (!activeIds.contains(id)) {
        _remarkControllers.remove(id)?.dispose();
      }
    }
  }

  @override
  void dispose() {
    _promoController.dispose();
    for (final controller in _remarkControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _validatePromo(int categoryId) async {
    final code = _promoController.text.trim();
    if (code.isEmpty) {
      setState(() => _promoPreview = null);
      return;
    }
    final result = await validateWebAppPromoCode(
      code: code,
      categoryId: categoryId,
    );
    if (!mounted) return;
    setState(() => _promoPreview = result);
  }

  Future<void> _checkout() async {
    final cart = context.read<PurchaseCartProvider>();
    if (cart.items.isEmpty) return;

    final promoCode = _promoController.text.trim();
    setState(() => _checkingOut = true);
    EasyLoading.show(status: 'در حال خرید...');

    var successCount = 0;
    String? lastConfig;

    for (final item in cart.items) {
      if (promoCode.isNotEmpty) {
        final validation = await validateWebAppPromoCode(
          code: promoCode,
          categoryId: item.product.id,
        );
        if (validation['valid'] != true) {
          EasyLoading.dismiss();
          if (!mounted) return;
          setState(() => _checkingOut = false);
          showMsg(
            msg:
                'کد تخفیف برای «${item.product.categoryName}» معتبر نیست: ${validation['message']}',
            context: context,
            type: 'error',
          );
          return;
        }
      }

      dynamic val;
      if (widget.userRole == 'agent') {
        val = await buyProductByAgentWithPrID(
          productID: item.product.id,
          remark: item.remark,
          promoCode: promoCode.isEmpty ? null : promoCode,
        );
      } else {
        val = await buyProductByUserWithPrID(
          productID: item.product.id,
          remark: item.remark,
          promoCode: promoCode.isEmpty ? null : promoCode,
        );
      }

      if (val == false || val == null) {
        EasyLoading.dismiss();
        if (!mounted) return;
        setState(() => _checkingOut = false);
        showMsg(
          msg: 'خطا در خرید «${item.product.categoryName}»',
          context: context,
          type: 'error',
        );
        return;
      }

      final text = val.toString();
      if (text == 'low ballance') {
        EasyLoading.dismiss();
        if (!mounted) return;
        setState(() => _checkingOut = false);
        showMsg(msg: 'موجودی کافی نیست', context: context, type: 'error');
        return;
      }

      successCount++;
      if (text.startsWith('vless://') ||
          text.startsWith('vmess://') ||
          text.startsWith('trojan://')) {
        lastConfig = text;
      }
    }

    cart.clear();
    EasyLoading.dismiss();
    if (!mounted) return;
    setState(() => _checkingOut = false);
    Navigator.pop(context);
    widget.onCheckoutComplete();
    showMsg(
      msg: '$successCount بسته با موفقیت خریداری شد',
      context: context,
      type: 'info',
    );

    if (lastConfig != null) {
      await PurchaseFlowHelper.showConfigDialog(context, lastConfig);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<PurchaseCartProvider>();
    _syncRemarkControllers(cart);
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Padding(
      padding: EdgeInsets.only(
        left: AppStyle.defaultPadding,
        right: AppStyle.defaultPadding,
        top: AppStyle.defaultPadding,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppStyle.defaultPadding,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'سبد خرید (${cart.count})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              'جمع: ${thousandSeperatorFormatter(cart.totalToman().toString())} تومان',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: cart.items.isEmpty
                  ? const Center(child: Text('سبد خرید خالی است'))
                  : ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (_, index) {
                        final item = cart.items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(item.product.categoryName),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => cart.removeAt(index),
                                    ),
                                  ],
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'نام بسته',
                                    isDense: true,
                                  ),
                                  controller: _remarkController(
                                    item.product.id,
                                    item.remark,
                                  ),
                                  onChanged: (v) => cart.updateRemark(index, v),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (cart.items.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      decoration: const InputDecoration(
                        labelText: 'کد تخفیف (برای همه اقلام)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _validatePromo(cart.items.first.product.id),
                    child: const Text('بررسی'),
                  ),
                ],
              ),
              if (_promoPreview != null && _promoPreview?['valid'] != true)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _promoPreview?['message']?.toString() ?? 'کد نامعتبر',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _checkingOut ? null : _checkout,
                icon: const Icon(Icons.shopping_cart_checkout),
                label: Text(_checkingOut ? 'در حال پردازش...' : 'تسویه سبد خرید'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
