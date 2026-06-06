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
      MaterialPageRoute(builder: (_) => const AgentFormScreen(mode: AgentFormMode.create)),
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

  void _showDeleteDialog(User agent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف دستیار فروش'),
        content: const Text(
          'با حذف دستیار فروش تمام اکانت‌های این کاربر به مدیر ربات منتقل می‌شود و کاربر به کاربر عادی تغییر خواهد کرد. اطمینان دارید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () async {
              EasyLoading.show();
              final result = await removeAgent(userID: agent.accountId);
              EasyLoading.dismiss();
              if (!context.mounted) return;
              Navigator.pop(ctx);
              if (result == true) {
                showMsg(msg: "با موفقیت حذف شد", context: context);
                _loadAgents();
              } else {
                showMsg(msg: "خطا در حذف دستیار فروش", context: context, type: "error");
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
            title: "دستیاران فروش (اکانت‌های نقره‌ای و طلایی)",
          ),
          floatingActionButton: Responsive.isMobile(context)
              ? FloatingActionButton.extended(
                  onPressed: _openAddScreen,
                  icon: const Icon(Icons.add),
                  label: const Text("افزودن"),
                )
              : null,
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError()
                  : RefreshIndicator(
                      onRefresh: _loadAgents,
                      child: _buildBody(context),
                    ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAgents,
            child: const Text("تلاش مجدد"),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: _agentListSection(context),
          ),
        ),
        if (!Responsive.isMobile(context)) ...[
          SizedBox(width: AppStyle.defaultPadding),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(AppStyle.defaultPadding),
              child: _sidebarActions(context),
            ),
          ),
        ],
      ],
    );
  }

  Widget _agentListSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "لیست دستیاران فروش (${_agents.length})",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_filteredAgents.length != _agents.length)
                Text(
                  "${_filteredAgents.length} نتیجه",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "جستجو بر اساس نام، شناسه یا گروه...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: AppStyle.defaultPadding),
          if (_filteredAgents.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredAgents.length,
              itemBuilder: (_, index) {
                final agent = _filteredAgents[index];
                return AgentInfoWidget(
                  agent: agent,
                  productCount: agent.agentProductsCount,
                  onTap: () => _openDetail(agent),
                  onEdit: () => _openEdit(agent),
                  onDelete: () => _showDeleteDialog(agent),
                );
              },
            ),
        ],
      ),
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
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("عملیات", style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openAddScreen,
              icon: const Icon(Icons.add),
              label: const Text("افزودن دستیار فروش"),
            ),
          ),
        ],
      ),
    );
  }
}
