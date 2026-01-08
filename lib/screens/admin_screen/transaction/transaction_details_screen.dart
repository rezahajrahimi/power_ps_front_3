import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/details_info.dart';

import 'package:powerps/models/transaction_model.dart';
import 'package:powerps/repositories/payment_type_repository.dart';
import 'package:powerps/repositories/transaction_repositopry.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/details_info_item_widget.dart';
import 'package:powerps/widgets/public/image_view_tab_v4_widget.dart';

class TransactionDetailsScreen extends StatefulWidget {
  const TransactionDetailsScreen({
    super.key,
    required this.item,
  });
  final Transaction item;

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  bool _isLoading = true;
  String _imageSrc = "";
  bool _showImage = false;
  final TextEditingController _amountTxtController = TextEditingController();
  final TextEditingController _recipeNUmberTxtController =
      TextEditingController();
  String _selectedTransactionStatus = "تایید نشده";
  final List<String> _transactionStatusList = ["تایید نشده", "تایید شده"];
  String? _selectedPaymentType;

  final List<String> _paymentTypeList = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);

    if (widget.item.amount != null) {
      _amountTxtController.text = widget.item.amount.toString();
    }
    if (widget.item.recipeNumber != null) {
      _recipeNUmberTxtController.text = widget.item.recipeNumber.toString();
    }

    _selectedTransactionStatus =
        widget.item.confirmed ? "تایید شده" : "تایید نشده";

    if (widget.item.image != null) {
      _imageSrc = "$imageURL${widget.item.image!.imgSrc}";
      _showImage = true;
    }

    await getAllActiveOfflinePaymentTypes();
    if (paymentTypesList.isNotEmpty) {
      _paymentTypeList.clear();
      for (var i in paymentTypesList) {
        _paymentTypeList.add("${i.id}: ${i.name}");
      }
      if (widget.item.paymentType != null) {
        _selectedPaymentType =
            "${widget.item.paymentType!.id}: ${widget.item.paymentType!.name}";
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBarWithBackButton(
            context: context,
            title:
                "تراکنش  ${widget.item.accountId} - ${widget.item.botUser?.username ?? ''}"),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(AppStyle.defaultPadding),
                  child: _content(context),
                ),
        ),
        bottomNavigationBar: Responsive.isMobile(context)
            ? _buildBottomNavigationBar(context)
            : null,
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  if (Responsive.isMobile(context) && _showImage)
                    _imageCard(context),
                  _mainInfoCard(context),
                  const SizedBox(height: 20),
                  if (Responsive.isMobile(context)) _operationInfoCard(context),
                ],
              ),
            ),
            if (!Responsive.isMobile(context)) ...[
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _operationInfoCard(context),
                    const SizedBox(height: 20),
                    if (_showImage) _imageCard(context),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _mainInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("جزییات تراکنش", Icons.receipt_long_outlined),
          const SizedBox(height: 20),
          _buildInfoGrid([
            DetailsInfoItemWidget(
                item: DetailsInfoItem(
                    icon: const Icon(Icons.info),
                    itemName: "Account Id",
                    itemValue: widget.item.accountId.toString())),
            DetailsInfoItemWidget(
                item: DetailsInfoItem(
                    icon: const Icon(Icons.person),
                    itemName: "نام کاربر",
                    itemValue: widget.item.botUser?.username ?? "نامشخص")),
            DetailsInfoItemWidget(
                item: DetailsInfoItem(
                    icon: const Icon(Icons.calendar_today),
                    itemName: "زمان ایجاد",
                    itemValue: widget.item.createdAt ?? "نامشخص")),
            _buildStatusDropdown(),
            if (widget.item.paymentType?.type == "online")
              DetailsInfoItemWidget(
                  item: DetailsInfoItem(
                      icon: const Icon(Icons.payment),
                      itemName: "درگاه پرداخت",
                      itemValue: widget.item.paymentType?.name ?? "نامشخص"))
            else
              _buildPaymentTypeDropdown(),
            if (widget.item.paymentType?.type == "online")
              DetailsInfoItemWidget(
                  item: DetailsInfoItem(
                      icon: const Icon(Icons.currency_exchange),
                      itemName: "مقدار واریزی (تومان)",
                      itemValue: thousandSeperatorFormatter(
                          widget.item.amount.toString())))
            else
              CustomTextFromFieldWidget(
                  controller: _amountTxtController,
                  keyboardType: TextInputType.number,
                  labelText: "مقدار واریزی (تومان)",
                  textHint: "مقدار واریزی را وارد کنید",
                  validationError: "مقدار واریزی را وارد کنید"),
            if (widget.item.paymentType?.type == "online")
              DetailsInfoItemWidget(
                  item: DetailsInfoItem(
                      icon: const Icon(Icons.offline_pin),
                      itemName: "کد پیگیری رسید واریزی",
                      itemValue: widget.item.recipeNumber
                          .toString()
                          .replaceAll(RegExp(r'^0+(?=\d)'), '')))
            else
              CustomTextFromFieldWidget(
                  controller: _recipeNUmberTxtController,
                  labelText: "کد پیگیری رسید",
                  textHint: "کد پیگیری رسید واریزی را وارد کنید",
                  validationError: "کد پیگیری رسید واریزی را وارد کنید"),
          ]),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppStyle.primaryColor),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(List<Widget> children) {
    return Responsive(
      mobile: Column(
          children: children
              .map((e) =>
                  Padding(padding: const EdgeInsets.only(bottom: 10), child: e))
              .toList()),
      tablet: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: children,
      ),
      desktop: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: children,
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppStyle.primaryColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedTransactionStatus,
        decoration: const InputDecoration(
            labelText: "وضعیت تراکنش", border: InputBorder.none),
        items: _transactionStatusList
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => _selectedTransactionStatus = v!),
      ),
    );
  }

  Widget _buildPaymentTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppStyle.primaryColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedPaymentType,
        decoration: const InputDecoration(
            labelText: "درگاه پرداخت", border: InputBorder.none),
        items: _paymentTypeList
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => _selectedPaymentType = v),
      ),
    );
  }

  Widget _operationInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("عملیات ها", Icons.settings),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: AppStyle.primaryColor,
                  ),
                  onPressed: () => _editTransaction(context),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text("ویرایش تراکنش",
                      style: TextStyle(color: Colors.white)),
                ),
                if (!widget.item.confirmed) ...[
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.red.withValues(alpha: 0.8),
                    ),
                    onPressed: () => _deleteTransaction(context),
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: const Text("حذف تراکنش",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("تصویر تراکنش", Icons.image),
          const SizedBox(height: 20),
          CustomImageView(imageSrc: _imageSrc),
          if (widget.item.image?.userText != null) ...[
            const SizedBox(height: 10),
            Text("پیام کاربر:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppStyle.primaryColor)),
            Text(widget.item.image!.userText!),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: AppStyle.primaryColor,
        ),
        onPressed: () => _editTransaction(context),
        child: const Text("ثبت تغییرات",
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Future<void> _editTransaction(BuildContext context) async {
    if (_amountTxtController.text.isEmpty ||
        _recipeNUmberTxtController.text.isEmpty) {
      showMsg(
          msg: "لطفا تمام فیلدها را پر کنید", context: context, type: "error");
      return;
    }

    EasyLoading.show();
    try {
      int? paymentTypeId;
      if (_selectedPaymentType != null) {
        paymentTypeId = int.tryParse(_selectedPaymentType!.split(":")[0]);
      }
      if (!context.mounted) return;

      final success = await editUserTranaction(
        amount: int.parse(_amountTxtController.text),
        confirmed: _selectedTransactionStatus == "تایید شده",
        id: widget.item.id.toInt(),
        paymentTypeId: paymentTypeId ?? int.parse(widget.item.paymentType!.id),
        recipeNUmber: _recipeNUmberTxtController.text,
      );
      if (!context.mounted) return;
      if (success) {
        showMsg(msg: "تراکنش با موفقیت ویرایش شد", context: context);
        Navigator.pop(context, true);
      } else {
        showMsg(msg: "خطا در ویرایش تراکنش", context: context, type: "error");
      }
    } catch (e) {
      showMsg(msg: "خطا: $e", context: context, type: "error");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> _deleteTransaction(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("حذف تراکنش"),
        content: const Text("آیا از حذف این تراکنش اطمینان دارید؟"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("انصراف")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("حذف", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      EasyLoading.show();
      final success = await removeUnconfirmedTransaction(
          transactionId: widget.item.id.toInt());
      EasyLoading.dismiss();
      if (!context.mounted) return;

      if (success) {
        showMsg(msg: "تراکنش حذف شد", context: context);
        Navigator.pop(context, true);
      } else {
        showMsg(msg: "خطا در حذف تراکنش", context: context, type: "error");
      }
    }
  }
}
