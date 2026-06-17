import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:powerps/models/product_category_model.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/repositories/blocked_user_repository.dart';
import 'package:powerps/repositories/product_categoy_repository.dart';
import 'package:powerps/repositories/product_details_repository.dart';
import 'package:powerps/repositories/referral_setting_repository.dart';
import 'package:powerps/widgets/product_details/user_bougth_products_info_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/bot_user_model.dart';
import 'package:powerps/models/details_info.dart';
import 'package:powerps/provider/prodct_provider.dart';
import 'package:powerps/repositories/account_ballance_repository.dart';
import 'package:powerps/repositories/bot_user_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/log/recent_events_list_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/bot_user_admin_alias_widget.dart';
import 'package:powerps/widgets/public/user_group_selector_widget.dart';
import 'package:powerps/widgets/public/user_verification_toggle_widget.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/details_info_item_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:powerps/widgets/transaction/transaction_info_item_widget.dart';

class BotUserDetailsScreen extends StatefulWidget {
  const BotUserDetailsScreen({super.key, required this.id});
  final BigInt id;
  @override
  State<BotUserDetailsScreen> createState() => _BotUserDetailsScreenState();
}

class _BotUserDetailsScreenState extends State<BotUserDetailsScreen> {
  BotUser? _botUser;
  bool _showData = false;
  bool _showBoughtProduct = false;
  bool _showBlockedUser = false;
  int _lastPageOfUserBought = 1;
  int selectedPageOfUserBought = 1;

  final _ballanceController = TextEditingController();

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    _showData = false;
    _ballanceController.dispose();
    _botUser = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
            context: context,
            title: _botUser?.adminAlias?.isNotEmpty == true
                ? _botUser!.adminAlias!
                : "اطلاعات کاربر",
          ),
          body: _showData == false
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "درحال دریافت اطلاعات کاربر...",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  primary: false,
                  padding: EdgeInsets.all(AppStyle.defaultPadding),
                  child: _content(context),
                ),
        ),
      ),
    );
  }

  void _fillData() async {
    await getBotUserByID(id: widget.id.toInt()).then((value) {
      if (value != null && value != false) {
        setStateIfMounted(() {
          _botUser = value;
          _showBlockedUser = _botUser!.blockedUser != null;
          _showData = true;
        });
      }
    }).onError((e, s) {
      if (!mounted) return;
      showMsg(msg: "خطا", context: context, type: "error");
      Navigator.of(context).pop();
    });
    await getUserProductsHistoryByAccountIDWithPagination(
            userID: widget.id.toInt())
        .then((value) {
      if (!mounted) return;
      if (value != false && value != null) {
        setState(() {
          _lastPageOfUserBought = lastPageOfUserBought;

          _showBoughtProduct = true;
        });
      } else {
        showMsg(msg: "خطا", context: context, type: "error");
        debugPrint("error on dashboard biding $value");
      }
    });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  _content(BuildContext context) {
    bool changed = context.watch<ProductProvider>().changed;
    if (changed) {
      _fillData();
    }
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _mainInfoItemCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    BotUserAdminAliasWidget(
                      botUser: _botUser!,
                      onChanged: _fillData,
                    ),
                    SizedBox(height: AppStyle.defaultPadding),
                    if (_botUser?.panelUser != null &&
                        _botUser!.panelUser!.role == 'user')
                      UserVerificationToggleWidget(
                        userId: _botUser!.panelUser!.id,
                        isVerified: _botUser!.panelUser!.isVerified,
                        onChanged: _fillData,
                      ),
                    if (_botUser?.panelUser != null &&
                        _botUser!.panelUser!.role == 'user')
                      SizedBox(height: AppStyle.defaultPadding),
                    if (_botUser?.panelUser != null &&
                        (_botUser!.panelUser!.role == 'user' ||
                            _botUser!.panelUser!.role == 'agent'))
                      UserGroupSelectorWidget(
                        userId: _botUser!.panelUser!.id,
                        roleType: _botUser!.panelUser!.role,
                        currentGroupId: _botUser!.panelUser!.userGroupId,
                      ),
                    if (_botUser?.panelUser != null &&
                        (_botUser!.panelUser!.role == 'user' ||
                            _botUser!.panelUser!.role == 'agent'))
                      SizedBox(height: AppStyle.defaultPadding),
                    if (Responsive.isMobile(context))
                      _accountBallanceInfoCard(context),
                    if (Responsive.isMobile(context))
                      _referralBallanceInfoCard(context),
                    if (Responsive.isMobile(context))
                      SizedBox(height: AppStyle.defaultPadding),
                    _showBoughtProduct
                        ? _productInfoItemCard(context)
                        : Container(),
                    if (Responsive.isMobile(context))
                      SizedBox(height: AppStyle.defaultPadding),
                    if (Responsive.isMobile(context))
                      _operationInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    _transactionInfoItemCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    RecentEvents(type: "fullList", events: _botUser!.logs!),
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
                    _accountBallanceInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    _referralBallanceInfoCard(context),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color ?? Colors.white),
      label: Text(
        label,
        style: TextStyle(color: color ?? Colors.white, fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: (color ?? Colors.blue).withValues(alpha: 0.1),
        foregroundColor: color ?? Colors.white,
        side: BorderSide(color: (color ?? Colors.blue).withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  _mainInfoItemCard(BuildContext context) {
    List<Widget> mainInfoWidgetList = [
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
              icon: const Icon(Icons.fingerprint, color: Colors.blue),
              itemName: "Account Id",
              itemValue: _botUser!.accountId.toString())),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
              icon: const Icon(Icons.alternate_email, color: Colors.orange),
              itemName: "نام کاربری",
              itemValue: _botUser!.username.toString())),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
              icon: const Icon(Icons.person_outline, color: Colors.green),
              itemName: "نام",
              itemValue: "${_botUser!.firstName} ${_botUser!.lastName}")),
      if (_botUser!.adminAlias != null && _botUser!.adminAlias!.isNotEmpty)
        DetailsInfoItemWidget(
            item: DetailsInfoItem(
                icon: const Icon(Icons.label_outline, color: Colors.amberAccent),
                itemName: "اسم مستعار",
                itemValue: _botUser!.adminAlias!)),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
              icon: const Icon(Icons.calendar_today_outlined,
                  color: Colors.purple),
              itemName: "تاریخ عضویت",
              itemValue: _botUser!.createdAt)),
    ];

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_pin_outlined,
                      color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text(
                    "مشخصات کاربر",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
              IconButton(
                  onPressed: _fillData,
                  icon: const Icon(Icons.refresh,
                      color: Colors.white70, size: 20))
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.8,
                  context: context,
                  importedList: mainInfoWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: mainInfoWidgetList),
              desktop: widgetsGridview(
                  importedList: mainInfoWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _accountBallanceInfoCard(BuildContext context) {
    List<Widget> mainWidgetList = [
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        icon: const Icon(Icons.account_balance_wallet_outlined,
            color: Colors.teal),
        itemName: "موجودی کیف پول",
        itemValue: _botUser!.ballance != null
            ? "${thousandSeperatorFormatter(_botUser!.ballance!.ballance.toString())} تومان "
            : "0 تومان",
      )),
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        icon: const Icon(Icons.currency_exchange, color: Colors.amber),
        itemName: "موجودی دلاری",
        itemValue: _botUser!.ballance != null
            ? "${thousandSeperatorFormatter(_botUser!.ballance!.accountBallanceIndollar.toString())} دلار "
            : "0 دلار",
      )),
    ];

    List<Widget> actionsWidgetList = [
      _buildActionButton(
        context: context,
        label: "ویرایش تومان",
        icon: Icons.edit_note,
        onPressed: () => _editAccuntBallanceDialog(context),
      ),
      _buildActionButton(
        context: context,
        label: "ویرایش دلار",
        icon: Icons.edit_note,
        onPressed: () => _editDollarAccuntBallanceDialog(context),
      ),
      _buildActionButton(
        context: context,
        label: "افزایش تومان",
        icon: Icons.add_circle_outline,
        color: Colors.green,
        onPressed: () => _incAccuntBallanceDialog(context, type: "toman"),
      ),
      _buildActionButton(
        context: context,
        label: "کاهش تومان",
        icon: Icons.remove_circle_outline,
        color: Colors.redAccent,
        onPressed: () => _decAccuntBallanceDialog(context, type: "toman"),
      ),
      _buildActionButton(
        context: context,
        label: "افزایش دلار",
        icon: Icons.add_circle_outline,
        color: Colors.green,
        onPressed: () => _incAccuntBallanceDialog(context, type: "dollar"),
      ),
      _buildActionButton(
        context: context,
        label: "کاهش دلار",
        icon: Icons.remove_circle_outline,
        color: Colors.redAccent,
        onPressed: () => _decAccuntBallanceDialog(context, type: "dollar"),
      ),
    ];

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wallet_outlined, color: Colors.tealAccent),
              const SizedBox(width: 8),
              Text(
                "کیف پول کاربر",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.8,
                  context: context,
                  crossAxisCount: 1,
                  importedList: mainWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 1,
                  importedList: mainWidgetList),
              desktop: widgetsGridview(
                  importedList: mainWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 1),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 3.5,
                  context: context,
                  crossAxisCount: 2,
                  importedList: actionsWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2,
                  importedList: actionsWidgetList),
              desktop: widgetsGridview(
                  importedList: actionsWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _referralBallanceInfoCard(BuildContext context) {
    List<Widget> mainWidgetList = [
      DetailsInfoItemWidget(
          item: DetailsInfoItem(
        icon: const Icon(Icons.handshake_outlined, color: Colors.orange),
        itemName: "موجودی همکاری",
        itemValue: _botUser!.referralWallet != null
            ? "${thousandSeperatorFormatter(_botUser!.referralWallet!.amount.toString())} تومان "
            : "0 تومان",
      )),
    ];

    List<Widget> actionsWidgetList = [
      _buildActionButton(
        context: context,
        label: "ویرایش موجودی",
        icon: Icons.edit_note,
        onPressed: () => _editReferralBallanceDialog(context),
      ),
    ];

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_outline, color: Colors.orangeAccent),
              const SizedBox(width: 8),
              Text(
                "کیف پول همکاری",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.8,
                  context: context,
                  crossAxisCount: 1,
                  importedList: mainWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 1,
                  importedList: mainWidgetList),
              desktop: widgetsGridview(
                  importedList: mainWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 1),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 3.5,
                  context: context,
                  crossAxisCount: 1,
                  importedList: actionsWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 1,
                  importedList: actionsWidgetList),
              desktop: widgetsGridview(
                  importedList: actionsWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 1),
            ),
          ),
        ],
      ),
    );
  }

  _productInfoItemCard(BuildContext context) {
    return Column(
      children: [
        UserBougthProductsInfoCardWidget(
          title: "کانفیگ‌های خریداری شده",
          products: userBoughtProductList,
        ),
        SizedBox(height: AppStyle.defaultPadding),
        Pagination(
          numOfPages: _lastPageOfUserBought,
          selectedPage: selectedPageOfUserBought,
          pagesVisible: 4,
          onPageChanged: (page) async {
            setState(() {
              selectedPageOfUserBought = page;
              _showBoughtProduct = false;
            });
            await getUserProductsHistoryByAccountIDWithPagination(
                page: page, userID: widget.id.toInt());

            setStateIfMounted(() {
              _lastPageOfUserBought = lastPageOfUserBought;

              _showBoughtProduct = true;
            });
          },
          nextIcon: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
            size: 14,
          ),
          previousIcon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
            size: 14,
          ),
          activeTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          activeBtnStyle: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.blue),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(38),
              ),
            ),
          ),
          inactiveBtnStyle: ButtonStyle(
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(38),
            )),
          ),
          inactiveTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (Responsive.isMobile(context))
          SizedBox(height: AppStyle.defaultPadding),
        if (Responsive.isMobile(context)) // side bar mobile
          Column(
            children: [
              SizedBox(height: AppStyle.defaultPadding),
            ],
          ),
      ],
    );
  }

  _operationInfoCard(BuildContext context) {
    List<Widget> actionsWidgetList = [
      _buildActionButton(
        context: context,
        label: "ارسال پیام",
        icon: Icons.message_outlined,
        onPressed: () => _showMessageDialog(context),
      ),
      _buildActionButton(
        context: context,
        label: "خرید کانفیگ",
        icon: Icons.shopping_cart_outlined,
        color: Colors.green,
        onPressed: () => _showAddNewProductDialog(context),
      ),
      _buildActionButton(
        context: context,
        label: "همگام‌سازی",
        icon: Icons.sync,
        color: Colors.orange,
        onPressed: () => _showSyncDialog(context),
      ),
      _buildActionButton(
        context: context,
        label: _showBlockedUser ? "رفع مسدودیت" : "مسدود کردن",
        icon: _showBlockedUser ? Icons.lock_open : Icons.lock_outline,
        color: _showBlockedUser ? Colors.teal : Colors.redAccent,
        onPressed: () => _handleBlockUnblock(context),
      ),
    ];

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_suggest_outlined,
                  color: Colors.purpleAccent),
              const SizedBox(width: 8),
              Text(
                "عملیات مدیریت",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 3.5,
                  context: context,
                  crossAxisCount: 2,
                  importedList: actionsWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2,
                  importedList: actionsWidgetList),
              desktop: widgetsGridview(
                  importedList: actionsWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 1),
            ),
          ),
        ],
      ),
    );
  }

  _transactionInfoItemCard(BuildContext context) {
    List<Widget> mainInfoWidgetList = [];
    if (_botUser!.transactions != null) {
      for (var i in _botUser!.transactions!) {
        mainInfoWidgetList.add(TransactionInfoItemCardWidget(
          item: i,
        ));
      }
    }
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(
                "تراکنش‌ها",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: mainInfoWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: mainInfoWidgetList),
              desktop: widgetsGridview(
                  importedList: mainInfoWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _showMessageDialog(BuildContext context) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppStyle.secondaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.message_outlined, color: Colors.blueAccent),
              const SizedBox(width: 10),
              const Text("ارسال پیام به کاربر",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: CustomTextFromFieldWidget(
            controller: messageController,
            textHint: "متن پیام",
            validationError: "لطفا متن پیام را وارد کنید",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("انصراف", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () async {
                if (messageController.text.isEmpty) return;
                EasyLoading.show();
                await sendAdminMessageToUser(
                  userID: _botUser!.id.toInt(),
                  message: messageController.text,
                ).then((value) {
                  if (!context.mounted) return;
                  EasyLoading.dismiss();
                  if (value != null && value != false) {
                    showMsg(context: context, msg: "پیام با موفقیت ارسال شد");
                    Navigator.pop(context);
                  } else {
                    showMsg(
                        context: context,
                        msg: "خطا در ارسال پیام",
                        type: "error");
                  }
                });
              },
              child: const Text("ارسال پیام"),
            ),
          ],
        ),
      ),
    );
  }

  _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppStyle.secondaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.sync, color: Colors.orangeAccent),
              const SizedBox(width: 10),
              const Text("همگام‌سازی کاربر",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: const Text(
            "آیا از همگام‌سازی اطلاعات کاربر با ربات اطمینان دارید؟",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("انصراف", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () async {
                EasyLoading.show();
                await syncUserProductsHistoryByAccountIDwithPanels(
                        id: _botUser!.accountId.toInt())
                    .then((value) {
                  if (!context.mounted) return;
                  EasyLoading.dismiss();
                  if (value != null && value != false) {
                    showMsg(
                        context: context, msg: "همگام‌سازی با موفقیت انجام شد");
                    _fillData();
                    Navigator.pop(context);
                  } else {
                    showMsg(
                        context: context,
                        msg: "خطا در همگام‌سازی",
                        type: "error");
                  }
                });
              },
              child: const Text("تایید همگام‌سازی"),
            ),
          ],
        ),
      ),
    );
  }

  _handleBlockUnblock(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppStyle.secondaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(_showBlockedUser ? Icons.lock_open : Icons.lock_outline,
                  color: _showBlockedUser ? Colors.teal : Colors.redAccent),
              const SizedBox(width: 10),
              Text(_showBlockedUser ? "رفع مسدودیت" : "مسدود کردن کاربر",
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: Text(
            _showBlockedUser
                ? "آیا از رفع مسدودیت این کاربر اطمینان دارید؟"
                : "آیا از مسدود کردن این کاربر اطمینان دارید؟",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("انصراف", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _showBlockedUser ? Colors.teal : Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () async {
                EasyLoading.show();
                if (_showBlockedUser) {
                  await unblockUser(_botUser!.accountId.toString())
                      .then((value) {
                    EasyLoading.dismiss();
                    if (!context.mounted) return;
                    if (value) {
                      showMsg(
                          context: context,
                          msg: "کاربر با موفقیت رفع مسدودیت شد");
                      _fillData();
                      Navigator.pop(context);
                    } else {
                      showMsg(context: context, msg: "خطا", type: "error");
                    }
                  });
                } else {
                  await blockUser(
                          _botUser!.accountId.toString(), "مسدود شده توسط مدیر")
                      .then((value) {
                    EasyLoading.dismiss();
                    if (!context.mounted) return;
                    if (value) {
                      showMsg(
                          context: context, msg: "کاربر با موفقیت مسدود شد");
                      _fillData();
                      Navigator.pop(context);
                    } else {
                      showMsg(context: context, msg: "خطا", type: "error");
                    }
                  });
                }
              },
              child: const Text("تایید"),
            ),
          ],
        ),
      ),
    );
  }

  _editAccuntBallanceDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
                child: AlertDialog(
              backgroundColor: AppStyle.secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.blueAccent),
                  SizedBox(width: 10),
                  Text("ویرایش موجودی (تومان)",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("لطفا مبلغ مورد نظر خود را وارد کنید",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: AppStyle.defaultPadding),
                  CustomTextFromFieldWidget(
                    controller: _ballanceController,
                    textHint: "میزان موجودی",
                    validationError: "میزان موجودی را وارد کنید",
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("انصراف",
                      style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () async {
                    EasyLoading.show();
                    await setNewAccountBallance(
                            ballance: int.parse(_ballanceController.text),
                            userID: _botUser!.accountId.toInt())
                        .then((value) {
                      if (!context.mounted) return;
                      if (value) {
                        setState(() {
                          _botUser!.ballance!.ballance =
                              BigInt.from(int.parse(_ballanceController.text));
                        });
                        EasyLoading.dismiss();
                        showMsg(
                            context: context,
                            msg: "موجودی با موفقیت ویرایش شد");
                        _ballanceController.clear();

                        Navigator.pop(context);
                        _fillData();
                      } else {
                        EasyLoading.dismiss();
                        showMsg(context: context, msg: "خطا", type: "error");
                      }
                    });
                  },
                  child: const Text("تایید"),
                )
              ],
            ))));
  }

  _editReferralBallanceDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
                child: AlertDialog(
              backgroundColor: AppStyle.secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.orangeAccent),
                  SizedBox(width: 10),
                  Text("ویرایش موجودی همکاری",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("لطفا مبلغ مورد نظر خود را وارد کنید",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: AppStyle.defaultPadding),
                  CustomTextFromFieldWidget(
                    controller: _ballanceController,
                    textHint: "میزان موجودی",
                    validationError: "میزان موجودی را وارد کنید",
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("انصراف",
                      style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () async {
                    EasyLoading.show();
                    await setNewReferralBallance(
                            ballance: int.parse(_ballanceController.text),
                            userID: _botUser!.accountId.toInt())
                        .then((value) {
                      if (!context.mounted) return;
                      if (value) {
                        setState(() {
                          _botUser!.ballance!.ballance =
                              BigInt.from(int.parse(_ballanceController.text));
                        });
                        EasyLoading.dismiss();
                        showMsg(
                            context: context,
                            msg: "موجودی با موفقیت ویرایش شد");
                        Navigator.pop(context);
                        _ballanceController.clear();
                        _fillData();
                      } else {
                        EasyLoading.dismiss();
                        showMsg(context: context, msg: "خطا", type: "error");
                      }
                    });
                  },
                  child: const Text("تایید"),
                )
              ],
            ))));
  }

  _incAccuntBallanceDialog(BuildContext context, {required String type}) async {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
                child: AlertDialog(
              backgroundColor: AppStyle.secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.add_circle_outline, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(
                      type == "toman"
                          ? "افزایش موجودی (تومان)"
                          : "افزایش موجودی (دلار)",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("لطفا مقدار مورد نظر خود را وارد کنید",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: AppStyle.defaultPadding),
                  CustomTextFromFieldWidget(
                    controller: _ballanceController,
                    textHint: "مقدار مورد نظر",
                    validationError: "مقدار مورد نظر را وارد کنید",
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("انصراف",
                      style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () async {
                    EasyLoading.show();
                    await increaseUserAccuntBalanceByUserID(
                            ballance: double.parse(_ballanceController.text),
                            userID: _botUser!.id.toInt(),
                            type: type)
                        .then((value) {
                      if (!context.mounted) return;
                      if (value.toString() != "false") {
                        setState(() {
                          if (type == "toman") {
                            _botUser!.ballance!.ballance =
                                BigInt.from(int.parse(value));
                          } else {
                            _botUser!.ballance!.accountBallanceIndollar =
                                double.parse(value);
                          }
                        });
                        EasyLoading.dismiss();
                        showMsg(
                            context: context,
                            msg: "موجودی با موفقیت ویرایش شد");
                        _ballanceController.clear();

                        Navigator.pop(context);
                        _fillData();
                      } else {
                        EasyLoading.dismiss();
                        showMsg(context: context, msg: "خطا", type: "error");
                      }
                    });
                  },
                  child: const Text("تایید"),
                )
              ],
            ))));
  }

  _decAccuntBallanceDialog(BuildContext context, {required String type}) async {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
                child: AlertDialog(
              backgroundColor: AppStyle.secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.remove_circle_outline,
                      color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Text(
                      type == "toman"
                          ? "کاهش موجودی (تومان)"
                          : "کاهش موجودی (دلار)",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("لطفا مقدار مورد نظر خود را وارد کنید",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: AppStyle.defaultPadding),
                  CustomTextFromFieldWidget(
                    controller: _ballanceController,
                    textHint: "مقدار مورد نظر",
                    validationError: "مقدار مورد نظر را وارد کنید",
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("انصراف",
                      style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () async {
                    EasyLoading.show();
                    await decreaseUserAccuntBalanceByUserID(
                            ballance: double.parse(_ballanceController.text),
                            userID: _botUser!.id.toInt(),
                            type: type,
                            isRequestByAdmin: true)
                        .then((value) {
                      if (!context.mounted) return;
                      if (value.toString() != "false" &&
                          value.toString() != "" &&
                          value.toString() != "null") {
                        setState(() {
                          if (type == "toman") {
                            _botUser!.ballance!.ballance =
                                BigInt.from(int.parse(value));
                          } else {
                            _botUser!.ballance!.accountBallanceIndollar =
                                double.parse(value);
                          }
                        });
                        EasyLoading.dismiss();
                        showMsg(
                            context: context,
                            msg: "موجودی با موفقیت ویرایش شد");
                        _ballanceController.clear();

                        Navigator.pop(context);
                        _fillData();
                      } else {
                        EasyLoading.dismiss();
                        showMsg(context: context, msg: "خطا", type: "error");
                      }
                    });
                  },
                  child: const Text("تایید"),
                )
              ],
            ))));
  }

  _editDollarAccuntBallanceDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
                child: AlertDialog(
              backgroundColor: AppStyle.secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.amber),
                  SizedBox(width: 10),
                  Text("ویرایش موجودی (دلار)",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("لطفا مبلغ مورد نظر خود را وارد کنید",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: AppStyle.defaultPadding),
                  CustomTextFromFieldWidget(
                    controller: _ballanceController,
                    textHint: "میزان موجودی",
                    validationError: "میزان موجودی را وارد کنید",
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("انصراف",
                      style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () async {
                    EasyLoading.show();
                    await setNewDollarAccountBallance(
                            ballance: double.parse(_ballanceController.text),
                            userID: _botUser!.accountId.toInt())
                        .then((value) {
                      if (!context.mounted) return;
                      if (value) {
                        setState(() {
                          _botUser!.ballance!.accountBallanceIndollar =
                              double.parse(_ballanceController.text);
                        });
                        EasyLoading.dismiss();
                        showMsg(
                            context: context,
                            msg: "موجودی با موفقیت ویرایش شد");
                        _ballanceController.clear();

                        Navigator.pop(context);
                        _fillData();
                      } else {
                        EasyLoading.dismiss();
                        showMsg(context: context, msg: "خطا", type: "error");
                      }
                    });
                  },
                  child: const Text("تایید"),
                )
              ],
            ))));
  }

  _showAddNewProductDialog(BuildContext context) async {
    EasyLoading.show();
    List<ProductCategory> productCategoryList = [];
    List<String> productCategoryItemList = [];
    String selectedItem = "";
    final nameEditText = TextEditingController(
      text: _botUser?.accountId.toString() ?? '',
    );
    final userGroupId = _botUser?.panelUser?.userGroupId;

    await getAllProdctCategory().then((res) {
      if (res != null && res != false) {
        productCategoryList =
            (res as List<ProductCategory>).where((c) => c.isAllowedForUserGroup(userGroupId)).toList();
        for (var i in productCategoryList) {
          productCategoryItemList.add("${i.id} - ${i.categoryName}");
        }
        if (productCategoryItemList.isNotEmpty) {
          selectedItem = productCategoryItemList[0];
        }
      }
    }).whenComplete(() async {
      if (!context.mounted) return;
      EasyLoading.dismiss();
      if (productCategoryItemList.isEmpty) {
        showMsg(
          msg: "برای گروه این کاربر، کانفیگ قابل خریدی وجود ندارد",
          context: context,
          type: "warning",
        );
        return;
      }

      showDialog(
          context: context,
          builder: (context) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: AppStyle.secondaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                scrollable: true,
                contentPadding: const EdgeInsets.all(20),
                title: const Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        color: Colors.greenAccent),
                    SizedBox(width: 10),
                    Text("خرید کانفیگ جدید",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("نام کانفیگ را وارد کنید:",
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 12),
                    CustomTextFromFieldWidget(
                      controller: nameEditText,
                      textHint: "نام کانفیگ جدید",
                      validationError: "لطفا نام کانفیگ را وارد کنید",
                    ),
                    const SizedBox(height: 24),
                    const Text("کانفیگ را انتخاب کنید:",
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          dropdownColor: AppStyle.secondaryColor,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                          hint: const Text('انتخاب کانفیگ',
                              style: TextStyle(color: Colors.white54)),
                          initialValue: selectedItem,
                          onChanged: (newValue) {
                            setState(() {
                              selectedItem = newValue.toString();
                            });
                          },
                          items: productCategoryItemList.map((clType) {
                            return DropdownMenuItem(
                              value: clType,
                              child: Text(clType,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("لغو",
                        style: TextStyle(color: Colors.white70)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onPressed: () async {
                      if (nameEditText.text.isEmpty) return;
                      EasyLoading.show();
                      int prcatID = int.parse(selectedItem.split(" - ")[0]);
                      await buyProductByAdmin(
                        productID: prcatID,
                        remark: nameEditText.text,
                        username: _botUser!.username,
                        userID: _botUser!.id.toInt(),
                        accountId: _botUser!.accountId.toInt(),
                      ).then((val) {
                        if (!context.mounted) return;
                        if (val != null) {
                          EasyLoading.dismiss();
                          Navigator.pop(context);
                          showMsg(
                              context: context, msg: "خرید با موفقیت انجام شد");
                          _fillData();
                        } else {
                          EasyLoading.dismiss();
                          showMsg(context: context, msg: "خطا", type: "error");
                        }
                      }).onError((error, stackTrace) {
                        if (!context.mounted) return;
                        EasyLoading.dismiss();
                        debugPrint(error.toString());
                        showMsg(context: context, msg: "خطا", type: "error");
                      });
                    },
                    child: const Text("تایید خرید"),
                  ),
                ],
              )));
    }).onError((error, stackTrace) {
      EasyLoading.dismiss();
      if (!context.mounted) return;
      showMsg(msg: "خطا", context: context, type: "error");
    });
  }
}
