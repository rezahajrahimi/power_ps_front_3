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
          border: Border.all(
              width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(AppStyle.defaultPadding),
          ),
        ),
        child: Row(
          children: [
            widget.item.confirmed == true
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: Icon(Icons.done, color: Colors.purple),
                  )
                : const SizedBox(
                    height: 20,
                    width: 20,
                    child: Icon(Icons.stop, color: Colors.purple),
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
                          widget.item.botUser!.username!.length > 30
                              ? "${widget.item.botUser!.username!.substring(25)}..."
                              : widget.item.botUser!.username!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.item.paymentType!.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${thousandSeperatorFormatter(widget.item.amount.toString())} تومان",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                        // Text(
                        //   "${widget.item.expireDay} روزه",
                        //   style: Theme.of(context)
                        //       .textTheme
                        //       .bodySmall!
                        //       .copyWith(color: Colors.white70),
                        // ),
                        Text(
                          "${widget.item.createdAt}",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
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
