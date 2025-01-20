import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/models/agent_permisson_model.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/provider/agent/agent_provider.dart';
import 'package:powerps/repositories/agent_permission_repository.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/agent/agent_select_category_with_inputs_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class EditAgentScreen extends StatefulWidget {
  const EditAgentScreen({super.key, required this.agent});
  final User agent;

  @override
  State<EditAgentScreen> createState() => _EditAgentScreenState();
}

class _EditAgentScreenState extends State<EditAgentScreen> {
  bool _showData = false;
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
    _fillData();
  }

  @override
  void dispose() {
    _minusBallance = false;
    _deleteProducts = false;
    _showData = false;
    _productCatWidgetLIst.clear();
    _productCatWidgetLIstAdded.clear();
    _maxTrafficLimitationTxtController.dispose();
    _maxProdouctLimitationTxtController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar:
            appBarWithBackButton(context: context, title: "ویرایش دستیار فروش"),
        body: SafeArea(
          child: SingleChildScrollView(
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
        ),
        bottomNavigationBar: Responsive.isMobile(context)
            ? _buildBottomNavigationBar(context)
            : const Opacity(opacity: 1),
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
                      Icons.done,
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
    await getAgentProductsWithNotSelectedByUserID(userID: widget.agent.id)
        .then((val) {
      if (!mounted) return;

      Provider.of<AgentProvider>(context, listen: false).clearAgentCategories();

      Provider.of<AgentProvider>(context, listen: false)
          .clearAgentCategoriesAdded();

      if (val != null) {
        List<AgentAddCategoriyModel> list = [];
        for (var i in val) {
          list.add(AgentAddCategoriyModel(
            id: i.id,
            price: i.price,
            productCategories: i,
            newPrice: null,
            priceInDollar: i.priceInDollar,
            newPriceInDollar: null,
          ));
        }
        Provider.of<AgentProvider>(context, listen: false)
            .setAgentCategories(list);
      }
    });
    await getAgentProductsByUserID(userID: widget.agent.id).then((val) {
      List<AgentAddCategoriyModel> addedlist = [];
      for (var i in val) {
        addedlist.add(i);
      }
      if (!mounted) return;

      Provider.of<AgentProvider>(context, listen: false)
          .setAgentCategoriesAdded(addedlist);
    });
    await getUserPremissionByAgentID(userID: widget.agent.id).then((value) {
      if (value == false) {
        if (!mounted) return;

        showMsg(
            type: "error",
            msg: "شما مجوز دسترسی به این صفحه را ندارید",
            context: context);
        Navigator.pop(context);
        return;
      }
      final agPer = AgentPermisson(
          userId: value.userId,
          createProducts: value.createProducts,
          deleteProducts: value.deleteProducts,
          minusBallance: value.minusBallance,
          productLimitation: value.productLimitation,
          trafficLimitationTB: value.trafficLimitationTB);
      setState(() {
        _minusBallance = agPer.minusBallance;
        // _createProducts = agentPermisson.createProducts;
        _deleteProducts = agPer.deleteProducts;
        _maxProdouctLimitationTxtController.text =
            agPer.productLimitation.toString();
        _maxTrafficLimitationTxtController.text =
            agPer.trafficLimitationTB.toString();
      });
    }).onError((error, stackTrace) {
      debugPrint(error.toString());
    });

    setState(() {
      _showData = true;
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
        icon: const Icon(Icons.done),
        label: const Text("ذخیره"),
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
                  childAspectRatio: 5,
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

    await createAndEditBatchOfUserAgentProduct(
            agentPermisson: AgentPermisson(
                userId: 0,
                createProducts: false,
                deleteProducts: _deleteProducts,
                minusBallance: _minusBallance,
                productLimitation:
                    int.parse(_maxProdouctLimitationTxtController.text),
                trafficLimitationTB:
                    double.parse(_maxTrafficLimitationTxtController.text)),
            userID: widget.agent.accountId,
            gentAddCategoriyList:
                Provider.of<AgentProvider>(context, listen: false)
                    .getAgentCategoriesAdded())
        .then((val) {
      if (val) {
        // EasyLoading.dismiss();
        // showMsg(msg: "دستیار فروش با موفقیت ایجاد شد.", context: context);
        return;
      }
      EasyLoading.dismiss();
      if (!context.mounted) return;

      showMsg(msg: "خطا", context: context, type: "error");
      return;
    }).whenComplete(() async {
      if (!context.mounted) return;

      Provider.of<AgentProvider>(context, listen: false).clearAgentCategories();
      Provider.of<AgentProvider>(context, listen: false)
          .clearAgentCategoriesAdded();
      await deleteBatchOfUserAgentProduct(
              userID: widget.agent.accountId,
              gentAddCategoriyList:
                  Provider.of<AgentProvider>(context, listen: false)
                      .getAgentCategories())
          .then((val) {
        if (!context.mounted) return;

        if (val) {
          EasyLoading.dismiss();
          showMsg(msg: "دستیار فروش با موفقیت ویرایش شد.", context: context);
          Navigator.of(context).pop();
          return;
        }
        EasyLoading.dismiss();
        showMsg(msg: "خطا", context: context, type: "error");
        return;
      }).onError((e, s) {
        if (!context.mounted) return;

        EasyLoading.dismiss();
        showMsg(msg: "خطا", context: context, type: "error");
      });
    }).onError((e, s) {
      if (!context.mounted) return;
      EasyLoading.dismiss();
      showMsg(msg: "خطا", context: context, type: "error");
    });
  }

  _productInfoTabCard(BuildContext context) {
    final agentCategories = context.watch<AgentProvider>().agentCategories;

    setState(() {
      _productCatWidgetLIst.clear();
      for (var i in agentCategories) {
        _productCatWidgetLIst
            .add(AgentSelectCategoryWithPriceInputWidget(type: "add", item: i));
      }
      if (_productCatWidgetLIst.isEmpty) {
        _productCatWidgetLIst.add(const Text("تمام بسته‌ها انتخاب شده‌اند."));
      }
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
            "کانفیگ ها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          if (_productCatWidgetLIst.isNotEmpty)
            SizedBox(
                width: double.infinity,
                child: Responsive(
                  mobile: widgetsGridview(
                      childAspectRatio: 2.8,
                      context: context,
                      importedList: _productCatWidgetLIst),
                  tablet: widgetsGridview(
                      context: context,
                      childAspectRatio: 4,
                      importedList: _productCatWidgetLIst),
                  desktop: widgetsGridview(
                      importedList: _productCatWidgetLIst,
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
        Text("در حال ویرایش مشخصات ${widget.agent.name} هستید."),
        const SizedBox(),
        const Text("آیا دستیار فروش می تواند موجودی حساب منفی داشته باشد؟"),
        Switch(
            value: _minusBallance,
            onChanged: (val) {
              setState(() {
                _minusBallance = val;
              });
            }),
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

    setState(() {
      _productCatWidgetLIstAdded.clear();
      for (var i in agentCategoriesAdded) {
        _productCatWidgetLIstAdded.add(
            AgentSelectCategoryWithPriceInputWidget(type: "minus", item: i));
      }
      if (_productCatWidgetLIstAdded.isEmpty) {
        _productCatWidgetLIstAdded
            .add(const Text("هیچ بسته‌ای انتخاب نشده است."));
      }
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
            " افزوده شده",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          if (_productCatWidgetLIstAdded.isNotEmpty)
            SizedBox(
                width: double.infinity,
                child: Responsive(
                  mobile: widgetsGridview(
                      childAspectRatio: 2.8,
                      context: context,
                      importedList: _productCatWidgetLIstAdded),
                  tablet: widgetsGridview(
                      context: context,
                      childAspectRatio: 4,
                      importedList: _productCatWidgetLIstAdded),
                  desktop: widgetsGridview(
                      importedList: _productCatWidgetLIstAdded,
                      context: context,
                      childAspectRatio: 4.0,
                      crossAxisCount: 2),
                )),
        ],
      ),
    );
  }
}
