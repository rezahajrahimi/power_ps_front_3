import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/provider/transaction_provider.dart';
import 'package:powerps/repositories/transaction_repositopry.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:powerps/widgets/transaction/transaction_info_item_widget.dart';

class UnConfirmedTransactionTab extends StatefulWidget {
  const UnConfirmedTransactionTab({super.key});

  @override
  State<UnConfirmedTransactionTab> createState() =>
      _UnConfirmedTransactionTabState();
}

class _UnConfirmedTransactionTabState extends State<UnConfirmedTransactionTab>
    with AutomaticKeepAliveClientMixin {
  late TransactionProvider _transactionProvider;

  @override
  void initState() {
    super.initState();

    _fillData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _transactionProvider = Provider.of<TransactionProvider>(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            child: Padding(
              padding: EdgeInsets.all(AppStyle.defaultPadding),
              child: Column(
                children: [
                  _transactionProvider.showUnConfirmedTransaction == false
                      ? const CircularProgressIndicator()
                      : _content(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _fillData() {
    if (context.mounted) {
      getUnConfirmedTransactions().then((value) {
        if (value != null) {
          _transactionProvider.setUnconfirmedTransaction(value);
          _transactionProvider.setShowUnconfirmedTransaction(true);
          _transactionProvider.setChanged(false);
        } else {
          _transactionProvider.setShowUnconfirmedTransaction(false);
        }
      });
    }
  }

  _content(BuildContext context) {
    if (_transactionProvider.changed) {
      _transactionProvider.setShowUnconfirmedTransaction(false);

      _fillData();
      return const CircularProgressIndicator();
    } else {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _transactionInfoTabCard(context),
                  ],
                ),
              ),
            ],
          )
        ],
      );
    }
  }

  _transactionInfoTabCard(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    List<Widget> widgetList = [];
    setState(() {
      for (var i in _transactionProvider.unConfirmedTransactions) {
        widgetList.add(TransactionInfoItemCardWidget(
          item: i,
        ));
      }
    });
    return _transactionProvider.unConfirmedTransactions.isNotEmpty
        ? Container(
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            decoration: BoxDecoration(
              color: AppStyle.secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: AppStyle.defaultPadding),
              SizedBox(
                width: double.infinity,
                child: Responsive(
                  mobile: widgetsGridview(
                      childAspectRatio: 2.7,
                      context: context,
                      importedList: widgetList),
                  tablet: widgetsGridview(
                      context: context,
                      childAspectRatio: 6,
                      importedList: widgetList),
                  desktop: widgetsGridview(
                      importedList: widgetList,
                      context: context,
                      childAspectRatio: size.width < 1400 ? 4 : 5.5,
                      crossAxisCount: 2),
                ),
              )
            ]))
        : const Opacity(opacity: 1);
  }
}
