import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/repositories/bot_user_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:powerps/widgets/users/bot_users_info_card_widget.dart';

class BotUsersScreen extends StatefulWidget {
  const BotUsersScreen({super.key});

  @override
  State<BotUsersScreen> createState() => _BotUsersScreenState();
}

class _BotUsersScreenState extends State<BotUsersScreen> {
  bool _showData = false;
  int _lastPage = 1;
  int selectedPage = 1;

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  void _fillData() async {
    await getBotUserListByPagination().then((value) {
      if (!mounted) return;
      if (value != false && value != null) {
        setState(() {
          _lastPage = lastPage;

          _showData = true;
        });
      } else {
        showMsg(msg: "خطا", context: context, type: "error");
        debugPrint("error on dashboard biding $value");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  // const Header(title: "کاربران"),
                  // SizedBox(height: AppStyle.defaultPadding),
                  _showData == false
                      ? const SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: CircularProgressIndicator()))
                      : _content(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _content(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            __filtersCardWidget(context),
                            BotUsersInfoCardWidget(
                              title: "کاربران",
                              botUsers: botUserList,
                            ),
                            SizedBox(height: AppStyle.defaultPadding),
                            Pagination(
                              numOfPages: _lastPage,
                              selectedPage: selectedPage,
                              pagesVisible: 4,
                              onPageChanged: (page) async {
                                setState(() {
                                  selectedPage = page;
                                  _showData = false;
                                });
                                await getBotUserListByPagination(page: page);
                                setState(() {
                                  _lastPage = lastPage;

                                  _showData = true;
                                });
                              },
                              nextIcon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.blue,
                                size: 14,
                              ),
                              previousIcon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.blue,
                                size: 14,
                              ),
                              activeTextStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              activeBtnStyle: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.blue),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(38),
                                  ),
                                ),
                              ),
                              inactiveBtnStyle: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(38),
                                )),
                              ),
                              inactiveTextStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (Responsive.isMobile(context))
                              SizedBox(height: AppStyle.defaultPadding),
                            if (Responsive.isMobile(context)) // side bar mobile
                              Column(
                                children: [
                                  SizedBox(height: AppStyle.defaultPadding),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (!Responsive.isMobile(context))
                        SizedBox(width: AppStyle.defaultPadding),
                      // On Mobile means if the screen is less than 850 we dont want to show it
                      if (!Responsive.isMobile(context)) // side windows
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _operationInfoCard(context),
                              SizedBox(height: AppStyle.defaultPadding),
                            ],
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  _operationInfoCard(BuildContext context) {
    List<Widget> operationWidgetList = [];
    setState(() {
      operationWidgetList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          final message = TextEditingController();
          showDialog(
              context: context,
              builder: (context) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: AlertDialog(
                    title: Text("ارسال پیام به تمامی کاربران"),
                    content: Column(
                      spacing: 8,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("متن پیام را وارد کنید."),
                        TextField(
                          controller: message,
                          maxLength: 400,
                          maxLines: 5,
                          textDirection: TextDirection.rtl,
                        )
                      ],
                    ),
                    actions: [
                      ElevatedButton.icon(
                          onPressed: () async {
                            EasyLoading.show();
                            await sendAdminMessageToAllUsers(
                                    message: message.text)
                                .then((val) {
                              EasyLoading.dismiss();
                              if (!context.mounted) return;

                              if (val) {
                                Navigator.pop(context);

                                showMsg(msg: "انجام شد.", context: context);
                              } else {
                                Navigator.pop(context);

                                showMsg(msg: "خطا", context: context);
                              }
                            }).onError((e, s) {
                              if (!context.mounted) return;
                              EasyLoading.dismiss();
                              debugPrint(e.toString());
                              showMsg(msg: "خطا", context: context);
                              return;
                            });
                          },
                          label: Text("ارسال")),
                      ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        label: Text("لغو"),
                      ),
                    ],
                  ),
                );
              });
        },
        icon: const Icon(Icons.send),
        label: const Text("ارسال پیام به تمام کاربران"),
      ));
      operationWidgetList.add(Tooltip(
          message: "ارسال پیام به تمام کاربرانی که هیچ بسته فعالی ندارند.",
          child: ElevatedButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppStyle.defaultPadding * 1.5,
                vertical: AppStyle.defaultPadding /
                    (Responsive.isMobile(context) ? 2 : 1),
              ),
            ),
            onPressed: () async {
              final message = TextEditingController();
              showDialog(
                  context: context,
                  builder: (context) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: AlertDialog(
                        title: Text(
                            "ارسال پیام به تمام کاربرانی که هیچ بسته فعالی ندارند"),
                        content: Column(
                          spacing: 8,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("متن پیام را وارد کنید."),
                            TextField(
                              controller: message,
                              maxLength: 400,
                              maxLines: 5,
                              textDirection: TextDirection.rtl,
                            )
                          ],
                        ),
                        actions: [
                          ElevatedButton.icon(
                              onPressed: () async {
                                EasyLoading.show();
                                await sendAdminMessageToAllUsersWithoutConfigs(
                                        message: message.text)
                                    .then((val) {
                                  EasyLoading.dismiss();
                                  if (!context.mounted) return;

                                  if (val) {
                                    Navigator.pop(context);

                                    showMsg(msg: "انجام شد.", context: context);
                                  } else {
                                    Navigator.pop(context);

                                    showMsg(msg: "خطا", context: context);
                                  }
                                }).onError((e, s) {
                                  if (!context.mounted) return;
                                  EasyLoading.dismiss();
                                  debugPrint(e.toString());
                                  showMsg(msg: "خطا", context: context);
                                  return;
                                });
                              },
                              label: Text("ارسال")),
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            label: Text("لغو"),
                          ),
                        ],
                      ),
                    );
                  });
            },
            icon: const Icon(Icons.send),
            label: const Text("ارسال پیام به کاربران فاقد بسته"),
          )));
      operationWidgetList.add(Tooltip(
          message:
              "ارسال پیام به تمام کاربرانی که موجودی کیف پول ریالی آنها صفر است.",
          child: ElevatedButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppStyle.defaultPadding * 1.5,
                vertical: AppStyle.defaultPadding /
                    (Responsive.isMobile(context) ? 2 : 1),
              ),
            ),
            onPressed: () async {
              // await _submitIncOprDialog(context, opr: "inc");
            },
            icon: const Icon(Icons.send),
            label: const Text("ارسال پیام به کاربران دارای موجودی صفر"),
          )));
      operationWidgetList.add(Tooltip(
          message: "میزان موجودی کیف کاربران را به مقدار دلخواه افزایش بدهید.",
          child: ElevatedButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppStyle.defaultPadding * 1.5,
                vertical: AppStyle.defaultPadding /
                    (Responsive.isMobile(context) ? 2 : 1),
              ),
            ),
            onPressed: () async {
              // await _submitIncOprDialog(context, opr: "inc");
            },
            icon: const Icon(Icons.wallet),
            label: const Text("افزایش کیف پول تمام کاربران"),
          )));
      operationWidgetList.add(Tooltip(
          message:
              "حذف تمامی کاربران عضو شده در ربات همراه با کانفیگ های خریداری شده.",
          child: ElevatedButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppStyle.defaultPadding * 1.5,
                vertical: AppStyle.defaultPadding /
                    (Responsive.isMobile(context) ? 2 : 1),
              ),
            ),
            onPressed: () async {
              // await _submitIncOprDialog(context, opr: "inc");
            },
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            label: const Text("حذف تمام کاربران"),
          )));
    });
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "عملیات گروهی (اکانت طلایی و نقره ای)",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  crossAxisCount: 2,
                  importedList: operationWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 2,
                  importedList: operationWidgetList),
              desktop: widgetsGridview(
                  importedList: operationWidgetList,
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  __filtersCardWidget(BuildContext context) {
    List<Widget> operationWidgetList = [];
    operationWidgetList.add(Tooltip(
        message: "10 کاربر آخر",
        child: ElevatedButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyle.defaultPadding * 1.5,
              vertical: AppStyle.defaultPadding /
                  (Responsive.isMobile(context) ? 2 : 1),
            ),
          ),
          onPressed: () async {
            EasyLoading.show();
              setState(() {
                _lastPage = 1;
                _showData = false;
              });

            await getLast10BotUser().then((val) {
            }).whenComplete(() {
              setState(() {
                _showData = true;
              });
            }).onError((e, s) {
              debugPrint(e.toString());
            });
            EasyLoading.dismiss();
          },
          icon: const Icon(Icons.filter_alt),
          label: const Text("10 کاربر آخر"),
        )));
    operationWidgetList.add(Tooltip(
        message: "ثبت نام در هفته گذشته",
        child: ElevatedButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyle.defaultPadding * 1.5,
              vertical: AppStyle.defaultPadding /
                  (Responsive.isMobile(context) ? 2 : 1),
            ),
          ),
          onPressed: () async {
            EasyLoading.show();
              setState(() {
                _lastPage = 1;
                _showData = false;
              });

            await getUsersByPastDays(days: 7).then((val) {
            }).whenComplete(() {
              setState(() {
                _showData = true;
              });
            }).onError((e, s) {
              debugPrint(e.toString());
            });
            EasyLoading.dismiss();
          },
          icon: const Icon(Icons.wallet),
          label: const Text("هفته گذشته"),
        )));
    operationWidgetList.add(Tooltip(
        message: "ماه گذشته",
        child: ElevatedButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyle.defaultPadding * 1.5,
              vertical: AppStyle.defaultPadding /
                  (Responsive.isMobile(context) ? 2 : 1),
            ),
          ),
          onPressed: () async {
            EasyLoading.show();
              setState(() {
                _lastPage = 1;
                _showData = false;
              });

            await getUsersByPastDays(days: 30).then((val) {
            }).whenComplete(() {
              setState(() {
                _showData = true;
              });
            }).onError((e, s) {
              debugPrint(e.toString());
            });
            EasyLoading.dismiss();
          },
          icon: const Icon(Icons.wallet),
          label: const Text("ماه گذشته"),
        )));
    operationWidgetList.add(Tooltip(
        message: "کاربران فاقد اکانت",
        child: ElevatedButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyle.defaultPadding * 1.5,
              vertical: AppStyle.defaultPadding /
                  (Responsive.isMobile(context) ? 2 : 1),
            ),
          ),
          onPressed: () async {
            EasyLoading.show();
              setState(() {
                _lastPage = 1;
                _showData = false;
              });

            await getUsersWithZeroConfigs().then((val) {
            }).whenComplete(() {
              setState(() {
                _showData = true;
              });
            }).onError((e, s) {
              debugPrint(e.toString());
            });
            EasyLoading.dismiss();
          },
          icon: const Icon(Icons.filter_alt),
          label: const Text("کاربران فاقد اکانت"),
        )));
    operationWidgetList.add(Tooltip(
        message: "کاربرانی که موجودی کیف پول آنها صفر یا منفی می باشد.",
        child: ElevatedButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyle.defaultPadding * 1.5,
              vertical: AppStyle.defaultPadding /
                  (Responsive.isMobile(context) ? 2 : 1),
            ),
          ),
          onPressed: () async {
             EasyLoading.show();
              setState(() {
                _lastPage = 1;
                _showData = false;
              });

            await getUsersWithZeroBallance().then((val) {
            }).whenComplete(() {
              setState(() {
                _showData = true;
              });
            }).onError((e, s) {
              debugPrint(e.toString());
            });
            EasyLoading.dismiss();
          },
          icon: const Icon(Icons.wallet),
          label: const Text("کاربران با موجودی کیف پول منفی یا صفر"),
        )));
    operationWidgetList.add(Tooltip(
        message: "دستیاران فروش",
        child: ElevatedButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyle.defaultPadding * 1.5,
              vertical: AppStyle.defaultPadding /
                  (Responsive.isMobile(context) ? 2 : 1),
            ),
          ),
          onPressed: () async {
             EasyLoading.show();
              setState(() {
                _lastPage = 1;
                _showData = false;
              });

            await getAgentRoleBotUsers().then((val) {
            }).whenComplete(() {
              setState(() {
                _showData = true;
              });
            }).onError((e, s) {
              debugPrint(e.toString());
            });
            EasyLoading.dismiss();
          },
          icon: const Icon(Icons.support_agent),
          label: const Text("دستیاران فروش"),
        )));

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "فیلتر کاربران",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  crossAxisCount: 2,
                  importedList: operationWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 2,
                  importedList: operationWidgetList),
              desktop: widgetsGridview(
                  importedList: operationWidgetList,
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 6),
            ),
          ),
        ],
      ),
    );
  }
}
