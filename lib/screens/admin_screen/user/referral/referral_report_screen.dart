import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/log_model.dart';
import 'package:powerps/repositories/log_repository.dart';
import 'package:powerps/repositories/referral_setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/log/recent_events_list_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class ReferralReportScreen extends StatefulWidget {
  final BigInt accountId;
  const ReferralReportScreen({super.key, required this.accountId});

  @override
  State<ReferralReportScreen> createState() => _ReferralReportScreenState();
}

class _ReferralReportScreenState extends State<ReferralReportScreen> {
  bool _showData = false;
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
            context: context, title: "گزارش کیف پول همکاری کاربر"),
        body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: _showData == false
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _content(context),
          ),
        ),
        // bottomNavigationBar: Responsive.isMobile(context)
        //     ? _buildBottomNavigationBar(context)
        //     : const Opacity(opacity: 1),
      ),
    );
  }

  void _fillData() async {
    await getReferralLogsByAccountId(userID: widget.accountId.toInt())
        .then((value) {
      if (value != null && value.isNotEmpty) {
        setState(() {
          lastLogList.clear();
          for (var i in value) {
            lastLogList.add(Log(
                id: BigInt.from(i.id),
                accountId: BigInt.from(i.referralUser!.accountId),
                createdAt: i.createdAt,
                event: i.amount == 0
                    ? " کاربر ${i.referralUser!.name} توسط لینک شما وارد ربات شد"
                    : " سسسسس"));
          }
          _showData = true;
        });
      }
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
                  RecentEvents(type: "fullList", events: lastLogList),
                ],
              ),
            ),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
          ],
        )
      ],
    );
  }
}
