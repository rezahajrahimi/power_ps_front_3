import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/cron_job_model.dart';
import 'package:powerps/repositories/cron_job_repostory.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/cron_jobs/cronjob_info_item_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class CronjobManagingScreen extends StatefulWidget {
  const CronjobManagingScreen({super.key});

  @override
  State<CronjobManagingScreen> createState() => _CronjobManagingScreenState();
}

class _CronjobManagingScreenState extends State<CronjobManagingScreen> {
  List<CronJobModel> _cronJobsItemsList = [];
  bool _showData = false;
  final List<Widget> _cronJobsItemWidgetList = [];
  @override
  void initState() {
    _fillData();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBarWithBackButton(
            context: context, title: "ویرایش پیام های خودکار"),
        body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: _showData == false
                ? const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _content(context),
          ),
        ),
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
                    _menuInfoCard(context),
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
                    // _actionInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  _menuInfoCard(BuildContext context) {
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
            "گزینه های ارسال پیام خودکار (تنها در اکانت‌های طلایی و نقره ای اجرا می شود.)",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.5,
                  context: context,
                  importedList: _cronJobsItemWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: _cronJobsItemWidgetList),
              desktop: widgetsGridview(
                  importedList: _cronJobsItemWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          )
        ],
      ),
    );
  }

  void _fillData() async {
    if (context.mounted) {
      await getAllCronJobs().then((res) {
        setState(() {
          _showData = false;
          _cronJobsItemsList = res;
          _cronJobsItemWidgetList.clear();
          for (var i in _cronJobsItemsList) {
            _cronJobsItemWidgetList.add(CronjobInfoItemWidget(
              cronJobModel: i,
            ));
          }
          _showData = true;
        });
      }).onError((error, stackTrace) {
        if (!mounted) return;

        showMsg(msg: "خطا", context: context, type: "error");
      });
    }
  }
}
