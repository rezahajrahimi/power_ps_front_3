import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/provider/agent/agent_provider.dart';
import 'package:powerps/repositories/agent_product_repository.dart';
import 'package:powerps/screens/admin_screen/settings/agent/edit_agent_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:provider/provider.dart';

class AgentInfoWidget extends StatefulWidget {
  const AgentInfoWidget({super.key, required this.agent});
  final User agent;

  @override
  State<AgentInfoWidget> createState() => _AgentInfoWidgetState();
}

class _AgentInfoWidgetState extends State<AgentInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // await Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => BotUserDetailsScreen(
        //         id: widget.agent.id,
        //       ),
        //     )).then((value) {});
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
            const SizedBox(
              height: 20,
              width: 20,
              child: Icon(Icons.verified_user),
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
                          widget.agent.accountId.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.agent.name,
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
                        IconButton(
                            onPressed: () {
                              // اینجا کاربر را باید اطلاعات بیشتری درج کنی
                            },
                            icon: const Icon(Icons.info)),
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditAgentScreen(agent: widget.agent),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit)),
                        IconButton(
                            onPressed: () {
                              //کاربر را باید تبدیل به کاربر معمولی کنی
                              // اگه کاربری ایجاد کرده ، تکلیف اون چی میشه
                              // می خوای کلا دسترسی این ادمین را بگیری یا کلا حذفش کنی
                              // اگه این کار را بکنی تکلیف موجودی حسابش چی می شه
                              _showDeleteDialog(context);
                            },
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            )),
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف دستیار فروش'),
          content: const Text(
              'با حذف دستیار فروش تمام اکانتهای این کاربر به مدیر ربات منتقل می شود و کاربر به عنوان کاربر عادی تغییر خواهد کرد. از حذف این کاربر اطمینان دارید؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('لغو'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('حذف'),
              onPressed: () async {
                EasyLoading.show();
                await removeAgent(userID: widget.agent.accountId).then((val) {
                  if (!context.mounted) return;

                  if (val != null && val == true) {
                    showMsg(msg: "با موفقیت حذف شد", context: context);
                    EasyLoading.dismiss();

                    Navigator.of(context).pop();
                    Provider.of<AgentProvider>(context, listen: false)
                        .setChanged(true);
                  } else {
                    showMsg(msg: "خطا", context: context, type: "error");
                    EasyLoading.dismiss();
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
}
