import 'package:flutter/material.dart';
import 'package:powerps/screens/admin_screen/transaction/transaction_tab/confirned_transaction_tab_screen.dart';
import 'package:powerps/screens/admin_screen/transaction/transaction_tab/unconfirmed_transaction_tab_screen.dart';
import 'package:powerps/styles/app_theme.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        child: Column(
          children: [
            // const Header(title: "تراکنش ها"),
            // SizedBox(height: AppStyle.defaultPadding),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(AppStyle.defaultPadding),
                decoration: BoxDecoration(
                  color: AppStyle.secondaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: AppStyle.secondaryColor,
                      // leading: IconButton(
                      //   icon: const Icon(Icons.arrow_back),
                      //   onPressed: () => Navigator.of(context).pop(),
                      // ),

                      automaticallyImplyLeading: true,
                      title: Text(
                        'لیست ترکنش هایی که در ربات ثبت شده است.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      bottom: const TabBar(tabs: [
                        Tab(text: 'تایید نشده'),
                        Tab(text: 'تایید شده')
                      ]),
                    ),
                    body: const TabBarView(
                      children: [
                        UnConfirmedTransactionTab(),
                        ConfirmedTransactionTab(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
