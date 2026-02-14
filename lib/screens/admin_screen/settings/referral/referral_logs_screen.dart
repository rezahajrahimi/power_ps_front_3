import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/models/referral_log_model.dart';
import 'package:powerps/repositories/referral_setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class ReferralLogsScreen extends StatefulWidget {
  const ReferralLogsScreen({super.key});

  @override
  State<ReferralLogsScreen> createState() => _ReferralLogsScreenState();
}

class _ReferralLogsScreenState extends State<ReferralLogsScreen> {
  bool _showData = false;
  List<ReferralLogModel> _referralLogs = [];
  List<Map<String, dynamic>> _topReferrers = [];

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
              context: context, title: "لاگ‌های بازاریابی"),
          body: SingleChildScrollView(
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
        _topReferrersCard(context),
        SizedBox(height: AppStyle.defaultPadding),
        _referralLogsCard(context),
      ],
    );
  }

  _topReferrersCard(BuildContext context) {
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
            "کاربران برتر بازاریابی",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _topReferrers.isEmpty
              ? const Text("هیچ داده‌ای یافت نشد")
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _topReferrers.length,
                  itemBuilder: (context, index) {
                    var referrer = _topReferrers[index];
                    return ListTile(
                      title: Text(
                          "کاربر: ${referrer['referral_user']?['name'] ?? 'نامشخص'} (${referrer['referral_user']?['account_id'] ?? 'نامشخص'})"),
                      subtitle:
                          Text("تعداد دعوت: ${referrer['referral_count']}"),
                    );
                  },
                ),
        ],
      ),
    );
  }

  _referralLogsCard(BuildContext context) {
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
            "لاگ‌های بازاریابی",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _referralLogs.isEmpty
              ? const Text("هیچ داده‌ای یافت نشد")
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _referralLogs.length,
                  itemBuilder: (context, index) {
                    var log = _referralLogs[index];
                    return ListTile(
                      title: Text(
                          "دعوت کننده: ${log.referralUser?.name ?? 'نامشخص'} (${log.referralUser?.accountId ?? 'نامشخص'})"),
                      subtitle: Text(
                          "دعوت شده: ${log.referralToUser?.name ?? 'نامشخص'} (${log.referralToUser?.accountId ?? 'نامشخص'}) - مبلغ: ${log.amount} - تاریخ: ${log.createdAt}"),
                    );
                  },
                ),
        ],
      ),
    );
  }

  void _fillData() async {
    EasyLoading.show();
    var logs = await getAllReferralLogs();
    var top = await getTopReferrers();
    EasyLoading.dismiss();
    if (logs != null) {
      setState(() {
        _referralLogs = logs;
      });
    }
    if (top != null) {
      setState(() {
        _topReferrers = top;
      });
    }
    setState(() {
      _showData = true;
    });
  }
}
