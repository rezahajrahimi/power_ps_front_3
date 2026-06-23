import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/log_model.dart';
import 'package:powerps/repositories/loyalty_setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/log/recent_events_list_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class LoyaltyReportScreen extends StatefulWidget {
  final BigInt accountId;
  const LoyaltyReportScreen({super.key, required this.accountId});

  @override
  State<LoyaltyReportScreen> createState() => _LoyaltyReportScreenState();
}

class _LoyaltyReportScreenState extends State<LoyaltyReportScreen> {
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
            context: context,
            title: 'تاریخچه امتیاز کاربر',
          ),
          body: SingleChildScrollView(
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
        await getLoyaltyLogsByAccountId(userID: widget.accountId.toInt());
    if (!mounted) return;

    final events = <Log>[];
    if (logs != null) {
      for (final item in logs) {
        final sign = item.points > 0 ? '+' : '';
        events.add(
          Log(
            id: BigInt.from(item.id),
            accountId: widget.accountId,
            createdAt: item.createdAt,
            event:
                '$sign${item.points} امتیاز — ${item.eventLabel}${(item.description ?? '').isNotEmpty ? ' — ${item.description}' : ''}',
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
        child: Text('هیچ فعالیت امتیازی برای این کاربر ثبت نشده است.'),
      );
    }
    return RecentEvents(type: 'fullList', events: _events);
  }
}
