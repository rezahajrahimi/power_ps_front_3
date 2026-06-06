import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/repositories/panel_user_repository.dart';
import 'package:powerps/screens/admin_screen/settings/agent/agent_detail_screen.dart';
import 'package:powerps/screens/admin_screen/settings/agent/agent_form_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/agent/agent_info_widget.dart';
import 'package:powerps/widgets/agent/agent_screen_shared.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class AgentsManageScreen extends StatefulWidget {
  const AgentsManageScreen({super.key});

  @override
  State<AgentsManageScreen> createState() => _AgentsManageScreenState();
}

class _AgentsManageScreenState extends State<AgentsManageScreen> {
  List<User> _agents = [];
  List<User> _filteredAgents = [];
  bool _loading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilter);
    _loadAgents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final query = _searchController.text.trim();
    setState(() {
      if (query.isEmpty) {
        _filteredAgents = List.from(_agents);
      } else {
        _filteredAgents = _agents
            .where((a) =>
                a.name.contains(query) ||
                a.accountId.toString().contains(query) ||
                (a.userGroupName?.contains(query) ?? false))
            .toList();
      }
    });
  }

  Future<void> _loadAgents() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final agents = await getAgents();
      if (!mounted) return;

      if (agents == null) {
        setState(() {
          _loading = false;
          _error = "خطا در دریافت لیست دستیاران";
        });
        return;
      }

      setState(() {
        _agents = agents;
        _filteredAgents = List.from(agents);
        _loading = false;
      });
      _applyFilter();
    } catch (e) {
      debugPrint("Error fetching agents: $e");
      if (mounted) {
        setState(() {
          _loading = false;
          _error = "خطا در برقراری ارتباط";
        });
      }
    }
  }

  Future<void> _openAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AgentFormScreen(mode: AgentFormMode.create),
      ),
    );
    if (result == true) _loadAgents();
  }

  Future<void> _openDetail(User agent) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AgentDetailScreen(agent: agent)),
    );
    if (result == true) _loadAgents();
  }

  Future<void> _openEdit(User agent) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgentFormScreen(mode: AgentFormMode.edit, agent: agent),
      ),
    );
    if (result == true) _loadAgents();
  }

  Future<void> _showDeleteDialog(User agent) async {
    final confirmed = await showAgentConfirmDialog(
      context: context,
      title: 'حذف دستیار فروش',
      message:
          'با حذف دستیار فروش، تمام اکانت‌های این کاربر به مدیر ربات منتقل می‌شود و نقش او به کاربر عادی تغییر می‌کند.\n\nآیا از حذف «${agent.name}» اطمینان دارید؟',
      confirmLabel: 'حذف',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;

    EasyLoading.show();
    final result = await removeAgent(userID: agent.accountId);
    EasyLoading.dismiss();
    if (!mounted) return;

    if (result == true) {
      showMsg(msg: "با موفقیت حذف شد", context: context);
      _loadAgents();
    } else {
      showMsg(msg: "خطا در حذف دستیار فروش", context: context, type: "error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
            context: context,
            title: isMobile
                ? "دستیاران فروش"
                : "دستیاران فروش (اکانت‌های نقره‌ای و طلایی)",
          ),
          floatingActionButton: isMobile
              ? FloatingActionButton.extended(
                  onPressed: _openAddScreen,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text("افزودن"),
                )
              : null,
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError()
                  : agentCenteredContent(
                      context,
                      child: _buildBody(context),
                    ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: agentScreenPadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAgents,
              icon: const Icon(Icons.refresh),
              label: const Text("تلاش مجدد"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        children: [
          Padding(
            padding: agentScreenPadding(context),
            child: _buildHeader(context),
          ),
          Expanded(child: _buildAgentsList(context)),
        ],
      );
    }

    return Padding(
      padding: agentScreenPadding(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                Expanded(child: _buildAgentsList(context)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 280,
            child: _sidebarActions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AgentSectionCard(
      title: "لیست دستیاران فروش (${_agents.length})",
      subtitle: _filteredAgents.length != _agents.length
          ? "${_filteredAgents.length} نتیجه از ${_agents.length} دستیار"
          : "جستجو بر اساس نام، شناسه تلگرام یا گروه کاربری",
      children: [
        TextField(
        controller: _searchController,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        decoration: agentRtlInputDecoration(
          label: "جستجو",
          hint: "نام، شناسه یا گروه...",
          suffixIcon: const Icon(Icons.search),
          prefixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
        onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildAgentsList(BuildContext context) {
    if (_filteredAgents.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAgents,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: agentScreenPadding(context),
          children: [_buildEmptyState()],
        ),
      );
    }

    final columns = agentGridColumns(context);

    return RefreshIndicator(
      onRefresh: _loadAgents,
      child: columns == 1
          ? ListView.separated(
              padding: agentScreenPadding(context),
              itemCount: _filteredAgents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) => _agentTile(_filteredAgents[index]),
            )
          : GridView.builder(
              padding: agentScreenPadding(context),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: Responsive.isTablet(context) ? 2.4 : 2.8,
              ),
              itemCount: _filteredAgents.length,
              itemBuilder: (_, index) => _agentTile(_filteredAgents[index]),
            ),
    );
  }

  Widget _agentTile(User agent) {
    return AgentInfoWidget(
      agent: agent,
      productCount: agent.agentProductsCount,
      compact: Responsive.isMobile(context),
      onTap: () => _openDetail(agent),
      onEdit: () => _openEdit(agent),
      onDelete: () => _showDeleteDialog(agent),
    );
  }

  Widget _buildEmptyState() {
    final isFiltered = _searchController.text.isNotEmpty;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppStyle.defaultPadding * 2),
      child: Center(
        child: Column(
          children: [
            Icon(
              isFiltered ? Icons.search_off : Icons.people_outline,
              size: 48,
              color: Colors.white38,
            ),
            const SizedBox(height: 12),
            Text(
              isFiltered
                  ? "دستیاری با این مشخصات یافت نشد"
                  : "هنوز دستیار فروشی تعریف نشده",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            if (!isFiltered) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openAddScreen,
                icon: const Icon(Icons.add),
                label: const Text("افزودن اولین دستیار"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sidebarActions(BuildContext context) {
    return AgentSectionCard(
      title: "عملیات",
      subtitle: "مدیریت دستیاران فروش",
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _openAddScreen,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text("افزودن دستیار فروش"),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "تعداد کل: ${_agents.length}",
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
