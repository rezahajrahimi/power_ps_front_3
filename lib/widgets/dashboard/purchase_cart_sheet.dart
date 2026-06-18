import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/provider/purchase_cart_provider.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/dashboard/purchase_flow_helper.dart';
import 'package:powerps/repositories/webapp_user_repository.dart';
import 'package:provider/provider.dart';

class _CartCheckoutPreviewItem {
  const _CartCheckoutPreviewItem({
    required this.remark,
    required this.categoryName,
    required this.originalPrice,
    required this.finalPrice,
    required this.discount,
    this.promoError,
  });

  final String remark;
  final String categoryName;
  final int originalPrice;
  final int finalPrice;
  final int discount;
  final String? promoError;
}

class _CheckoutPreviewDialog extends StatelessWidget {
  const _CheckoutPreviewDialog({
    required this.items,
    required this.promoCode,
  });

  final List<_CartCheckoutPreviewItem> items;
  final String promoCode;

  int get _subtotal =>
      items.fold(0, (sum, item) => sum + item.originalPrice);

  int get _totalDiscount =>
      items.fold(0, (sum, item) => sum + item.discount);

  int get _totalPayable =>
      items.fold(0, (sum, item) => sum + item.finalPrice);

  bool get _hasPromoErrors =>
      promoCode.isNotEmpty && items.any((item) => item.promoError != null);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('پیش‌نمایش نهایی خرید'),
        content: SizedBox(
          width: 640,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (promoCode.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'کد تخفیف: $promoCode',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ...items.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.remark,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.categoryName,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.discount > 0
                              ? '${thousandSeperatorFormatter(item.originalPrice.toString())} → ${thousandSeperatorFormatter(item.finalPrice.toString())} تومان'
                              : '${thousandSeperatorFormatter(item.originalPrice.toString())} تومان',
                        ),
                        if (item.discount > 0)
                          Text(
                            'تخفیف: ${thousandSeperatorFormatter(item.discount.toString())} تومان',
                            style: const TextStyle(color: Colors.greenAccent),
                          ),
                        if (item.promoError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              item.promoError!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                const Divider(),
                _summaryRow(
                  'جمع اولیه',
                  '${thousandSeperatorFormatter(_subtotal.toString())} تومان',
                ),
                if (_totalDiscount > 0)
                  _summaryRow(
                    'مجموع تخفیف',
                    '${thousandSeperatorFormatter(_totalDiscount.toString())} تومان',
                    valueColor: Colors.greenAccent,
                  ),
                _summaryRow(
                  'مبلغ قابل پرداخت',
                  '${thousandSeperatorFormatter(_totalPayable.toString())} تومان',
                  isBold: true,
                ),
                if (_hasPromoErrors)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'به‌خاطر خطای کد تخفیف، امکان ادامه خرید وجود ندارد.',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('بازگشت'),
          ),
          ElevatedButton(
            onPressed: _hasPromoErrors
                ? null
                : () => Navigator.pop(context, true),
            child: const Text('تأیید و پرداخت'),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

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
  Map<String, dynamic>? _packageNameHint;
  bool _checkingOut = false;

  @override
  void initState() {
    super.initState();
    _loadPackageNameHint();
  }

  Future<void> _loadPackageNameHint() async {
    final hint = await getWebAppPackageNameHint();
    if (!mounted) return;
    setState(() => _packageNameHint = hint);
  }

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

  Future<List<_CartCheckoutPreviewItem>> _buildCheckoutPreview(
    List<PurchaseCartItem> items,
    String promoCode,
  ) async {
    final preview = <_CartCheckoutPreviewItem>[];

    for (final item in items) {
      final originalPrice = item.product.price;
      var finalPrice = originalPrice;
      var discount = 0;
      String? promoError;

      if (promoCode.isNotEmpty) {
        final validation = await validateWebAppPromoCode(
          code: promoCode,
          categoryId: item.product.id,
        );
        if (validation['valid'] == true) {
          finalPrice =
              (validation['final_price_toman'] as num?)?.round() ?? originalPrice;
          discount = (validation['discount_toman'] as num?)?.round() ??
              (originalPrice - finalPrice);
        } else {
          promoError = validation['message']?.toString() ?? 'کد نامعتبر';
        }
      }

      preview.add(
        _CartCheckoutPreviewItem(
          remark: PurchaseFlowHelper.displayPackageRemark(item.remark),
          categoryName: item.product.categoryName,
          originalPrice: originalPrice,
          finalPrice: finalPrice,
          discount: discount,
          promoError: promoError,
        ),
      );
    }

    return preview;
  }

  Future<void> _startCheckout() async {
    final cart = context.read<PurchaseCartProvider>();
    if (cart.items.isEmpty || _checkingOut) return;

    final promoCode = _promoController.text.trim();
    EasyLoading.show(status: 'در حال محاسبه...');
    final preview = await _buildCheckoutPreview(cart.items, promoCode);
    EasyLoading.dismiss();
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _CheckoutPreviewDialog(
        items: preview,
        promoCode: promoCode,
      ),
    );

    if (confirmed == true) {
      await _executeCheckout();
    }
  }

  Future<void> _executeCheckout() async {
    final cart = context.read<PurchaseCartProvider>();
    if (cart.items.isEmpty) return;
    final sheetNavigator = Navigator.of(context);
    final hostContext = Navigator.of(context, rootNavigator: true).context;

    final promoCode = _promoController.text.trim();
    setState(() => _checkingOut = true);
    EasyLoading.show(status: 'در حال خرید...');

    var successCount = 0;
    final deliveryResults = <PurchaseDeliveryResult>[];
    final successfulIndices = <int>[];
    String? failureMessage;

    for (var index = 0; index < cart.items.length; index++) {
      final item = cart.items[index];
      if (promoCode.isNotEmpty) {
        final validation = await validateWebAppPromoCode(
          code: promoCode,
          categoryId: item.product.id,
        );
        if (validation['valid'] != true) {
          failureMessage =
              'کد تخفیف برای «${item.product.categoryName}» معتبر نیست: ${validation['message']}';
          break;
        }
      }

      final result = await PurchaseFlowHelper.buyProduct(
        userRole: widget.userRole,
        product: item.product,
        remark: item.remark,
        promoCode: promoCode.isEmpty ? null : promoCode,
      );
      if (result.error != null) {
        failureMessage = result.error == 'موجودی کافی نیست'
            ? 'موجودی کافی نیست'
            : 'خطا در خرید «${item.product.categoryName}»: ${result.error}';
        break;
      }

      successCount++;
      successfulIndices.add(index);
      if (result.result != null && result.result!.value.isNotEmpty) {
        deliveryResults.add(result.result!);
      }
    }

    EasyLoading.dismiss();
    if (!mounted) return;
    setState(() => _checkingOut = false);
    if (!hostContext.mounted) return;
    if (successfulIndices.isNotEmpty) {
      cart.removeIndices(successfulIndices);
    }

    if (successCount == 0) {
      showMsg(
        msg: failureMessage ?? 'هیچ خریدی انجام نشد',
        context: hostContext,
        type: 'error',
      );
      return;
    }

    sheetNavigator.pop();
    widget.onCheckoutComplete();
    showMsg(
      msg: failureMessage == null
          ? '$successCount بسته با موفقیت خریداری شد'
          : '$successCount بسته خریداری شد و ${cart.count} بسته در سبد باقی ماند',
      context: hostContext,
      type: failureMessage == null ? 'info' : 'warning',
    );

    if (deliveryResults.isNotEmpty) {
      await PurchaseFlowHelper.showCheckoutResultsDialog(
        hostContext,
        deliveryResults,
      );
      if (!hostContext.mounted) return;
    }

    if (failureMessage != null) {
      showMsg(
        msg: failureMessage,
        context: hostContext,
        type: 'error',
      );
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
                                  decoration: InputDecoration(
                                    labelText: 'نام بسته',
                                    hintText: PurchaseFlowHelper.packageNameHintText(
                                      _packageNameHint,
                                    ),
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
                onPressed: _checkingOut ? null : _startCheckout,
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
