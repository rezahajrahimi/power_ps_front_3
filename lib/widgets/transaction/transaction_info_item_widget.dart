import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/transaction_model.dart';
import 'package:powerps/provider/transaction_provider.dart';
import 'package:powerps/screens/admin_screen/transaction/transaction_details_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';

class TransactionInfoItemCardWidget extends StatefulWidget {
  const TransactionInfoItemCardWidget({
    super.key,
    required this.item,
  });

  final Transaction item;
  @override
  State<TransactionInfoItemCardWidget> createState() =>
      _TransactionInfoItemCardWidgetState();
}

class _TransactionInfoItemCardWidgetState
    extends State<TransactionInfoItemCardWidget> {
  late TransactionProvider _transactionProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _transactionProvider = Provider.of<TransactionProvider>(context);

    return GestureDetector(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailsScreen(
                item: widget.item,
              ),
            )).then((value) async {
          _transactionProvider.setChanged(true);
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
          border: Border.all(
            color: AppStyle.primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (widget.item.confirmed == true
                        ? Colors.green
                        : Colors.orange)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.item.confirmed == true
                    ? Icons.check_circle_outline
                    : Icons.pending_outlined,
                color: widget.item.confirmed == true
                    ? Colors.greenAccent
                    : Colors.orangeAccent,
                size: 20,
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (widget.item.botUser?.username ?? "بدون نام کاربری")
                                      .length >
                                  20
                              ? "${(widget.item.botUser?.username ?? "بدون نام کاربری").substring(0, 20)}..."
                              : (widget.item.botUser?.username ??
                                  "بدون نام کاربری"),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.item.paymentType?.name ?? "نامشخص",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${formatPrice(widget.item.amount.toString())} تومان",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.item.createdAt!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
