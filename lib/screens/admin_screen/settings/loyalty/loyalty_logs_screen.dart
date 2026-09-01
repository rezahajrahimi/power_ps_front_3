import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/loyalty_transaction_model.dart';
import 'package:powerps/repositories/loyalty_setting_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class LoyaltyLogsScreen extends StatefulWidget {
  const LoyaltyLogsScreen({super.key});

  @override
  State<LoyaltyLogsScreen> createState() => _LoyaltyLogsScreenState();
}

class _LoyaltyLogsScreenState extends State<LoyaltyLogsScreen> {
  bool _loading = true;
  List<LoyaltyTransactionModel> _logs = [];
  List<Map<String, dynamic>> _topUsers = [];

  int get _earnCount => _logs.where((log) => log.isEarn).length;

  int get _redeemCount => _logs.where((log) => !log.isEarn).length;

  int get _totalEarned =>
      _logs.where((log) => log.isEarn).fold(0, (sum, log) => sum + log.points);

  @override
  void initState() {
    super.initState();
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
          appBar: appBarWithBackButton(
            context: context,
            title: 'تاریخچه امتیازها',
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fillData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(AppStyle.defaultPadding),
                    child: Responsive(
                      mobile: _mobileLayout(context),
                      tablet: _desktopLayout(context),
                      desktop: _desktopLayout(context),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _summaryRow(context),
        SizedBox(height: AppStyle.defaultPadding),
        _topUsersSection(context),
        SizedBox(height: AppStyle.defaultPadding),
        _logsSection(context),
      ],
    );
  }

  Widget _desktopLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _summaryRow(context),
        SizedBox(height: AppStyle.defaultPadding),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _topUsersSection(context)),
            SizedBox(width: AppStyle.defaultPadding),
            Expanded(flex: 3, child: _logsSection(context)),
          ],
        ),
      ],
    );
  }

  Widget _summaryRow(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final items = [
      _StatChip(
        icon: Icons.history,
        label: 'کل رویدادها',
        value: '${_logs.length}',
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
        label: 'جمع امتیاز داده‌شده',
        value: thousandSeperatorFormatter(_totalEarned.toString()),
        color: Colors.lightBlueAccent,
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(children: [Expanded(child: items[0]), const SizedBox(width: 8), Expanded(child: items[1])]),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: items[2]), const SizedBox(width: 8), Expanded(child: items[3])]),
        ],
      );
    }

    return Row(
      children: items
          .map((item) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: item == items.last ? 0 : 8,
                    right: item == items.first ? 0 : 8,
                  ),
                  child: item,
                ),
              ))
          .toList(),
    );
  }

  Widget _topUsersSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(context, 'برترین کاربران', Icons.emoji_events_outlined),
          SizedBox(height: AppStyle.defaultPadding),
          if (_topUsers.isEmpty)
            const Text('هنوز کاربری امتیاز ندارد.', style: TextStyle(color: Colors.white54))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _topUsers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = _topUsers[index];
                return _TopUserTile(
                  rank: index + 1,
                  name: user['name']?.toString() ?? 'کاربر',
                  accountId: user['account_id']?.toString() ?? '',
                  balance: user['balance']?.toString() ?? '0',
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _logsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(context, 'تاریخچه فعالیت‌ها', Icons.history_outlined),
          SizedBox(height: AppStyle.defaultPadding),
          if (_logs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text('هیچ لاگی ثبت نشده است', style: TextStyle(color: Colors.white54)),
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

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppStyle.primaryColor),
        const SizedBox(width: 8),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _fillData() async {
    if (!_loading) EasyLoading.show();
    final logs = await getAllLoyaltyLogs();
    final top = await getTopLoyaltyUsers();
    EasyLoading.dismiss();
    if (!mounted) return;
    setState(() {
      _logs = logs ?? [];
      _topUsers = top ?? [];
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
              Text(value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _TopUserTile extends StatelessWidget {
  final int rank;
  final String name;
  final String accountId;
  final String balance;

  const _TopUserTile({
    required this.rank,
    required this.name,
    required this.accountId,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppStyle.bgColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.amber.withValues(alpha: 0.2),
            child: Text('$rank',
                style: const TextStyle(
                    color: Colors.amber, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('شناسه: $accountId',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white54)),
              ],
            ),
          ),
          Text('$balance امتیاز',
              style: TextStyle(
                  color: AppStyle.primaryColor, fontWeight: FontWeight.w600)),
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
                        '$sign${log.points} امتیاز — ${log.eventLabel}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(log.createdAt,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white38, fontSize: 11)),
                  ],
                ),
                if (log.userName != null || log.accountId != null)
                  Text(
                    '${log.userName ?? 'کاربر'} (${log.accountId ?? ''})',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white54),
                  ),
                if ((log.description ?? '').isNotEmpty)
                  Text(log.description!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white38)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
