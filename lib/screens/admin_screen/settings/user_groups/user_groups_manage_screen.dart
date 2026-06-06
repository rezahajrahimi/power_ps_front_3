import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/user_group_model.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/repositories/user_group_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';

class UserGroupsManageScreen extends StatefulWidget {
  const UserGroupsManageScreen({super.key});

  @override
  State<UserGroupsManageScreen> createState() => _UserGroupsManageScreenState();
}

class _UserGroupsManageScreenState extends State<UserGroupsManageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showData = false;
  List<UserGroup> _userGroups = [];
  List<UserGroup> _agentGroups = [];
  Map<String, String> _paymentKeyLabels = {};
  int _verifiedCount = 0;
  int _unverifiedCount = 0;
  int _withoutGroupCount = 0;
  List<GlobalVerificationPaymentMethod> _globalVerificationPayments = [];
  String _verificationFilter = 'all';
  List<User> _groupingUsers = [];
  bool _usersLoaded = false;
  final Map<int, List<User>> _groupMembersCache = {};
  final Set<int> _expandedGroupIds = {};

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fillData() async {
    EasyLoading.show();
    await seedDefaultUserGroups();
    final userData = await getUserGroups(roleType: 'user');
    final agentData = await getUserGroups(roleType: 'agent');

    if (!mounted) return;
    EasyLoading.dismiss();

    if (userData != null && agentData != null) {
      final stats = userData['verificationStats'] as Map<String, int>?;
      setState(() {
        _userGroups = userData['groups'];
        _agentGroups = agentData['groups'];
        _paymentKeyLabels = userData['paymentKeyLabels'];
        _verifiedCount = stats?['verified'] ?? 0;
        _unverifiedCount = stats?['unverified'] ?? 0;
        _withoutGroupCount = stats?['without_group'] ?? 0;
        _globalVerificationPayments =
            userData['globalVerificationPayments'] ?? [];
        _showData = true;
      });
      await _loadGroupingUsers();
      _groupMembersCache.clear();
      _expandedGroupIds.clear();
    } else {
      showMsg(msg: 'خطا در دریافت گروه‌ها', context: context, type: 'error');
    }
  }

  Future<void> _loadGroupMembers(int groupId) async {
    final users = await getGroupUsers(groupId: groupId);
    if (!mounted) return;
    setState(() {
      _groupMembersCache[groupId] = users ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
            context: context,
            title: 'دسته‌بندی کاربران و روش پرداخت',
          ),
          body: _showData
              ? Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'کاربران عادی'),
                        Tab(text: 'نمایندگان'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _groupsList(context, _userGroups, 'user'),
                          _groupsList(context, _agentGroups, 'agent'),
                        ],
                      ),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Future<void> _loadGroupingUsers() async {
    final filter = _verificationFilter == 'all' ? null : _verificationFilter;
    final users = await getNormalUsersForGrouping(verificationFilter: filter);
    if (!mounted) return;
    setState(() {
      _groupingUsers = users ?? [];
      _usersLoaded = true;
    });
  }

  Widget _groupsList(BuildContext context, List<UserGroup> groups, String roleType) {
    return ListView(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      children: [
        if (roleType == 'user') ...[
          _globalVerificationPaymentsCard(context),
          SizedBox(height: AppStyle.defaultPadding),
          _usersVerificationList(context),
          SizedBox(height: AppStyle.defaultPadding),
        ],
        if (roleType == 'user' && groups.isNotEmpty) ...[
          Text('گروه‌های سفارشی', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppStyle.defaultPadding / 2),
        ],
        ElevatedButton.icon(
          onPressed: () => _showCreateGroupDialog(roleType),
          icon: const Icon(Icons.add),
          label: Text(roleType == 'user' ? 'افزودن گروه سفارشی' : 'افزودن گروه نماینده'),
        ),
        SizedBox(height: AppStyle.defaultPadding),
        if (groups.isEmpty && roleType == 'user')
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'گروه سفارشی ندارید. کاربران بدون گروه از تنظیمات تایید شده/نشده استفاده می‌کنند.',
              style: TextStyle(color: AppStyle.deactiveStatus, fontSize: 12),
            ),
          ),
        ...groups.map((group) => _groupCard(context, group, roleType)),
      ],
    );
  }

  Widget _globalVerificationPaymentsCard(BuildContext context) {
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
            'کاربران بدون گروه (پیش‌فرض)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              'کاربران تایید نشده همان کاربران پیش‌فرض هستند. روش پرداخت بر اساس وضعیت تایید تعیین می‌شود.',
              style: TextStyle(color: AppStyle.deactiveStatus, fontSize: 12),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statChip('بدون گروه', _withoutGroupCount, Colors.blueAccent),
              _statChip('تایید شده', _verifiedCount, Colors.greenAccent),
              _statChip('تایید نشده', _unverifiedCount, Colors.orangeAccent),
            ],
          ),
          const Divider(),
          _globalVerificationPaymentSection(
            context: context,
            isVerified: false,
            title: 'کاربران تایید نشده (پیش‌فرض)',
            icon: Icons.person_off_outlined,
            iconColor: Colors.orangeAccent,
          ),
          const Divider(),
          _globalVerificationPaymentSection(
            context: context,
            isVerified: true,
            title: 'کاربران تایید شده',
            icon: Icons.verified_user,
            iconColor: Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _globalVerificationPaymentSection({
    required BuildContext context,
    required bool isVerified,
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    final methods = <String, bool>{};
    for (final key in _paymentKeyLabels.keys) {
      final existing = _globalVerificationPayments.where(
        (m) => m.isVerified == isVerified && m.paymentKey == key,
      );
      methods[key] = existing.isEmpty ? true : existing.first.isEnabled;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        ...methods.entries.map(
          (entry) => SwitchListTile(
            title: Text(_paymentKeyLabels[entry.key] ?? entry.key),
            value: entry.value,
            onChanged: (val) async {
              methods[entry.key] = val;
              EasyLoading.show();
              final ok = await updateGlobalVerificationPaymentMethods(
                isVerified: isVerified,
                paymentMethods: methods.entries
                    .map((e) => {
                          'payment_key': e.key,
                          'is_enabled': e.value,
                        })
                    .toList(),
              );
              EasyLoading.dismiss();
              if (!context.mounted) return;
              if (ok) {
                await _fillData();
                showMsg(msg: 'ذخیره شد', context: context);
              } else {
                showMsg(msg: 'خطا', context: context, type: 'error');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Chip(
      avatar: Icon(Icons.circle, size: 10, color: color),
      label: Text('$label: $count'),
    );
  }

  Widget _usersVerificationList(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('مدیریت تایید کاربران', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppStyle.defaultPadding / 2),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('همه'),
                selected: _verificationFilter == 'all',
                onSelected: (_) => _changeFilter('all'),
              ),
              FilterChip(
                label: const Text('تایید شده'),
                selected: _verificationFilter == 'verified',
                onSelected: (_) => _changeFilter('verified'),
              ),
              FilterChip(
                label: const Text('تایید نشده'),
                selected: _verificationFilter == 'unverified',
                onSelected: (_) => _changeFilter('unverified'),
              ),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding),
          if (!_usersLoaded)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (_groupingUsers.isEmpty)
            const Text('کاربری یافت نشد')
          else
            ..._groupingUsers.map((user) => _userVerificationTile(context, user)),
        ],
      ),
    );
  }

  Future<void> _changeFilter(String filter) async {
    setState(() {
      _verificationFilter = filter;
      _usersLoaded = false;
    });
    await _loadGroupingUsers();
  }

  Future<void> _refreshVerificationData() async {
    final userData = await getUserGroups(roleType: 'user');
    if (!mounted || userData == null) return;
    final stats = userData['verificationStats'] as Map<String, int>?;
    setState(() {
      _userGroups = userData['groups'];
      _verifiedCount = stats?['verified'] ?? 0;
      _unverifiedCount = stats?['unverified'] ?? 0;
    });
    await _loadGroupingUsers();
  }

  Widget _userVerificationTile(BuildContext context, User user) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(user.name.isNotEmpty ? user.name : 'کاربر ${user.accountId}'),
      subtitle: Text(
        'ID: ${user.accountId}${user.userGroupName != null ? ' | گروه: ${user.userGroupName}' : ''}',
      ),
      trailing: Switch(
        value: user.isVerified,
        onChanged: (val) async {
          EasyLoading.show();
          final updated = await updateUserVerificationStatus(
            userId: user.id,
            isVerified: val,
          );
          EasyLoading.dismiss();
          if (!context.mounted) return;
          if (updated != null) {
            await _refreshVerificationData();
            showMsg(msg: val ? 'تایید شد' : 'تایید لغو شد', context: context);
          } else {
            showMsg(msg: 'خطا', context: context, type: 'error');
          }
        },
      ),
      leading: Icon(
        user.isVerified ? Icons.verified_user : Icons.person_off_outlined,
        color: user.isVerified ? Colors.greenAccent : Colors.orangeAccent,
      ),
    );
  }

  Widget _groupCard(BuildContext context, UserGroup group, String roleType) {
    final methods = <String, bool>{};
    for (final key in _paymentKeyLabels.keys) {
      final existing = group.paymentMethods.where((m) => m.paymentKey == key);
      methods[key] = existing.isEmpty ? true : existing.first.isEnabled;
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (group.isDefault)
                const Chip(label: Text('پیش‌فرض')),
              Text('${group.usersCount} کاربر'),
              if (roleType == 'user') ...[
                const SizedBox(width: 8),
                Icon(Icons.verified_user, size: 14, color: Colors.greenAccent),
                Text('${group.verifiedUsersCount}'),
                const SizedBox(width: 4),
                Icon(Icons.person_off_outlined, size: 14, color: Colors.orangeAccent),
                Text('${group.unverifiedUsersCount}'),
              ],
              IconButton(
                tooltip: 'حذف گروه',
                onPressed: group.isDefault ? null : () => _confirmDeleteGroup(group),
                icon: Icon(
                  Icons.delete_outline,
                  color: group.isDefault ? Colors.grey : Colors.redAccent,
                ),
              ),
            ],
          ),
          const Divider(),
          _groupMembersSection(context, group, roleType),
          const Divider(),
          Text(
            'روش‌های پرداخت عمومی گروه',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              roleType == 'user'
                  ? 'در صورت عدم تنظیم جداگانه، برای همه کاربران این گروه اعمال می‌شود.'
                  : 'روش‌های پرداخت مجاز برای نمایندگان این گروه',
              style: TextStyle(color: AppStyle.deactiveStatus, fontSize: 12),
            ),
          ),
          ...methods.entries.map(
            (entry) => SwitchListTile(
              title: Text(_paymentKeyLabels[entry.key] ?? entry.key),
              value: entry.value,
              onChanged: (val) async {
                methods[entry.key] = val;
                EasyLoading.show();
                final ok = await updateUserGroupPaymentMethods(
                  groupId: group.id,
                  paymentMethods: methods.entries
                      .map((e) => {
                            'payment_key': e.key,
                            'is_enabled': e.value,
                          })
                      .toList(),
                );
                EasyLoading.dismiss();
                if (!context.mounted) return;
                if (ok) {
                  await _fillData();
                  showMsg(msg: 'ذخیره شد', context: context);
                } else {
                  showMsg(msg: 'خطا', context: context, type: 'error');
                }
              },
            ),
          ),
          if (roleType == 'user') ...[
            const Divider(),
            _verificationPaymentSection(
              context: context,
              group: group,
              isVerified: true,
              title: 'روش‌های پرداخت — کاربران تایید شده',
              icon: Icons.verified_user,
              iconColor: Colors.greenAccent,
              generalMethods: methods,
            ),
            const Divider(),
            _verificationPaymentSection(
              context: context,
              group: group,
              isVerified: false,
              title: 'روش‌های پرداخت — کاربران تایید نشده',
              icon: Icons.person_off_outlined,
              iconColor: Colors.orangeAccent,
              generalMethods: methods,
            ),
          ],
        ],
      ),
    );
  }

  Widget _verificationPaymentSection({
    required BuildContext context,
    required UserGroup group,
    required bool isVerified,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Map<String, bool> generalMethods,
  }) {
    final hasCustom = group.hasCustomVerificationPayments(isVerified);
    final verificationMethods = <String, bool>{};
    for (final key in _paymentKeyLabels.keys) {
      verificationMethods[key] = group.isVerificationPaymentEnabled(
        isVerified,
        key,
        generalMethods[key] ?? true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
            ),
            if (hasCustom)
              TextButton(
                onPressed: () async {
                  EasyLoading.show();
                  final ok = await clearUserGroupVerificationPaymentMethods(
                    groupId: group.id,
                    isVerified: isVerified,
                  );
                  EasyLoading.dismiss();
                  if (!context.mounted) return;
                  if (ok) {
                    await _fillData();
                    showMsg(msg: 'بازگشت به تنظیمات عمومی', context: context);
                  } else {
                    showMsg(msg: 'خطا', context: context, type: 'error');
                  }
                },
                child: const Text('بازگشت به عمومی'),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            hasCustom
                ? 'تنظیم اختصاصی فعال است.'
                : 'از تنظیمات عمومی گروه استفاده می‌شود. با تغییر هر گزینه، تنظیم اختصاصی ذخیره می‌شود.',
            style: TextStyle(color: AppStyle.deactiveStatus, fontSize: 12),
          ),
        ),
        ...verificationMethods.entries.map(
          (entry) => SwitchListTile(
            title: Text(_paymentKeyLabels[entry.key] ?? entry.key),
            value: entry.value,
            onChanged: (val) async {
              verificationMethods[entry.key] = val;
              EasyLoading.show();
              final ok = await updateUserGroupVerificationPaymentMethods(
                groupId: group.id,
                isVerified: isVerified,
                paymentMethods: verificationMethods.entries
                    .map((e) => {
                          'payment_key': e.key,
                          'is_enabled': e.value,
                        })
                    .toList(),
              );
              EasyLoading.dismiss();
              if (!context.mounted) return;
              if (ok) {
                await _fillData();
                showMsg(msg: 'ذخیره شد', context: context);
              } else {
                showMsg(msg: 'خطا', context: context, type: 'error');
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateGroupDialog(String roleType) async {
    final nameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('گروه جدید'),
          content: CustomTextFromFieldWidget(
            controller: nameController,
            textHint: 'نام گروه',
            validationError: 'نام گروه را وارد کنید',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                EasyLoading.show();
                final group = await createUserGroup(
                  name: nameController.text,
                  roleType: roleType,
                );
                EasyLoading.dismiss();
                if (!context.mounted) return;
                Navigator.pop(context);
                if (group != null) {
                  await _fillData();
                  showMsg(msg: 'گروه ایجاد شد', context: context);
                } else {
                  showMsg(msg: 'خطا', context: context, type: 'error');
                }
              },
              child: const Text('ایجاد'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
  }

  Widget _groupMembersSection(
      BuildContext context, UserGroup group, String roleType) {
    final isExpanded = _expandedGroupIds.contains(group.id);
    final members = _groupMembersCache[group.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'اعضای گروه',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddUsersToGroupDialog(group, roleType),
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: const Text('افزودن'),
            ),
            IconButton(
              onPressed: () async {
                if (isExpanded) {
                  setState(() => _expandedGroupIds.remove(group.id));
                } else {
                  setState(() => _expandedGroupIds.add(group.id));
                  if (members == null) {
                    EasyLoading.show();
                    await _loadGroupMembers(group.id);
                    EasyLoading.dismiss();
                  }
                }
              },
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            ),
          ],
        ),
        if (isExpanded) ...[
          if (members == null)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (members.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('هیچ کاربری در این گروه نیست'),
            )
          else
            ...members.map((user) => _groupMemberTile(context, user, group)),
        ],
      ],
    );
  }

  Widget _groupMemberTile(BuildContext context, User user, UserGroup group) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: const Icon(Icons.person_outline),
      title: Text(user.name.isNotEmpty ? user.name : 'کاربر ${user.accountId}'),
      subtitle: Text('ID: ${user.accountId}'),
      trailing: IconButton(
        tooltip: 'حذف از گروه',
        onPressed: () => _confirmRemoveUserFromGroup(user, group),
        icon: const Icon(Icons.person_remove_outlined, color: Colors.redAccent),
      ),
    );
  }

  Future<void> _confirmRemoveUserFromGroup(User user, UserGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف از گروه'),
          content: Text(
            'آیا "${user.name.isNotEmpty ? user.name : user.accountId}" از گروه "${group.name}" حذف شود؟\nکاربر بدون گروه می‌شود و روش پرداخت بر اساس وضعیت تایید اعمال می‌شود.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لغو'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    EasyLoading.show();
    final result = await removeUserFromGroup(userId: user.id);
    EasyLoading.dismiss();
    if (!mounted) return;

    if (result != null) {
      await _loadGroupMembers(group.id);
      await _fillData();
      showMsg(msg: 'کاربر از گروه حذف شد', context: context);
    } else {
      showMsg(msg: 'خطا', context: context, type: 'error');
    }
  }

  Future<void> _showAddUsersToGroupDialog(
      UserGroup group, String roleType) async {
    final searchController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: _AddUsersToGroupDialog(
          group: group,
          roleType: roleType,
          searchController: searchController,
          parentContext: context,
          onAdded: () async {
            if (_expandedGroupIds.contains(group.id)) {
              await _loadGroupMembers(group.id);
            }
            await _fillData();
          },
        ),
      ),
    );
    searchController.dispose();
  }

  Future<void> _confirmDeleteGroup(UserGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف گروه'),
          content: Text(
            'آیا گروه "${group.name}" حذف شود؟\n${group.usersCount} کاربر بدون گروه می‌شوند.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لغو'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    EasyLoading.show();
    final ok = await deleteUserGroup(id: group.id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (ok) {
      _groupMembersCache.remove(group.id);
      _expandedGroupIds.remove(group.id);
      await _fillData();
      showMsg(msg: 'گروه حذف شد', context: context);
    } else {
      showMsg(msg: 'گروه پیش‌فرض قابل حذف نیست', context: context, type: 'error');
    }
  }
}

class _AddUsersToGroupDialog extends StatefulWidget {
  const _AddUsersToGroupDialog({
    required this.group,
    required this.roleType,
    required this.searchController,
    required this.parentContext,
    required this.onAdded,
  });

  final UserGroup group;
  final String roleType;
  final TextEditingController searchController;
  final BuildContext parentContext;
  final Future<void> Function() onAdded;

  @override
  State<_AddUsersToGroupDialog> createState() => _AddUsersToGroupDialogState();
}

class _AddUsersToGroupDialogState extends State<_AddUsersToGroupDialog> {
  List<User> _availableUsers = [];
  final Set<int> _selectedIds = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loaded = false);
    final users = await getNormalUsersForGrouping(
      roleType: widget.roleType,
      excludeGroupId: widget.group.id,
      search: widget.searchController.text.trim().isEmpty
          ? null
          : widget.searchController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _availableUsers = users ?? [];
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('افزودن به گروه "${widget.group.name}"'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: widget.searchController,
              decoration: InputDecoration(
                labelText: 'جستجو (نام یا ID)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _loadUsers,
                ),
              ),
              onSubmitted: (_) => _loadUsers(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: !_loaded
                  ? const Center(child: CircularProgressIndicator())
                  : _availableUsers.isEmpty
                      ? const Center(child: Text('کاربری برای افزودن یافت نشد'))
                      : ListView.builder(
                          itemCount: _availableUsers.length,
                          itemBuilder: (context, index) {
                            final user = _availableUsers[index];
                            return CheckboxListTile(
                              value: _selectedIds.contains(user.id),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedIds.add(user.id);
                                  } else {
                                    _selectedIds.remove(user.id);
                                  }
                                });
                              },
                              title: Text(
                                user.name.isNotEmpty
                                    ? user.name
                                    : 'کاربر ${user.accountId}',
                              ),
                              subtitle: Text(
                                'ID: ${user.accountId}${user.userGroupName != null ? ' | گروه فعلی: ${user.userGroupName}' : ''}',
                              ),
                              secondary: user.isVerified
                                  ? const Icon(Icons.verified_user,
                                      color: Colors.greenAccent, size: 20)
                                  : null,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('لغو'),
        ),
        TextButton(
          onPressed: _selectedIds.isEmpty
              ? null
              : () async {
                  EasyLoading.show();
                  final added = await addUsersToGroup(
                    groupId: widget.group.id,
                    userIds: _selectedIds.toList(),
                  );
                  EasyLoading.dismiss();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  if (added != null && added.isNotEmpty) {
                    await widget.onAdded();
                    if (widget.parentContext.mounted) {
                      showMsg(
                        msg: '${added.length} کاربر به گروه اضافه شد',
                        context: widget.parentContext,
                      );
                    }
                  } else if (widget.parentContext.mounted) {
                    showMsg(
                      msg: 'خطا',
                      context: widget.parentContext,
                      type: 'error',
                    );
                  }
                },
          child: Text('افزودن (${_selectedIds.length})'),
        ),
      ],
    );
  }
}
