import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class AddNewInventoryPanelScreen extends StatefulWidget {
  const AddNewInventoryPanelScreen({super.key});

  @override
  State<AddNewInventoryPanelScreen> createState() =>
      _AddNewInventoryPanelScreenState();
}

class _AddNewInventoryPanelScreenState extends State<AddNewInventoryPanelScreen> {
  bool _showData = false;
  final List<Widget> _fields = [];
  final _locationEditTxt = TextEditingController();
  final _capacityEditTxt = TextEditingController(text: '1000');

  @override
  void initState() {
    super.initState();
    _fillData();
  }

  @override
  void dispose() {
    _locationEditTxt.dispose();
    _capacityEditTxt.dispose();
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
            title: 'افزودن پنل دیگر (موجودی)',
          ),
          body: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: _showData
                ? _content(context)
                : const Center(child: CircularProgressIndicator()),
          ),
          bottomNavigationBar: Responsive.isMobile(context)
              ? _buildBottomNavigationBar(context)
              : const Opacity(opacity: 1),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () => _submitData(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyle.secondaryColor,
        ),
        child: const Text('افزودن پنل', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppStyle.defaultPadding),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4)),
          ),
          child: const Text(
            'این پنل به API متصل نیست. کانفیگ‌ها را از بخش بسته‌ها با import اکسل '
            'یا به‌صورت دستی اضافه کنید و فقط فروش انجام می‌شود.',
            textDirection: TextDirection.rtl,
          ),
        ),
        SizedBox(height: AppStyle.defaultPadding),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: _panelInfoCard(context),
            ),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
            if (!Responsive.isMobile(context))
              Expanded(
                flex: 2,
                child: _operationInfoCard(context),
              ),
          ],
        ),
      ],
    );
  }

  Widget _panelInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('اطلاعات پنل', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                childAspectRatio: 2.9,
                context: context,
                importedList: _fields,
              ),
              tablet: widgetsGridview(
                context: context,
                childAspectRatio: 4.5,
                importedList: _fields,
              ),
              desktop: widgetsGridview(
                importedList: _fields,
                context: context,
                childAspectRatio: 4.5,
                crossAxisCount: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _operationInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('عملیات', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppStyle.defaultPadding),
          ElevatedButton.icon(
            onPressed: () => _submitData(context),
            icon: const Icon(Icons.add),
            label: const Text('افزودن پنل'),
          ),
        ],
      ),
    );
  }

  void _fillData() {
    setState(() {
      _fields
        ..clear()
        ..add(CustomTextFromFieldWidget(
          controller: _locationEditTxt,
          textHint: 'نام / موقعیت (مثلاً موجودی اصلی)',
          validationError: 'یک نام برای این پنل وارد کنید.',
          keyboardType: TextInputType.text,
        ))
        ..add(CustomTextFromFieldWidget(
          controller: _capacityEditTxt,
          textHint: 'ظرفیت (اختیاری)',
          validationError: 'ظرفیت را به عدد وارد کنید.',
          keyboardType: TextInputType.number,
        ));
      _showData = true;
    });
  }

  Future<void> _submitData(BuildContext context) async {
    if (_locationEditTxt.text.trim().isEmpty) {
      showMsg(
        msg: 'نام پنل را وارد کنید.',
        context: context,
        type: 'error',
      );
      return;
    }

    final capacity = int.tryParse(_capacityEditTxt.text.trim()) ?? 1000;
    if (capacity <= 0) {
      showMsg(msg: 'ظرفیت نامعتبر است.', context: context, type: 'error');
      return;
    }

    EasyLoading.show();
    final res = await addNewPannel(
      pannel: Pannel(
        id: '1',
        type: 'custome',
        location: _locationEditTxt.text.trim(),
        capacity: capacity,
      ),
    );
    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (res) {
      showMsg(msg: 'پنل با موفقیت ثبت شد.', context: context);
      Navigator.pop(context, true);
    } else {
      showMsg(
        msg: lastPannelAddError.isNotEmpty
            ? lastPannelAddError
            : 'خطا در ثبت پنل.',
        context: context,
        type: 'error',
      );
    }
  }
}
