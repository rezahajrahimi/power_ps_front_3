import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/repositories/loyalty_setting_repository.dart';
import 'package:powerps/repositories/webapp_user_repository.dart';
import 'package:powerps/widgets/dashboard/mobile_verification_helper.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchaseDeliveryResult {
  const PurchaseDeliveryResult({
    required this.title,
    required this.value,
    required this.isConfig,
  });

  final String title;
  final String value;
  final bool isConfig;
}

class PurchaseFlowHelper {
  static const _defaultPackageNameHint =
      'اختیاری — در صورت خالی بودن، مطابق تنظیمات ربات نام‌گذاری می‌شود.';

  static String packageNameHintText(Map<String, dynamic>? hint) {
    final preview = hint?['preview']?.toString().trim();
    if (preview != null && preview.isNotEmpty) {
      return 'اختیاری — در صورت خالی بودن، مثل ربات: $preview';
    }
    return hint?['hint']?.toString() ?? _defaultPackageNameHint;
  }

  static String displayPackageRemark(String remark) {
    final trimmed = remark.trim();
    return trimmed.isEmpty ? 'نام خودکار (طبق تنظیمات ربات)' : trimmed;
  }

  static Future<void> showPurchaseDialog({
    required BuildContext context,
    required ProductCategory product,
    required String userRole,
    required VoidCallback onSuccess,
    bool allowAddToCart = true,
    void Function(ProductCategory product, String remark)? onAddToCart,
  }) async {
    final remarkController = TextEditingController();
    final promoController = TextEditingController();
    final packageNameHint = await getWebAppPackageNameHint();
    final loyaltyInfo = await getWebAppLoyaltyInfo();
    if (!context.mounted) return;

    bool useLoyaltyPoints = loyaltyInfo?['is_active'] == true &&
        loyaltyInfo?['redeem_enabled'] == true;
    Map<String, dynamic>? loyaltyPreview;
    if (useLoyaltyPoints) {
      loyaltyPreview = await validateLoyaltyRedemption(
        orderAmountToman: product.price.toDouble(),
        useLoyaltyPoints: true,
      );
    }
    bool validatingPromo = false;
    Map<String, dynamic>? promoPreview;

    if (userRole == 'user') {
      final canPurchase =
          await MobileVerificationHelper.ensureVerifiedForPurchase(context);
      if (!canPurchase) return;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            final Map<String, dynamic>? preview = promoPreview;
            final discountedToman = preview != null && preview['valid'] == true
                ? preview['final_price_toman']
                : null;

            Future<void> refreshLoyaltyPreview() async {
              if (!useLoyaltyPoints) {
                setLocalState(() => loyaltyPreview = null);
                return;
              }
              final basePrice = discountedToman != null
                  ? double.tryParse(discountedToman.toString()) ??
                      product.price.toDouble()
                  : product.price.toDouble();
              final result = await validateLoyaltyRedemption(
                orderAmountToman: basePrice,
                useLoyaltyPoints: true,
              );
              if (!context.mounted) return;
              setLocalState(() => loyaltyPreview = result);
            }

            Future<void> validatePromo() async {
              final code = promoController.text.trim();
              if (code.isEmpty) {
                setLocalState(() => promoPreview = null);
                await refreshLoyaltyPreview();
                return;
              }
              setLocalState(() => validatingPromo = true);
              final result = await validateWebAppPromoCode(
                code: code,
                categoryId: product.id,
              );
              if (!context.mounted) return;
              setLocalState(() {
                validatingPromo = false;
                promoPreview = result;
              });
              await refreshLoyaltyPreview();
            }

            final finalPrice = loyaltyPreview?['final_price_toman'] ??
                discountedToman ??
                product.price;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text(product.categoryName),
                content: SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'مبلغ نهایی: ${thousandSeperatorFormatter(finalPrice.toString())} تومان',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if (loyaltyInfo?['is_active'] == true &&
                            loyaltyInfo?['redeem_enabled'] == true)
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'استفاده از امتیاز (${loyaltyInfo?['balance'] ?? 0} امتیاز)',
                            ),
                            value: useLoyaltyPoints,
                            onChanged: (value) async {
                              useLoyaltyPoints = value;
                              setLocalState(() {});
                              await refreshLoyaltyPreview();
                            },
                          ),
                        if (loyaltyPreview?['toman_discount'] != null &&
                            (loyaltyPreview?['toman_discount'] as num) > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'تخفیف امتیاز: ${thousandSeperatorFormatter((loyaltyPreview?['toman_discount'] ?? 0).toString())} تومان',
                              style: const TextStyle(color: Colors.amber),
                            ),
                          ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: remarkController,
                          decoration: InputDecoration(
                            labelText: 'نام بسته',
                            hintText: packageNameHintText(packageNameHint),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: promoController,
                                decoration: const InputDecoration(
                                  labelText: 'کد تخفیف',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed:
                                  validatingPromo ? null : () => validatePromo(),
                              child: validatingPromo
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('اعمال'),
                            ),
                          ],
                        ),
                        if (promoPreview != null &&
                            promoPreview?['valid'] != true)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              promoPreview?['message']?.toString() ??
                                  'کد نامعتبر',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        if (promoPreview?['valid'] == true)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'تخفیف: ${thousandSeperatorFormatter((promoPreview?['discount_toman'] ?? 0).toString())} تومان',
                              style: const TextStyle(color: Colors.greenAccent),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  if (allowAddToCart && onAddToCart != null)
                    TextButton(
                      onPressed: () {
                        final remark = remarkController.text.trim();
                        onAddToCart(product, remark);
                        Navigator.pop(dialogContext);
                        showMsg(
                          msg: 'به سبد خرید اضافه شد',
                          context: context,
                          type: 'info',
                        );
                      },
                      child: const Text('افزودن به سبد'),
                    ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('بستن'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final remark = remarkController.text.trim();

                      final promoCode = promoController.text.trim();
                      if (promoCode.isNotEmpty &&
                          promoPreview?['valid'] != true) {
                        showMsg(
                          msg: 'ابتدا کد تخفیف را اعمال کنید.',
                          context: dialogContext,
                          type: 'error',
                        );
                        return;
                      }

                      EasyLoading.show();
                      final result = await buyProduct(
                        userRole: userRole,
                        product: product,
                        remark: remark,
                        promoCode:
                            promoCode.isEmpty ? null : promoCode,
                        useLoyaltyPoints: useLoyaltyPoints,
                      );
                      EasyLoading.dismiss();
                      if (!dialogContext.mounted) return;

                      if (result.error != null) {
                        showMsg(
                          msg: result.error!,
                          context: context,
                          type: 'error',
                        );
                        return;
                      }

                      Navigator.pop(dialogContext);
                      onSuccess();
                      if (result.result != null &&
                          result.result!.value.isNotEmpty) {
                        if (result.result!.isConfig) {
                          await showConfigDialog(context, result.result!.value);
                        } else {
                          await showCheckoutResultsDialog(context, [
                            result.result!,
                          ]);
                        }
                      }
                    },
                    child: const Text('خرید'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    remarkController.dispose();
    promoController.dispose();
  }

  static Future<({PurchaseDeliveryResult? result, String? error})> buyProduct({
    required String userRole,
    required ProductCategory product,
    required String remark,
    String? promoCode,
    bool useLoyaltyPoints = true,
  }) async {
    dynamic val;
    if (userRole == 'agent') {
      val = await buyProductByAgentWithPrID(
        productID: product.id,
        remark: remark,
        promoCode: promoCode,
        useLoyaltyPoints: useLoyaltyPoints,
      );
    } else {
      val = await buyProductByUserWithPrID(
        productID: product.id,
        remark: remark,
        promoCode: promoCode,
        useLoyaltyPoints: useLoyaltyPoints,
      );
    }

    if (val == false || val == null) {
      return (result: null, error: 'خطا در برقراری ارتباط با سرور');
    }

    if (MobileVerificationHelper.isVerificationError(val)) {
      return (
        result: null,
        error: MobileVerificationHelper.verificationErrorMessage(val),
      );
    }

    final text = val.toString();
    if (text == 'low ballance' || text.contains('موجودی')) {
      return (result: null, error: 'موجودی کافی نیست');
    }

    if (product.pannel?.type == 'sanaei' ||
        text.startsWith('vless://') ||
        text.startsWith('vmess://') ||
        text.startsWith('trojan://')) {
      return (
        result: PurchaseDeliveryResult(
          title: displayPackageRemark(remark),
          value: text,
          isConfig: true,
        ),
        error: null,
      );
    }

    if (text.contains('https://') || text.contains('http://')) {
      return (
        result: PurchaseDeliveryResult(
          title: displayPackageRemark(remark),
          value: text,
          isConfig: false,
        ),
        error: null,
      );
    }

    return (result: null, error: text);
  }

  static Future<void> showConfigDialog(BuildContext context, String config) {
    return showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('کانفیگ خریداری شده'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QrImageView(
                    data: config,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  SelectableText(config, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: config));
                showMsg(msg: 'کپی شد', context: ctx, type: 'info');
              },
              child: const Text('کپی'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('بستن'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showCheckoutResultsDialog(
    BuildContext context,
    List<PurchaseDeliveryResult> results,
  ) {
    return showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('خروجی خریدهای انجام‌شده'),
          content: SizedBox(
            width: 640,
            child: results.isEmpty
                ? const Text('برای این خریدها خروجی مستقیمی وجود ندارد.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final result = results[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              result.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            if (result.isConfig &&
                                (result.value.startsWith('vless://') ||
                                    result.value.startsWith('vmess://') ||
                                    result.value.startsWith('trojan://'))) ...[
                              Center(
                                child: QrImageView(
                                  data: result.value,
                                  version: QrVersions.auto,
                                  size: 160,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            SelectableText(
                              result.value,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              alignment: WrapAlignment.end,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: result.value),
                                    );
                                    showMsg(
                                      msg: 'کپی شد',
                                      context: ctx,
                                      type: 'info',
                                    );
                                  },
                                  child: const Text('کپی'),
                                ),
                                if (!result.isConfig)
                                  TextButton(
                                    onPressed: () async {
                                      await launchUrl(
                                        Uri.parse(result.value),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    child: const Text('باز کردن لینک'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('بستن'),
            ),
          ],
        ),
      ),
    );
  }
}
