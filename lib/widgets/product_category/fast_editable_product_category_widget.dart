import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';

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
  final _nameEditText = TextEditingController();
  final _priceEditText = TextEditingController();
  final _priceInDollarEditText = TextEditingController();
  final _expireDayEditText = TextEditingController();
  final _volumeEditText = TextEditingController();
  bool _isActive = true;
  @override
  void initState() {
    _fillData();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(
            width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
        borderRadius: BorderRadius.all(
          Radius.circular(AppStyle.defaultPadding),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width / 4
                            : 330,
                        child: CustomTextFromFieldWidget(
                          controller: _nameEditText,
                          textHint: "نام بسته",
                          validationError: "نام بسته را وارد کنید.",
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      SizedBox(
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width / 8
                            : 180,
                        child: CustomTextFromFieldWidget(
                          controller: _priceEditText,
                          textHint: "قیمت بسته",
                          validationError: "قیمت بسته را وارد کنید.",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width / 8
                            : 180,
                        child: CustomTextFromFieldWidget(
                          controller: _priceInDollarEditText,
                          textHint: " قیمت بسته به دلار",
                          validationError: "قیمت دلاری بسته را وارد کنید.",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width / 8
                            : 180,
                        child: CustomTextFromFieldWidget(
                          controller: _expireDayEditText,
                          textHint: "مدت زمان اعتبار (روز) بسته",
                          validationError:
                              "مدت زمان اعتبار (روز) بسته را وارد کنید.",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width / 8
                            : 180,
                        child: CustomTextFromFieldWidget(
                          controller: _volumeEditText,
                          textHint: "حجم بسته",
                          validationError: "حجم بسته را وارد کنید.",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Text(widget.productCategory.pannel!.location!),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _isActive = !_isActive;
                            });
                          },
                          icon: _isActive
                              ? const Icon(Icons.code)
                              : const Icon(Icons.code_off)),
                      IconButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              AppStyle.primaryColor),
                        ),
                        onPressed: () async {
                          EasyLoading.show();
                          int pannelID =
                              int.parse(widget.productCategory.pannel!.id);

                          if (_nameEditText.text.isNotEmpty &&
                              _priceEditText.text.isNotEmpty &&
                              _expireDayEditText.text.isNotEmpty &&
                              _volumeEditText.text.isNotEmpty) {
                            await editProductCategory(
                                    name: _nameEditText.text,
                                    price: int.parse(_priceEditText.text),
                                    priceInDollar: double.parse(
                                        _priceInDollarEditText.text),
                                    pannelID: pannelID,
                                    expDay: int.parse(_expireDayEditText.text),
                                    volume: int.parse(_volumeEditText.text),
                                    rechargable:
                                        widget.productCategory.rechargable,
                                    showPannelLink:
                                        widget.productCategory.showPannelLink,
                                    showSubscriptionLink: widget
                                        .productCategory.showSubscriptionLink,
                                    isActive: _isActive,
                                    id: widget.productCategory.id.toInt())
                                .then((res) {
                              if (!context.mounted) return;
                              if (res != false) {
                                showMsg(
                                    msg: "بسته با موفقیت ویرایش شد.",
                                    context: context,
                                    type: "success");
                              } else {
                                showMsg(
                                    msg: "خطا",
                                    context: context,
                                    type: "error");
                              }
                            });
                          } else {
                            showMsg(
                                msg: "اطلاعات درخواست شده را وارد کنید.",
                                context: context);
                          }
                          EasyLoading.dismiss();
                        },
                        icon: const Icon(Icons.save),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _fillData() {
    setState(() {
      _nameEditText.text = widget.productCategory.categoryName;
      _priceEditText.text = widget.productCategory.price.toString();
      _priceInDollarEditText.text =
          widget.productCategory.priceInDollar.toString();
      _expireDayEditText.text = widget.productCategory.expireDay.toString();
      _volumeEditText.text = widget.productCategory.volume.toString();
      _isActive = widget.productCategory.isActive;
      // _widgetList.add(ElevatedButton.icon(
      //   style: ButtonStyle(
      //     backgroundColor:
      //         WidgetStateProperty.all<Color>(AppStyle.primaryColor),
      //   ),
      //   onPressed: () async {},
      //   icon: const Icon(Icons.delete),
      //   label: const Text("حذف"),
      // ));
    });
  }
}
