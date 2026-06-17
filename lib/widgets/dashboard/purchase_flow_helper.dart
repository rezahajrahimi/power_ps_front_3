import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/repositories/webapp_user_repository.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchaseFlowHelper {
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
    Map<String, dynamic>? promoPreview;
    bool validatingPromo = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            Future<void> validatePromo() async {
              final code = promoController.text.trim();
              if (code.isEmpty) {
                setLocalState(() => promoPreview = null);
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
            }

            final Map<String, dynamic>? preview = promoPreview;
            final discountedToman = preview != null && preview['valid'] == true
                ? preview['final_price_toman']
                : null;

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
                          '${thousandSeperatorFormatter(product.price.toString())} تومان'
                          '${discountedToman != null ? ' → ${thousandSeperatorFormatter(discountedToman.toString())} تومان' : ''}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: remarkController,
                          decoration: const InputDecoration(
                            labelText: 'نام بسته',
                            hintText: 'یک نام برای این بسته بنویسید',
                            border: OutlineInputBorder(),
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
                        if (remark.isEmpty) {
                          showMsg(
                            msg: 'نام را وارد کنید.',
                            context: dialogContext,
                            type: 'error',
                          );
                          return;
                        }
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
                      if (remark.isEmpty) {
                        showMsg(
                          msg: 'نام را وارد کنید.',
                          context: dialogContext,
                          type: 'error',
                        );
                        return;
                      }

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
                      final result = await _buyProduct(
                        userRole: userRole,
                        product: product,
                        remark: remark,
                        promoCode:
                            promoCode.isEmpty ? null : promoCode,
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
                      if (result.config != null && result.config!.isNotEmpty) {
                        await showConfigDialog(context, result.config!);
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

  static Future<({String? config, String? error})> _buyProduct({
    required String userRole,
    required ProductCategory product,
    required String remark,
    String? promoCode,
  }) async {
    dynamic val;
    if (userRole == 'agent') {
      val = await buyProductByAgentWithPrID(
        productID: product.id,
        remark: remark,
        promoCode: promoCode,
      );
    } else {
      val = await buyProductByUserWithPrID(
        productID: product.id,
        remark: remark,
        promoCode: promoCode,
      );
    }

    if (val == false || val == null) {
      return (config: null, error: 'خطا در برقراری ارتباط با سرور');
    }

    final text = val.toString();
    if (text == 'low ballance' || text.contains('موجودی')) {
      return (config: null, error: 'موجودی کافی نیست');
    }

    if (product.pannel?.type == 'sanaei' ||
        text.startsWith('vless://') ||
        text.startsWith('vmess://') ||
        text.startsWith('trojan://')) {
      return (config: text, error: null);
    }

    if (text.contains('https://') || text.contains('http://')) {
      await launchUrl(Uri.parse(text), mode: LaunchMode.externalApplication);
      return (config: null, error: null);
    }

    return (config: null, error: text);
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
}
