import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/loyalty_transaction_model.dart';
import 'package:powerps/repositories/loyalty_setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class LoyaltyReportScreen extends StatefulWidget {
  final BigInt accountId;
  final String? userName;
  final int? currentBalance;

  const LoyaltyReportScreen({
    super.key,
    required this.accountId,
    this.userName,
    this.currentBalance,
  });

  @override
  State<LoyaltyReportScreen> createState() => _LoyaltyReportScreenState();
}

class _LoyaltyReportScreenState extends State<LoyaltyReportScreen> {
  static const _perPage = 15;

  bool _loading = true;
  List<LoyaltyTransactionModel> _logs = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  int _earnCount = 0;
  int _redeemCount = 0;
  int _totalEarned = 0;
  int _currentBalance = 0;

  @override
  void initState() {
    super.initState();
    _currentBalance = widget.currentBalance ?? 0;
    _fillData();
  }

  BoxDecoration _sectionDecoration() {
    return BoxDecoration(
      color: AppStyle.secondaryColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppStyle.bgColor,
          appBar: appBarWithBackButton(
            context: context,
            title: 'تاریخچه امتیاز کاربر',
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => _fillData(page: _currentPage),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(AppStyle.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _userHeader(context),
                        SizedBox(height: AppStyle.defaultPadding),
                        _summaryRow(context),
                        SizedBox(height: AppStyle.defaultPadding),
                        _logsSection(context),
                        if (_lastPage > 1) ...[
                          SizedBox(height: AppStyle.defaultPadding),
                          _pagination(),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _userHeader(BuildContext context) {
    final name = widget.userName?.trim().isNotEmpty == true
        ? widget.userName!.trim()
        : 'کاربر ${widget.accountId}';

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.amber.withValues(alpha: 0.15),
            child: const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'شناسه تلگرام: ${widget.accountId}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'موجودی فعلی',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white54),
              ),
              Text(
                '${thousandSeperatorFormatter(_currentBalance.toString())} امتیاز',
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final items = [
      _StatChip(
        icon: Icons.history,
        label: 'کل رویدادها',
        value: '$_total',
        color: Colors.amber,
      ),
      _StatChip(
        icon: Icons.add_circle_outline,
        label: 'امتیازدهی',
        value: '$_earnCount',
        color: Colors.greenAccent,
      ),
      _StatChip(
        icon: Icons.remove_circle_outline,
        label: 'مصرف امتیاز',
        value: '$_redeemCount',
        color: Colors.orangeAccent,
      ),
      _StatChip(
        icon: Icons.stars,
        label: 'جمع امتیاز کسب‌شده',
        value: thousandSeperatorFormatter(_totalEarned.toString()),
        color: Colors.lightBlueAccent,
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: items[0]),
              const SizedBox(width: 8),
              Expanded(child: items[1]),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: items[2]),
              const SizedBox(width: 8),
              Expanded(child: items[3]),
            ],
          ),
        ],
      );
    }

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: item == items.last ? 0 : 8,
                  right: item == items.first ? 0 : 8,
                ),
                child: item,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _logsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.history_outlined,
                  size: 20, color: AppStyle.primaryColor),
              const SizedBox(width: 8),
              Text(
                'تاریخچه فعالیت‌ها',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_total > 0)
                Text(
                  'صفحه $_currentPage از $_lastPage',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white38),
                ),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding),
          if (_logs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 48, color: Colors.white24),
                    SizedBox(height: 12),
                    Text(
                      'هیچ فعالیت امتیازی برای این کاربر ثبت نشده است.',
                      style: TextStyle(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _LogTile(log: _logs[index]),
            ),
        ],
      ),
    );
  }

  Widget _pagination() {
    return Pagination(
      numOfPages: _lastPage,
      selectedPage: _currentPage,
      pagesVisible: 4,
      onPageChanged: (page) => _fillData(page: page),
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
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
        ),
      ),
      inactiveBtnStyle: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
        ),
      ),
      inactiveTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Future<void> _fillData({int page = 1}) async {
    if (!_loading) EasyLoading.show();

    final result = await getLoyaltyLogsByAccountId(
      userID: widget.accountId.toInt(),
      page: page,
      perPage: _perPage,
    );

    EasyLoading.dismiss();
    if (!mounted) return;

    if (result == null) {
      setState(() => _loading = false);
      showMsg(
        context: context,
        msg: 'خطا در دریافت تاریخچه امتیاز',
        type: 'error',
      );
      return;
    }

    final summary = result['summary'] as Map<String, dynamic>? ?? {};

    setState(() {
      _logs = List<LoyaltyTransactionModel>.from(result['logs'] ?? []);
      _currentPage = result['current_page'] ?? 1;
      _lastPage = result['last_page'] ?? 1;
      _total = result['total'] ?? 0;
      _earnCount = summary['earn_count'] ?? 0;
      _redeemCount = summary['redeem_count'] ?? 0;
      _totalEarned = summary['total_earned'] ?? 0;
      _currentBalance = summary['current_balance'] ?? _currentBalance;
      _loading = false;
    });
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final LoyaltyTransactionModel log;

  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final accent = log.isEarn ? Colors.greenAccent : Colors.orangeAccent;
    final sign = log.points > 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppStyle.bgColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              log.isEarn ? Icons.add : Icons.remove,
              color: accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log.eventLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$sign${log.points}',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  log.createdAt,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white38, fontSize: 11),
                ),
                if ((log.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    log.description!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white54),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
