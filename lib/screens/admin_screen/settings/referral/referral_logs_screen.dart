import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/responsive.dart';
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
  bool _loading = true;
  List<ReferralLogModel> _referralLogs = [];
  List<Map<String, dynamic>> _topReferrers = [];

  @override
  void initState() {
    super.initState();
    _fillData();
  }

  EdgeInsets _screenPadding(BuildContext context) {
    return EdgeInsets.all(AppStyle.defaultPadding);
  }

  BoxDecoration _sectionDecoration() {
    return BoxDecoration(
      color: AppStyle.secondaryColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    );
  }

  int get _signupCount =>
      _referralLogs.where((log) => log.amount == 0).length;

  int get _commissionCount =>
      _referralLogs.where((log) => log.amount > 0).length;

  double get _totalCommission => _referralLogs
      .where((log) => log.amount > 0)
      .fold(0.0, (sum, log) => sum + log.amount);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
            context: context,
            title: 'لاگ‌های بازاریابی',
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fillData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: _screenPadding(context),
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
        _topReferrersSection(context),
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
            Expanded(
              flex: 2,
              child: _topReferrersSection(context),
            ),
            SizedBox(width: AppStyle.defaultPadding),
            Expanded(
              flex: 3,
              child: _logsSection(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryRow(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final items = [
      _StatChip(
        icon: Icons.groups_outlined,
        label: 'کل رویدادها',
        value: '${_referralLogs.length}',
        color: AppStyle.primaryColor,
      ),
      _StatChip(
        icon: Icons.person_add_outlined,
        label: 'دعوت‌ها',
        value: '$_signupCount',
        color: Colors.blueAccent,
      ),
      _StatChip(
        icon: Icons.payments_outlined,
        label: 'کمیسیون‌ها',
        value: '$_commissionCount',
        color: Colors.greenAccent,
      ),
      _StatChip(
        icon: Icons.emoji_events_outlined,
        label: 'معرف‌های برتر',
        value: '${_topReferrers.length}',
        color: Colors.amberAccent,
      ),
    ];

    if (isMobile) {
      return SizedBox(
        height: 92,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, index) => SizedBox(width: 140, child: items[index]),
        ),
      );
    }

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: AppStyle.defaultPadding / 2),
          Expanded(child: items[i]),
        ],
      ],
    );
  }

  Widget _topReferrersSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(
            context,
            'کاربران برتر بازاریابی',
            Icons.leaderboard_outlined,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          if (_topReferrers.isEmpty)
            _emptyState(
              icon: Icons.emoji_events_outlined,
              message: 'هنوز معرفی ثبت نشده است',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _topReferrers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final referrer = _topReferrers[index];
                final name =
                    referrer['referral_user']?['name']?.toString() ?? 'نامشخص';
                final accountId =
                    referrer['referral_user']?['account_id']?.toString() ??
                        '—';
                final count = referrer['referral_count']?.toString() ?? '0';

                return _TopReferrerTile(
                  rank: index + 1,
                  name: name,
                  accountId: accountId,
                  inviteCount: count,
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
          Row(
            children: [
              Expanded(
                child: _sectionTitle(
                  context,
                  'تاریخچه فعالیت‌ها',
                  Icons.history_outlined,
                ),
              ),
              if (_totalCommission > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'جمع کمیسیون: ${_totalCommission.toStringAsFixed(0)} تومان',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding),
          if (_referralLogs.isEmpty)
            _emptyState(
              icon: Icons.inbox_outlined,
              message: 'هیچ لاگی ثبت نشده است',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _referralLogs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _LogTile(log: _referralLogs[index]);
              },
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
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _emptyState({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.white24),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _fillData() async {
    if (!_loading) EasyLoading.show();
    final logs = await getAllReferralLogs();
    final top = await getTopReferrers();
    EasyLoading.dismiss();

    if (!mounted) return;
    setState(() {
      _referralLogs = logs ?? [];
      _topReferrers = top ?? [];
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
        mainAxisAlignment: MainAxisAlignment.center,
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TopReferrerTile extends StatelessWidget {
  final int rank;
  final String name;
  final String accountId;
  final String inviteCount;

  const _TopReferrerTile({
    required this.rank,
    required this.name,
    required this.accountId,
    required this.inviteCount,
  });

  Color get _rankColor => switch (rank) {
        1 => Colors.amberAccent,
        2 => Colors.blueGrey.shade200,
        3 => Colors.orangeAccent.shade100,
        _ => Colors.white38,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppStyle.bgColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _rankColor.withValues(alpha: 0.2),
            child: Text(
              '$rank',
              style: TextStyle(
                color: _rankColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'شناسه: $accountId',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppStyle.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$inviteCount دعوت',
              style: TextStyle(
                color: AppStyle.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final ReferralLogModel log;

  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final isSignup = log.amount == 0;
    final accent = isSignup ? Colors.blueAccent : Colors.greenAccent;

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
              isSignup ? Icons.person_add_outlined : Icons.payments_outlined,
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
                        isSignup
                            ? 'دعوت جدید'
                            : 'کمیسیون ${log.amount.toStringAsFixed(0)} تومان',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      log.createdAt,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _logDetailRow(
                  'دعوت‌کننده',
                  '${log.referralUser?.name ?? 'نامشخص'} (${log.referralUser?.accountId ?? '—'})',
                ),
                const SizedBox(height: 4),
                _logDetailRow(
                  'دعوت‌شده',
                  '${log.referralToUser?.name ?? 'نامشخص'} (${log.referralToUser?.accountId ?? '—'})',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
