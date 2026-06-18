import 'package:flutter/material.dart';
import 'package:powerps/models/log_model.dart';
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
  bool _loading = true;
  List<Log> _events = [];

  @override
  void initState() {
    super.initState();
    _fillData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
              context: context, title: "گزارش کیف پول همکاری کاربر"),
          body: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _content(context),
          ),
        ),
      ),
    );
  }

  Future<void> _fillData() async {
    final logs =
        await getReferralLogsByAccountId(userID: widget.accountId.toInt());
    if (!mounted) return;

    final events = <Log>[];
    if (logs != null) {
      for (final item in logs) {
        final inviteeName =
            item.referralToUser?.name ?? 'کاربر ${item.referralToUser?.accountId ?? ''}';
        final event = item.amount == 0
            ? 'کاربر $inviteeName با لینک شما وارد ربات شد'
            : 'کمیسیون ${item.amount} تومان از واریز $inviteeName';
        events.add(
          Log(
            id: BigInt.from(item.id),
            accountId: widget.accountId,
            createdAt: item.createdAt,
            event: event,
          ),
        );
      }
    }

    setState(() {
      _events = events;
      _loading = false;
    });
  }

  Widget _content(BuildContext context) {
    if (_events.isEmpty) {
      return const Center(
        child: Text('هیچ فعالیت بازاریابی برای این کاربر ثبت نشده است.'),
      );
    }

    return Column(
      children: [
        RecentEvents(type: "fullList", events: _events),
      ],
    );
  }
}
