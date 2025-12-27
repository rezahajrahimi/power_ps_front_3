import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powerps/provider/transaction_provider.dart';
import 'package:powerps/repositories/transaction_repositopry.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/transaction/transaction_info_item_widget.dart';

class ConfirmedTransactionTab extends StatefulWidget {
  const ConfirmedTransactionTab({super.key});

  @override
  State<ConfirmedTransactionTab> createState() =>
      _ConfirmedTransactionTabState();
}

class _ConfirmedTransactionTabState extends State<ConfirmedTransactionTab>
    with AutomaticKeepAliveClientMixin {
  late TransactionProvider _transactionProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fillData(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_transactionProvider.confirmedLoadingMore &&
          _transactionProvider.confirmedCurrentPage <
              _transactionProvider.confirmedLastPage) {
        _loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _transactionProvider = Provider.of<TransactionProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => _fillData(refresh: true),
            child: _transactionProvider.showConfirmedTransaction == false
                ? const Center(child: CircularProgressIndicator())
                : _content(context),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _fillData({bool refresh = false}) async {
    if (refresh) {
      _transactionProvider.resetConfirmed();
    }

    final result = await getConfirmedTransactions(
      page: _transactionProvider.confirmedCurrentPage + (refresh ? 0 : 0),
      count: 15,
    );

    if (result != null) {
      _transactionProvider.setConfirmedTransaction(
        result['data'],
        currentPage: result['current_page'],
        lastPage: result['last_page'],
      );
      _transactionProvider.setChanged(false);
    }
  }

  Future<void> _loadMore() async {
    _transactionProvider.setConfirmedLoadingMore(true);
    final result = await getConfirmedTransactions(
      page: _transactionProvider.confirmedCurrentPage + 1,
      count: 15,
    );

    if (result != null) {
      _transactionProvider.setConfirmedTransaction(
        result['data'],
        currentPage: result['current_page'],
        lastPage: result['last_page'],
      );
    } else {
      _transactionProvider.setConfirmedLoadingMore(false);
    }
  }

  _content(BuildContext context) {
    if (_transactionProvider.changed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fillData(refresh: true);
      });
      return const Center(child: CircularProgressIndicator());
    }

    if (_transactionProvider.confirmedTransactions.isEmpty) {
      return const Center(child: Text("تراکنشی یافت نشد"));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      itemCount: _transactionProvider.confirmedTransactions.length +
          (_transactionProvider.confirmedLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _transactionProvider.confirmedTransactions.length) {
          return TransactionInfoItemCardWidget(
            item: _transactionProvider.confirmedTransactions[index],
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
