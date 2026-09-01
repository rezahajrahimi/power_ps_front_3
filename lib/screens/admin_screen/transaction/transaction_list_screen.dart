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
            Expanded(
              child: Container(
                padding: EdgeInsets.all(AppStyle.defaultPadding),
                decoration: BoxDecoration(
                  color: AppStyle.secondaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      automaticallyImplyLeading: true,
                      title: Row(
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              color: AppStyle.primaryColor),
                          const SizedBox(width: 10),
                          Text(
                            'لیست تراکنش‌های ربات',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      bottom: TabBar(
                        indicatorColor: AppStyle.primaryColor,
                        indicatorWeight: 3,
                        labelColor: AppStyle.primaryColor,
                        unselectedLabelColor: Colors.white70,
                        tabs: const [
                          Tab(text: 'تایید نشده'),
                          Tab(text: 'تایید شده'),
                        ],
                      ),
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
