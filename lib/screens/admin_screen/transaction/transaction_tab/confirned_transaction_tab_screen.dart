import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/provider/transaction_provider.dart';
import 'package:powerps/repositories/transaction_repositopry.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
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

  @override
  void initState() {
    _fillData();
    super.initState();
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
                  _transactionProvider.showConfirmedTransaction == false
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
      getConfirmedTransactions().then((value) {
        if (value != null) {
          _transactionProvider.setConfirmedTransaction(value);
          _transactionProvider.setShowConfirmedTransaction(true);

          _transactionProvider.setChanged(false);
        }
      });
    }
  }

  _content(BuildContext context) {
    if (_transactionProvider.changed) {
      _transactionProvider.setShowUnconfirmedTransaction(false);

      _fillData();
      return const Opacity(
        opacity: 1,
      );
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
      for (var i in _transactionProvider.confirmedTransactions) {
        widgetList.add(TransactionInfoItemCardWidget(
          item: i,
        ));
      }
    });
    return Container(
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          color: AppStyle.secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Text(
          //   "لیست اقلام",
          //   style: Theme.of(context).textTheme.titleMedium,
          // ),
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
              ))
        ]));
  }
}
