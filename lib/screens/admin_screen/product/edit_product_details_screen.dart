import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/provider/product_category_provider.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class EditProductDetailsScreen extends StatefulWidget {
  const EditProductDetailsScreen(
      {super.key, required this.selectedProductCategory});
  final ProductCategory selectedProductCategory;

  @override
  State<EditProductDetailsScreen> createState() =>
      _EditProductDetailsScreenState();
}

class _EditProductDetailsScreenState extends State<EditProductDetailsScreen> {
  bool _showData = false;
  final List<Widget> _productDetailsWidgetLIst = [];
  final List<String> _pannelNameList = [];
  late String _selectedPannelName;
  final _nameEditText = TextEditingController();
  final _priceEditText = TextEditingController();
  final _priceInDollarEditText = TextEditingController();
  final _expireDayEditText = TextEditingController();
  final _volumeEditText = TextEditingController();

  bool _rechargable = true;
  bool _showSubscriptionLink = true;
  bool _showPannelLink = true;
  bool _isActive = true;

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBarWithBackButton(
          context: context,
          title: "ویرایش ${widget.selectedProductCategory.categoryName}",
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            child: Padding(
              padding: EdgeInsets.all(AppStyle.defaultPadding),
              child: Column(
                children: [
                  // const Header(title: "ویرایش بسته"),
                  SizedBox(height: AppStyle.defaultPadding),
                  _showData == false
                      ? const SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: CircularProgressIndicator()))
                      : _content(context),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Responsive.isMobile(context)
            ? _buildBottomNavigationBar(context)
            : const Opacity(opacity: 1),
      ),
    );
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: ElevatedButton(
              onPressed: () async {
                await _submitData(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.secondaryColor),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "ثبت تغییرات",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _fillData() async {
    List<Pannel>? resPannel = await getPannels();

    setStateIfMounted(() {
      _nameEditText.text = widget.selectedProductCategory.categoryName;
      _priceEditText.text = widget.selectedProductCategory.price.toString();
      _priceInDollarEditText.text =
          widget.selectedProductCategory.priceInDollar.toString();
      _expireDayEditText.text =
          widget.selectedProductCategory.expireDay.toString();
      _volumeEditText.text = widget.selectedProductCategory.volume.toString();
      _rechargable = widget.selectedProductCategory.rechargable;
      _showSubscriptionLink =
          widget.selectedProductCategory.showSubscriptionLink;
      _showPannelLink = widget.selectedProductCategory.showPannelLink;
      _isActive = widget.selectedProductCategory.isActive;
      if (resPannel!.isNotEmpty) {
        _pannelNameList.clear();
        for (var i in resPannel) {
          _pannelNameList
              .add("${i.id}: ${getPannelName(name: i.type)} - ${i.location}");
        }

        _selectedPannelName =
            "${widget.selectedProductCategory.pannel!.id}: ${getPannelName(name: widget.selectedProductCategory.pannel!.type)} - ${widget.selectedProductCategory.pannel!.location}";
      }

      _showData = true;
    });
  }

  _content(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _productInfoTabCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                )),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
            // side windows
            if (!Responsive.isMobile(context))
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _operationInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  _operationInfoCard(BuildContext context) {
    List<Widget> actionsWidgetList = [];

    setStateIfMounted(() {
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          _submitData(context);
        },
        icon: const Icon(Icons.edit),
        label: const Text("ویرایش بسته"),
      ));
    });
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "عملیات ها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 3.2,
                  context: context,
                  crossAxisCount: 1,
                  importedList: actionsWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 1,
                  importedList: actionsWidgetList),
              desktop: widgetsGridview(
                  importedList: actionsWidgetList,
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _productInfoTabCard(BuildContext context) {
    _productDetailsWidgetLIst.clear();
    setStateIfMounted(() {
      _productDetailsWidgetLIst.add(CustomTextFromFieldWidget(
        controller: _nameEditText,
        textHint: "نام بسته",
        validationError: "نام بسته را وارد کنید.",
        keyboardType: TextInputType.text,
      ));
      _productDetailsWidgetLIst.add(CustomTextFromFieldWidget(
        controller: _priceEditText,
        textHint: "قیمت بسته",
        validationError: "قیمت بسته را وارد کنید.",
        keyboardType: TextInputType.number,
      ));
      _productDetailsWidgetLIst.add(CustomTextFromFieldWidget(
        controller: _priceInDollarEditText,
        textHint: " قیمت بسته به دلار",
        validationError: "قیمت دلاری بسته را وارد کنید.",
        keyboardType: TextInputType.number,
      ));
      _productDetailsWidgetLIst.add(CustomTextFromFieldWidget(
        controller: _expireDayEditText,
        textHint: "مدت زمان اعتبار (روز) بسته",
        validationError: "مدت زمان اعتبار (روز) بسته را وارد کنید.",
        keyboardType: TextInputType.number,
      ));
      _productDetailsWidgetLIst.add(CustomTextFromFieldWidget(
        controller: _volumeEditText,
        textHint: "حجم بسته",
        validationError: "حجم بسته را وارد کنید.",
        keyboardType: TextInputType.number,
      ));
      _productDetailsWidgetLIst.add(Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
              width: 2, color: AppStyle.primaryColor.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(AppStyle.defaultPadding),
          ),
        ),
        child: DropdownButtonFormField(
          isExpanded: true,
          hint: const Text('پنل'),
          value: _selectedPannelName,
          alignment: Alignment.centerLeft,
          onChanged: (newValue) {
            setStateIfMounted(() {
              _selectedPannelName = newValue.toString();
            });
          },
          items: _pannelNameList.map((clType) {
            return DropdownMenuItem(
              value: clType,
              alignment: Alignment.centerRight,
              child: Text(clType),
            );
          }).toList(),
        ),
      ));

      _productDetailsWidgetLIst.add(Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
              width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(AppStyle.defaultPadding),
          ),
        ),
        child: SwitchListTile(
          value: _selectedPannelName.contains("Hiddify") != true
              ? _showSubscriptionLink
              : true,
          onChanged: _selectedPannelName.contains("Hiddify") != true
              ? (bool value) {
                  setStateIfMounted(() {
                    _showSubscriptionLink = value;
                  });
                }
              : null,
          title: const Text("نمایش لینک سابسکریپشن به کاربر"),
        ),
      ));
      _productDetailsWidgetLIst.add(Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
              width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(AppStyle.defaultPadding),
          ),
        ),
        child: SwitchListTile(
          value: _showPannelLink,
          onChanged: (bool value) {
            setStateIfMounted(() {
              _showPannelLink = value;
            });
          },
          title: const Text("نمایش لینک پنل به کاربر"),
        ),
      ));
      _productDetailsWidgetLIst.add(Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
              width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(AppStyle.defaultPadding),
          ),
        ),
        child: SwitchListTile(
          value: _selectedPannelName.contains("دیگر") != true
              ? _rechargable
              : false,
          onChanged: _selectedPannelName.contains("دیگر") != true
              ? (bool value) {
                  setStateIfMounted(() {
                    _rechargable = value;
                  });
                }
              : null,
          title: const Text("قابلیت شارژ مجدد توسط ربات"),
        ),
      ));
      _productDetailsWidgetLIst.add(Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
              width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(AppStyle.defaultPadding),
          ),
        ),
        child: SwitchListTile(
          value: _isActive,
          onChanged: (bool value) {
            setStateIfMounted(() {
              _isActive = value;
            });
          },
          title: const Text("قابلیت خرید (فعالسازی)"),
        ),
      ));
    });
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ویرایش",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 3.2,
                    context: context,
                    importedList: _productDetailsWidgetLIst),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4.5,
                    importedList: _productDetailsWidgetLIst),
                desktop: widgetsGridview(
                    importedList: _productDetailsWidgetLIst,
                    context: context,
                    childAspectRatio: 4.5,
                    crossAxisCount: 2),
              )),
        ],
      ),
    );
  }

  _submitData(BuildContext context) async {
    EasyLoading.show();
    int pannelID = 1;
    if (_selectedPannelName != "") {
      pannelID = int.parse(_selectedPannelName.split(":")[0]);
    }
    if (_nameEditText.text.isNotEmpty &&
        _priceEditText.text.isNotEmpty &&
        _expireDayEditText.text.isNotEmpty &&
        _volumeEditText.text.isNotEmpty) {
      var res = await editProductCategory(
          name: _nameEditText.text,
          price: int.parse(_priceEditText.text),
          priceInDollar: double.parse(_priceInDollarEditText.text),
          pannelID: pannelID,
          expDay: int.parse(_expireDayEditText.text),
          volume: int.parse(_volumeEditText.text),
          rechargable: _rechargable,
          showPannelLink: _showPannelLink,
          showSubscriptionLink: _showSubscriptionLink,
          isActive: _isActive,
          id: widget.selectedProductCategory.id.toInt());
      if (res) {
        if (context.mounted) {
          showMsg(msg: "ویرایش شد.", context: context);
          context.read<ProductCategoryProvider>().setChanged(true);
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          showMsg(msg: "خطا", context: context, type: "error");
        }
      }
    } else {
      showMsg(msg: "اطلاعات درخواست شده را وارد کنید.", context: context);
    }
    EasyLoading.dismiss();
  }
}
