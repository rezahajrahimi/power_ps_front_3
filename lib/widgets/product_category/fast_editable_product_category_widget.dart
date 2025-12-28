import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class FastEditableProductCategoryWidget extends StatefulWidget {
  final ProductCategory productCategory;

  const FastEditableProductCategoryWidget(
      {super.key, required this.productCategory});

  @override
  State<FastEditableProductCategoryWidget> createState() =>
      _FastEditableProductCategoryWidgetState();
}

class _FastEditableProductCategoryWidgetState
    extends State<FastEditableProductCategoryWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameEditText;
  late TextEditingController _priceEditText;
  late TextEditingController _priceInDollarEditText;
  late TextEditingController _expireDayEditText;
  late TextEditingController _volumeEditText;
  bool _isActive = true;

  @override
  void initState() {
    _nameEditText =
        TextEditingController(text: widget.productCategory.categoryName);
    _priceEditText =
        TextEditingController(text: widget.productCategory.price.toString());
    _priceInDollarEditText = TextEditingController(
        text: widget.productCategory.priceInDollar.toString());
    _expireDayEditText = TextEditingController(
        text: widget.productCategory.expireDay.toString());
    _volumeEditText =
        TextEditingController(text: widget.productCategory.volume.toString());
    _isActive = widget.productCategory.isActive;
    super.initState();
  }

  @override
  void dispose() {
    _nameEditText.dispose();
    _priceEditText.dispose();
    _priceInDollarEditText.dispose();
    _expireDayEditText.dispose();
    _volumeEditText.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      EasyLoading.show(status: 'در حال بروزرسانی...');
      try {
        int pannelID = int.parse(widget.productCategory.pannel!.id);
        final res = await editProductCategory(
          name: _nameEditText.text,
          price: int.parse(_priceEditText.text),
          priceInDollar: double.parse(_priceInDollarEditText.text),
          pannelID: pannelID,
          expDay: int.parse(_expireDayEditText.text),
          volume: int.parse(_volumeEditText.text),
          rechargable: widget.productCategory.rechargable,
          showPannelLink: widget.productCategory.showPannelLink,
          showSubscriptionLink: widget.productCategory.showSubscriptionLink,
          isActive: _isActive,
          id: widget.productCategory.id.toInt(),
        );

        if (res != false) {
          if (mounted) {
            showMsg(
              msg: "بسته \"${_nameEditText.text}\" با موفقیت ویرایش شد.",
              context: context,
              type: "success",
            );
          }
        } else {
          if (mounted) {
            showMsg(msg: "خطا در ویرایش بسته", context: context, type: "error");
          }
        }
      } catch (e) {
        if (mounted) {
          showMsg(msg: "خطای غیرمنتظره: $e", context: context, type: "error");
        }
      } finally {
        EasyLoading.dismiss();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    return Container(
      margin: EdgeInsets.only(bottom: AppStyle.defaultPadding),
      padding: EdgeInsets.all(isMobile ? 12 : AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppStyle.primaryColor.withAlpha(1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.productCategory.pannel?.location ?? "نامشخص",
                          style: TextStyle(
                              color: AppStyle.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 12 : 14),
                        ),
                      ),
                      Text(
                        isMobile ? "فعال" : "وضعیت فعال:",
                        style: TextStyle(fontSize: isMobile ? 12 : 14),
                      ),
                      SizedBox(
                        height: 30,
                        child: Switch(
                          value: _isActive,
                          onChanged: (val) => setState(() => _isActive = val),
                          activeThumbColor: AppStyle.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _save,
                  icon: const Icon(Icons.save, color: Colors.green),
                  tooltip: "ذخیره تغییرات",
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;
                return Wrap(
                  spacing: isMobile ? 8 : 16,
                  runSpacing: isMobile ? 12 : 16,
                  children: [
                    _buildField("نام بسته", _nameEditText,
                        width > 600 ? 250 : width, Icons.label),
                    _buildField("قیمت (تومان)", _priceEditText,
                        width > 600 ? 150 : (width - 8) / 2, Icons.money,
                        isNumber: true),
                    _buildField("قیمت (دلار)", _priceInDollarEditText,
                        width > 600 ? 120 : (width - 8) / 2, Icons.attach_money,
                        isNumber: true),
                    _buildField("اعتبار (روز)", _expireDayEditText,
                        width > 600 ? 100 : (width - 8) / 2, Icons.timer,
                        isNumber: true),
                    _buildField("حجم (گیگ)", _volumeEditText,
                        width > 600 ? 100 : (width - 8) / 2, Icons.data_usage,
                        isNumber: true),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      double width, IconData icon,
      {bool isNumber = false}) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "اجباری";
          return null;
        },
      ),
    );
  }
}
