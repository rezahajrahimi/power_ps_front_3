import 'package:provider/provider.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/provider/agent/agent_provider.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';

class AgentSelectCategoryWithPriceInputWidget extends StatefulWidget {
  const AgentSelectCategoryWithPriceInputWidget({
    super.key,
    required this.item,
    required this.type,
  });
  final AgentAddCategoriyModel item;

  final String type;

  @override
  State<AgentSelectCategoryWithPriceInputWidget> createState() =>
      _AgentSelectCategoryWithPriceInputWidgetState();
}

class _AgentSelectCategoryWithPriceInputWidgetState
    extends State<AgentSelectCategoryWithPriceInputWidget> {
  final _formKey = GlobalKey<FormState>();
  final _priceInTomanController = TextEditingController();
  final _priceInDollarController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _priceInTomanController.dispose();
    _priceInDollarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final agentProcider = context.watch<AgentProvider>().agentCategories;

    return GestureDetector(
      onTap: () async {
        if (widget.type == "add") {
          await _showActionDialog(context);
        } else {
          Provider.of<AgentProvider>(context, listen: false)
              .moveCategoryToAvailable(widget.item);
        }

        // agentProcider.remove(widget.item);
      },
      child: Container(
        margin: EdgeInsets.only(top: AppStyle.defaultPadding),
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
              width: 2, color: AppStyle.primaryColor.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(AppStyle.defaultPadding),
          ),
        ),
        child: Row(
          children: [
            widget.type == "add"
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: Icon(Icons.add),
                  )
                : const SizedBox(
                    height: 20,
                    width: 20,
                    child: Icon(Icons.remove),
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
                          widget.item.productCategories!.categoryName.length >
                                  30
                              ? "${widget.item.productCategories!.categoryName.substring(0, 30)}..."
                              : widget.item.productCategories!.categoryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Text(
                        //   "${widget.item.productCategories!.pannel?.type}",
                        //   style: Theme.of(context)
                        //       .textTheme
                        //       .bodySmall!
                        //       .copyWith(color: Colors.white70),
                        // ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.item.newPrice != null
                            ? Text(
                                "${thousandSeperatorFormatter(widget.item.newPrice.toString())} تومان",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: Colors.white70),
                              )
                            : Text(
                                "${thousandSeperatorFormatter(widget.item.price.toString())} تومان",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: Colors.white70),
                              ),
                        widget.item.newPriceInDollar != null
                            ? Text(
                                "${thousandSeperatorFormatter(widget.item.newPriceInDollar.toString())}\$",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: Colors.white70),
                              )
                            : Text(
                                "${thousandSeperatorFormatter(widget.item.priceInDollar.toString())}\$",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: Colors.white70),
                              ),
                        Text(
                          "${widget.item.productCategories!.expireDay} روزه",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                        Text(
                          "${widget.item.productCategories!.volume} گیگابایت",
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

  _showActionDialog(BuildContext context) {
    _priceInDollarController.text = widget.item.priceInDollar.toString();
    _priceInTomanController.text = widget.item.price.toString();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
          title: Text(
              "قیمت بسته ${widget.item.productCategories!.categoryName} را برای دستیار فروش وارد کنید"),
          content: SizedBox(
            height: 260,
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "قیمت اصلی: ${thousandSeperatorFormatter(widget.item.price.toString())} تومان / ${thousandSeperatorFormatter(widget.item.priceInDollar.toString())}\$",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  const Text("قیمت به تومان"),
                  TextFormField(
                    controller: _priceInTomanController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setDialogState(() {}),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "لطفا قیمت را وارد کنید";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text("قیمت به دلار"),
                  TextFormField(
                    controller: _priceInDollarController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setDialogState(() {}),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "لطفا قیمت را به دلار وارد کنید";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Builder(builder: (context) {
                    final toman = int.tryParse(_priceInTomanController.text);
                    if (toman == null || widget.item.price == 0) {
                      return const SizedBox.shrink();
                    }
                    final diff = ((widget.item.price - toman) / widget.item.price * 100);
                    final label = diff >= 0
                        ? "تخفیف: ${diff.toStringAsFixed(1)}٪"
                        : "افزایش: ${(-diff).toStringAsFixed(1)}٪";
                    return Text(
                      label,
                      style: TextStyle(
                        color: diff >= 0 ? Colors.greenAccent : Colors.orangeAccent,
                        fontSize: 13,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            // create a form and put it in the dialog
            TextButton(
              child: const Text("لغو"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("تایید"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Provider.of<AgentProvider>(context, listen: false)
                      .moveCategoryToAdded(
                    widget.item.setNewPricesValus(
                      newPrice: int.parse(_priceInTomanController.text),
                      newPriceInDollar:
                          double.parse(_priceInDollarController.text),
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  showMsg(context: context, msg: "لطفا تمام فیلدها را پر کنید");
                }
              },
            ),
          ],
        );
          },
        );
      },
    );
  }
}
