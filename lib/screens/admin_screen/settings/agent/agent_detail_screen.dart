import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/agent_detail_model.dart';
import 'package:powerps/models/agent_permisson_model.dart';
import 'package:powerps/models/bought_product_details_model.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/repositories/agent_manage_repository.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/screens/admin_screen/settings/agent/agent_form_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/agent/agent_screen_shared.dart';
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
      _error = detail == null ? 'خطا در دریافت اطلاعات دستیار' : null;
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
    final isMobile = Responsive.isMobile(context);

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(
            context: context,
            title: isMobile ? 'جزئیات دستیار' : 'جزئیات دستیار فروش',
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError()
                  : RefreshIndicator(
                      onRefresh: _loadDetail,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: agentScreenPadding(context),
                        child: agentCenteredContent(
                          context,
                          child: _buildContent(context),
                        ),
                      ),
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
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('تلاش مجدد'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final detail = _detail!;
    final permission = detail.permission;
    final user = detail.user;
    final isDesktop = Responsive.isDesktop(context);

    if (isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _infoCard(context, detail)),
              const SizedBox(width: 16),
              Expanded(child: _balanceCard(context, user)),
            ],
          ),
          const SizedBox(height: 16),
          if (permission != null) ...[
            _permissionsCard(context, permission),
            const SizedBox(height: 16),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _productsCard(context, detail)),
              const SizedBox(width: 16),
              Expanded(child: _salesCard(context, user)),
            ],
          ),
          const SizedBox(height: 16),
          _actionsCard(context),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _infoCard(context, detail),
        SizedBox(height: AppStyle.defaultPadding),
        _balanceCard(context, user),
        SizedBox(height: AppStyle.defaultPadding),
        if (permission != null) ...[
          _permissionsCard(context, permission),
          SizedBox(height: AppStyle.defaultPadding),
        ],
        _productsCard(context, detail),
        SizedBox(height: AppStyle.defaultPadding),
        _salesCard(context, user),
        SizedBox(height: AppStyle.defaultPadding),
        _actionsCard(context),
      ],
    );
  }

  Widget _infoCard(BuildContext context, AgentDetailModel detail) {
    return AgentSectionCard(
      title: 'اطلاعات کاربر',
      children: [
        AgentRtlRow(label: 'نام', value: detail.user.name),
        AgentRtlRow(
          label: 'شناسه تلگرام',
          value: detail.user.accountId.toString(),
        ),
        if (detail.user.userGroupName != null)
          AgentRtlRow(label: 'گروه کاربری', value: detail.user.userGroupName!),
        AgentRtlRow(
          label: 'وضعیت تایید',
          value: detail.user.isVerified ? 'تایید شده' : 'تایید نشده',
        ),
      ],
    );
  }

  Widget _balanceCard(BuildContext context, User user) {
    return AgentSectionCard(
      title: 'موجودی حساب',
      children: [
        AgentRtlRow(
          label: 'موجودی تومان',
          value: user.balanceToman != null
              ? '${thousandSeperatorFormatter(user.balanceToman.toString())} تومان'
              : '—',
        ),
        AgentRtlRow(
          label: 'موجودی دلار',
          value: user.balanceDollar != null
              ? '${thousandSeperatorFormatter(user.balanceDollar.toString())} \$'
              : '—',
        ),
        if (user.salesCount != null)
          AgentRtlRow(
            label: 'تعداد کل فروش',
            value: user.salesCount.toString(),
          ),
      ],
    );
  }

  Widget _permissionsCard(BuildContext context, AgentPermisson permission) {
    return AgentSectionCard(
      title: 'مجوزها و محدودیت‌ها',
      children: [
        AgentRtlRow(
          label: 'موجودی منفی',
          value: permission.minusBallance ? 'بله' : 'خیر',
        ),
        AgentRtlRow(
          label: 'حذف اکانت کم‌مصرف',
          value: permission.deleteProducts ? 'بله' : 'خیر',
        ),
        AgentRtlRow(
          label: 'محدودیت کانفیگ',
          value: thousandSeperatorFormatter(
            permission.productLimitation.toString(),
          ),
        ),
        AgentRtlRow(
          label: 'محدودیت ترافیک',
          value: '${permission.trafficLimitationTB} ترابایت',
        ),
      ],
    );
  }

  Widget _productsCard(BuildContext context, AgentDetailModel detail) {
    return AgentSectionCard(
      title: 'بسته‌های فعال (${detail.products.length})',
      children: [
        if (detail.products.isEmpty)
          const Text(
            'هیچ بسته‌ای تعریف نشده',
            textAlign: TextAlign.right,
          )
        else
          agentScrollableList(
            context: context,
            itemCount: detail.products.length,
            maxHeight: Responsive.isDesktop(context) ? 360 : null,
            itemBuilder: (_, index) {
              final p = detail.products[index];
              final name = p.productCategories?.categoryName ?? '—';
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${thousandSeperatorFormatter(p.price.toString())} تومان',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _salesCard(BuildContext context, User user) {
    return AgentSectionCard(
      title: 'گزارش فروش (${user.salesCount ?? _sales.length})',
      children: [
        if (_loadingSales)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_sales.isEmpty)
          const Text(
            'هنوز فروشی ثبت نشده',
            textAlign: TextAlign.right,
          )
        else ...[
          agentScrollableList(
            context: context,
            itemCount: _sales.length,
            maxHeight: Responsive.isDesktop(context) ? 360 : null,
            itemBuilder: (_, index) => _saleRow(_sales[index]),
          ),
          if (_salesLastPage > 1) ...[
            const SizedBox(height: 12),
            _salesPagination(),
          ],
        ],
      ],
    );
  }

  Widget _saleRow(BoughtProductDetailsModel sale) {
    final name = sale.productCategory?.categoryName ?? sale.remark ?? '—';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sale.createdAt,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
  }

  Widget _salesPagination() {
    return Pagination(
      numOfPages: _salesLastPage,
      selectedPage: _salesCurrentPage,
      pagesVisible: Responsive.isMobile(context) ? 3 : 4,
      onPageChanged: (page) => _loadSales(page: page),
      nextIcon: const Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 14),
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
    );
  }

  Widget _actionsCard(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return AgentSectionCard(
      title: 'عملیات',
      children: [
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _actionButtons(context),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _actionButtons(context),
          ),
      ],
    );
  }

  List<Widget> _actionButtons(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final gap = isMobile ? const SizedBox(height: 8) : const SizedBox.shrink();

    Widget btn(Widget child) => SizedBox(
          width: isMobile ? double.infinity : null,
          child: child,
        );

    return [
      btn(ElevatedButton.icon(
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
        label: const Text('ویرایش'),
      )),
      gap,
      btn(ElevatedButton.icon(
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
        label: Text(
          isMobile ? 'کپی برای دستیار جدید' : 'کپی تنظیمات برای دستیار جدید',
        ),
      )),
      gap,
      btn(OutlinedButton.icon(
        onPressed: () => _showDeleteDialog(context),
        icon: const Icon(Icons.delete_forever, color: Colors.red),
        label: const Text('حذف دستیار', style: TextStyle(color: Colors.red)),
      )),
    ];
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showAgentConfirmDialog(
      context: context,
      title: 'حذف دستیار فروش',
      message:
          'با حذف دستیار فروش، تمام اکانت‌های این کاربر به مدیر ربات منتقل می‌شود و نقش او به کاربر عادی تغییر خواهد کرد.\n\nآیا از حذف «${widget.agent.name}» اطمینان دارید؟',
      confirmLabel: 'حذف',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    EasyLoading.show();
    final result = await removeAgent(userID: widget.agent.accountId);
    EasyLoading.dismiss();
    if (!context.mounted) return;

    if (result == true) {
      showMsg(msg: 'با موفقیت حذف شد', context: context);
      Navigator.pop(context, true);
    } else {
      showMsg(
        msg: 'خطا در حذف دستیار فروش',
        context: context,
        type: 'error',
      );
    }
  }
}
