import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/agent_detail_model.dart';
import 'package:powerps/models/agent_permisson_model.dart';
import 'package:powerps/models/bought_product_details_model.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/repositories/agent_manage_repository.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/screens/admin_screen/settings/agent/agent_form_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class AgentDetailScreen extends StatefulWidget {
  const AgentDetailScreen({super.key, required this.agent});

  final User agent;

  @override
  State<AgentDetailScreen> createState() => _AgentDetailScreenState();
}

class _AgentDetailScreenState extends State<AgentDetailScreen> {
  AgentDetailModel? _detail;
  bool _loading = true;
  String? _error;

  List<BoughtProductDetailsModel> _sales = [];
  int _salesLastPage = 1;
  int _salesCurrentPage = 1;
  bool _loadingSales = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final detail = await getAgentDetailById(id: widget.agent.id);
    if (!mounted) return;
    setState(() {
      _detail = detail;
      _loading = false;
      _error = detail == null ? "خطا در دریافت اطلاعات دستیار" : null;
    });
    if (detail != null) {
      await _loadSales(page: 1);
    }
  }

  Future<void> _loadSales({required int page}) async {
    setState(() => _loadingSales = true);
    final result = await getAgentSelledProductsByAdmin(
      userId: widget.agent.id,
      page: page,
    );
    if (!mounted) return;
    setState(() {
      _loadingSales = false;
      if (result != null) {
        _sales = result.products;
        _salesLastPage = result.lastPage;
        _salesCurrentPage = page;
      }
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
            title: "جزئیات دستیار فروش",
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError()
                  : RefreshIndicator(
                      onRefresh: _loadDetail,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(AppStyle.defaultPadding),
                        child: _buildContent(context),
                      ),
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
            onPressed: _loadDetail,
            child: const Text("تلاش مجدد"),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final detail = _detail!;
    final permission = detail.permission;
    final user = detail.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoCard(context, detail),
        SizedBox(height: AppStyle.defaultPadding),
        _balanceCard(context, user),
        SizedBox(height: AppStyle.defaultPadding),
        if (permission != null) _permissionsCard(context, permission),
        SizedBox(height: AppStyle.defaultPadding),
        _productsCard(context, detail),
        SizedBox(height: AppStyle.defaultPadding),
        _salesCard(context, user),
        SizedBox(height: AppStyle.defaultPadding),
        _actionsCard(context),
      ],
    );
  }

  Widget _infoCard(BuildContext context, AgentDetailModel detail) {
    return _card(
      context,
      title: "اطلاعات کاربر",
      children: [
        _row("نام", detail.user.name),
        _row("شناسه تلگرام", detail.user.accountId.toString()),
        if (detail.user.userGroupName != null)
          _row("گروه کاربری", detail.user.userGroupName!),
        _row(
          "وضعیت تایید",
          detail.user.isVerified ? "تایید شده" : "تایید نشده",
        ),
      ],
    );
  }

  Widget _balanceCard(BuildContext context, User user) {
    return _card(
      context,
      title: "موجودی حساب",
      children: [
        _row(
          "موجودی تومان",
          user.balanceToman != null
              ? "${thousandSeperatorFormatter(user.balanceToman.toString())} تومان"
              : "—",
        ),
        _row(
          "موجودی دلار",
          user.balanceDollar != null
              ? "${thousandSeperatorFormatter(user.balanceDollar.toString())} \$"
              : "—",
        ),
        if (user.salesCount != null)
          _row("تعداد کل فروش", user.salesCount.toString()),
      ],
    );
  }

  Widget _permissionsCard(BuildContext context, AgentPermisson permission) {
    return _card(
      context,
      title: "مجوزها و محدودیت‌ها",
      children: [
        _row("موجودی منفی", permission.minusBallance ? "بله" : "خیر"),
        _row("حذف اکانت کم‌مصرف", permission.deleteProducts ? "بله" : "خیر"),
        _row(
          "محدودیت کانفیگ",
          thousandSeperatorFormatter(permission.productLimitation.toString()),
        ),
        _row(
          "محدودیت ترافیک",
          "${permission.trafficLimitationTB} ترابایت",
        ),
      ],
    );
  }

  Widget _productsCard(BuildContext context, AgentDetailModel detail) {
    return _card(
      context,
      title: "بسته‌های فعال (${detail.products.length})",
      children: detail.products.isEmpty
          ? [const Text("هیچ بسته‌ای تعریف نشده")]
          : detail.products.map((p) {
              final name = p.productCategories?.categoryName ?? "—";
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "${thousandSeperatorFormatter(p.price.toString())} تومان",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              );
            }).toList(),
    );
  }

  Widget _salesCard(BuildContext context, User user) {
    return _card(
      context,
      title: "گزارش فروش (${user.salesCount ?? _sales.length})",
      children: [
        if (_loadingSales)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_sales.isEmpty)
          const Text("هنوز فروشی ثبت نشده")
        else
          ..._sales.map((sale) {
            final name =
                sale.productCategory?.categoryName ?? sale.remark ?? "—";
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(
                          sale.createdAt,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    sale.isActive == true ? Icons.check_circle : Icons.cancel,
                    color: sale.isActive == true
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    size: 18,
                  ),
                ],
              ),
            );
          }),
        if (_salesLastPage > 1) ...[
          const SizedBox(height: 12),
          Pagination(
            numOfPages: _salesLastPage,
            selectedPage: _salesCurrentPage,
            pagesVisible: 4,
            onPageChanged: (page) => _loadSales(page: page),
            nextIcon: const Icon(Icons.arrow_forward_ios,
                color: Colors.blue, size: 14),
            previousIcon:
                const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 14),
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
          ),
        ],
      ],
    );
  }

  Widget _actionsCard(BuildContext context) {
    return _card(
      context,
      title: "عملیات",
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AgentFormScreen(
                      mode: AgentFormMode.edit,
                      agent: widget.agent,
                    ),
                  ),
                );
                if (result == true) _loadDetail();
              },
              icon: const Icon(Icons.edit),
              label: const Text("ویرایش"),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AgentFormScreen(
                      mode: AgentFormMode.create,
                      copyFromAgent: widget.agent,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text("کپی تنظیمات برای دستیار جدید"),
            ),
            OutlinedButton.icon(
              onPressed: () => _showDeleteDialog(context),
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label:
                  const Text("حذف دستیار", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _card(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppStyle.defaultPadding),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
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
              final result =
                  await removeAgent(userID: widget.agent.accountId);
              EasyLoading.dismiss();
              if (!context.mounted) return;
              Navigator.pop(ctx);
              if (result == true) {
                showMsg(msg: "با موفقیت حذف شد", context: context);
                Navigator.pop(context, true);
              } else {
                showMsg(
                  msg: "خطا در حذف دستیار فروش",
                  context: context,
                  type: "error",
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
