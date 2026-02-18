import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/models/agent_permisson_model.dart';
import 'package:powerps/provider/agent/agent_provider.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/repositories/panel_user_repository.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/agent/agent_select_category_with_inputs_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class AddNewAgentScreen extends StatefulWidget {
  const AddNewAgentScreen({super.key});

  @override
  State<AddNewAgentScreen> createState() => _AddNewAgentScreenState();
}

class _AddNewAgentScreenState extends State<AddNewAgentScreen> {
  bool _showData = false;
  final List _userList = [];
  String _selectedUserName = "";
  final List<Widget> _productCatWidgetLIst = [];
  final List<Widget> _productCatWidgetLIstAdded = [];
  bool _minusBallance = false;
  // bool _createProducts = false;
  bool _deleteProducts = false;
  final TextEditingController _maxTrafficLimitationTxtController =
      TextEditingController();
  final TextEditingController _maxProdouctLimitationTxtController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _maxTrafficLimitationTxtController.text = "10";
    _maxProdouctLimitationTxtController.text = "1000";
    _fillData();
  }

  @override
  void dispose() {
    super.dispose();
    _maxTrafficLimitationTxtController.dispose();
    _maxProdouctLimitationTxtController.dispose();

    _minusBallance = false;
    _deleteProducts = false;
    _showData = false;
    _productCatWidgetLIst.clear();
    _productCatWidgetLIstAdded.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
              context: context, title: "افزودن دستیار فروش"),
          body: SingleChildScrollView(
            primary: false,
            child: Padding(
              padding: EdgeInsets.all(AppStyle.defaultPadding),
              child: Column(
                children: [
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
          bottomNavigationBar: Responsive.isMobile(context)
              ? _buildBottomNavigationBar(context)
              : const Opacity(opacity: 1),
        ),
      ),
    );
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
                      Icons.add,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "ذخیره",
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
                  _agentInfoTabCard(context),
                  SizedBox(width: AppStyle.defaultPadding),
                  _productInfoTabCard(context),
                  SizedBox(width: AppStyle.defaultPadding),
                  _productAddedInfoTabCard(context),
                ],
              ),
            ),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
            // On Mobile means if the screen is less than 850 we dont want to show it
            if (!Responsive.isMobile(context)) // side windows
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _operationInfoCard(context),
                  ],
                ),
              ),
          ],
        )
      ],
    );
  }

  void _fillData() async {
    await getAllProdctCategory().then((val) {
      if (!mounted) return;

      Provider.of<AgentProvider>(context, listen: false).clearAgentCategories();

      Provider.of<AgentProvider>(context, listen: false)
          .clearAgentCategoriesAdded();

      if (val != null) {
        List<AgentAddCategoriyModel> list = [];
        for (var i in val) {
          list.add(AgentAddCategoriyModel(
            id: i.id,
            productCategories: i,
            price: i.price,
            newPrice: null,
            priceInDollar: i.priceInDollar,
            newPriceInDollar: null,
          ));
        }
        Provider.of<AgentProvider>(context, listen: false)
            .setAgentCategories(list);
      }
    });
    await getNormalUsers().then((val) {
      if (val != null && val.isNotEmpty) {
        setState(() {
          for (var i in val) {
            _userList.add("${i.accountId}: ${i.name}");
          }
          _selectedUserName = "${val[0].accountId}: ${val[0].name}";
        });
      }

      setState(() {
        _showData = true;
      });
    });
  }

  _operationInfoCard(BuildContext context) {
    List<Widget> actionsWidgetList = [];

    setState(() {
      actionsWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          await _submitData(context);
        },
        icon: const Icon(Icons.add),
        label: const Text("افزودن"),
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
                  childAspectRatio: 2.9,
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

  Future<void> _submitData(BuildContext context) async {
    EasyLoading.show();
    if (_selectedUserName.isEmpty) {
      EasyLoading.dismiss();
      showMsg(msg: "لطفا یک کاربر را انتخاب کنید.", context: context);
      return;
    }
    int selectedUserTelID = int.parse(_selectedUserName.split(':')[0].trim());

    await createAndEditBatchOfUserAgentProduct(
            agentPermisson: AgentPermisson(
              userId: 0,
              createProducts: false,
              deleteProducts: _deleteProducts,
              minusBallance: _minusBallance,
              productLimitation:
                  int.tryParse(_maxProdouctLimitationTxtController.text) ?? 0,
              trafficLimitationTB:
                  double.tryParse(_maxTrafficLimitationTxtController.text) ?? 0,
            ),
            userID: selectedUserTelID,
            gentAddCategoriyList:
                Provider.of<AgentProvider>(context, listen: false)
                    .getAgentCategoriesAdded())
        .then((val) {
      EasyLoading.dismiss();
      if (!context.mounted) return;

      if (val == true) {
        showMsg(msg: "دستیار فروش با موفقیت ایجاد شد.", context: context);
        Navigator.of(context).pop();
        return;
      }
      if (!context.mounted) return;

      showMsg(
          msg: val is String ? val : "خطا در ایجاد دستیار فروش",
          context: context,
          type: "error");
    }).onError((e, s) {
      if (!context.mounted) return;
      EasyLoading.dismiss();
      showMsg(msg: "خطا در برقراری ارتباط", context: context, type: "error");
    });
  }

  _productInfoTabCard(BuildContext context) {
    final agentCategories = context.watch<AgentProvider>().agentCategories;

    List<Widget> productCatWidgetLIst = [];
    for (var i in agentCategories) {
      productCatWidgetLIst
          .add(AgentSelectCategoryWithPriceInputWidget(type: "add", item: i));
    }
    if (productCatWidgetLIst.isEmpty) {
      productCatWidgetLIst.add(const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("تمام بسته‌ها انتخاب شده‌اند."),
      ));
    }

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
            "بسته‌های قابل انتخاب",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 2.8,
                    context: context,
                    importedList: productCatWidgetLIst),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4,
                    importedList: productCatWidgetLIst),
                desktop: widgetsGridview(
                    importedList: productCatWidgetLIst,
                    context: context,
                    childAspectRatio: 4.0,
                    crossAxisCount: 2),
              )),
        ],
      ),
    );
  }

  _agentInfoTabCard(BuildContext context) {
    List<Widget> myWidgetList = [];
    List<Widget> limitationWidgetList = [];
    setState(() {
      myWidgetList = [
        const Text("کاربر را انتخاب کنید."),
        DropdownButtonFormField(
          isExpanded: true,
          hint: const Text('کاربر'),
          initialValue: _selectedUserName,
          alignment: Alignment.centerRight,
          onChanged: (newValue) {
            setState(() {
              _selectedUserName = newValue.toString();
            });
          },
          items: _userList.map((user) {
            return DropdownMenuItem(
              value: user,
              alignment: Alignment.centerRight,
              child: Text(user),
            );
          }).toList(),
        ),
        const Text("آیا دستیار فروش می تواند موجودی حساب منفی داشته باشد؟"),
        Switch(
            value: _minusBallance,
            onChanged: (val) {
              setState(() {
                _minusBallance = val;
              });
            }),
        // const Text("آیا دستیار فروش می تواند بسته دلخواه ایجاد کند؟"),
        // Switch(
        //     value: _createProducts,
        //     onChanged: (val) {
        //       setState(() {
        //         _createProducts = val;
        //       });
        //     }),
        const Text(
            "آیا دستیار فروش می تواند اکانت های دارای حجم مصرف شده با کمتر از 0.5GB را حذف کند؟"),
        Switch(
            value: _deleteProducts,
            onChanged: (val) {
              setState(() {
                _deleteProducts = val;
              });
            }),
      ];
      limitationWidgetList = [
        CustomTextFromFieldWidget(
          controller: _maxProdouctLimitationTxtController,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: false, signed: false),
          textHint: "محدودیت تعداد فروش کانفیگ",
          validationError:
              "تعداد کانفیگی که دستیار فروش می تواند به فروش برساند را وارد کنید.",
        ),
        CustomTextFromFieldWidget(
          controller: _maxTrafficLimitationTxtController,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: false),
          textHint: "محدودیت ترافیک(ترابایت)",
          validationError:
              "ترافیک قابل فروش توسط این دستیار فروش به ترابایت را وارد کنید.",
        ),
      ];
    });
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Text(
              "ورود اطلاعات دستیار فروش",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 1.8,
                  context: context,
                  crossAxisCount: 2,
                  importedList: myWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 8,
                  crossAxisCount: 2,
                  importedList: myWidgetList),
              desktop: widgetsGridview(
                  importedList: myWidgetList,
                  context: context,
                  childAspectRatio: 8,
                  crossAxisCount: 2),
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 4.5,
                  context: context,
                  crossAxisCount: 1,
                  importedList: limitationWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2,
                  importedList: limitationWidgetList),
              desktop: widgetsGridview(
                  importedList: limitationWidgetList,
                  context: context,
                  childAspectRatio: 5.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _productAddedInfoTabCard(BuildContext context) {
    final agentCategoriesAdded =
        context.watch<AgentProvider>().agentCategoriesAdded;

    List<Widget> productCatWidgetLIstAdded = [];
    for (var i in agentCategoriesAdded) {
      productCatWidgetLIstAdded.add(
          AgentSelectCategoryWithPriceInputWidget(type: "remove", item: i));
    }
    if (productCatWidgetLIstAdded.isEmpty) {
      productCatWidgetLIstAdded.add(const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("هیچ بسته‌ای انتخاب نشده است."),
      ));
    }

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
            "بسته‌های انتخاب شده",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 2.8,
                    context: context,
                    importedList: productCatWidgetLIstAdded),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 4,
                    importedList: productCatWidgetLIstAdded),
                desktop: widgetsGridview(
                    importedList: productCatWidgetLIstAdded,
                    context: context,
                    childAspectRatio: 4.0,
                    crossAxisCount: 2),
              )),
        ],
      ),
    );
  }
}
