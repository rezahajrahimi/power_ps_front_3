import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persian_datetimepickers/persian_datetimepickers.dart';
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
  final Set<String> _selectedUserAccountIds = {};
  bool _isFiltersExpanded = false;

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
        backgroundColor: AppStyle.bgColor,
        body: SafeArea(
          child: _showData == false
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "درحال دریافت لیست کاربران...",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppStyle.defaultPadding),
                        child: _content(context),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  _content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        __filtersCardWidget(context),
        SizedBox(height: AppStyle.defaultPadding),
        BotUsersInfoCardWidget(
          title: "کاربران",
          botUsers: botUserList,
          selectedUserAccountIds: _selectedUserAccountIds,
          onUserSelected: (accountId, selected) {
            setState(() {
              if (selected) {
                _selectedUserAccountIds.add(accountId);
              } else {
                _selectedUserAccountIds.remove(accountId);
              }
            });
          },
        ),
        SizedBox(height: AppStyle.defaultPadding),
        Container(
          padding: EdgeInsets.symmetric(vertical: AppStyle.defaultPadding),
          decoration: BoxDecoration(
            color: AppStyle.secondaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Pagination(
            numOfPages: _lastPage,
            selectedPage: selectedPage,
            pagesVisible: Responsive.isMobile(context) ? 3 : 5,
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
            nextIcon: Icon(
              Icons.arrow_forward_ios,
              color: AppStyle.primaryColor,
              size: 14,
            ),
            previousIcon: Icon(
              Icons.arrow_back_ios,
              color: AppStyle.primaryColor,
              size: 14,
            ),
            activeTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            activeBtnStyle: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(AppStyle.primaryColor),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              shadowColor: WidgetStateProperty.all(
                  AppStyle.primaryColor.withValues(alpha: 0.5)),
              elevation: WidgetStateProperty.all(5),
            ),
            inactiveBtnStyle: ButtonStyle(
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              )),
              backgroundColor:
                  WidgetStateProperty.all(Colors.white.withValues(alpha: 0.05)),
            ),
            inactiveTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  void _showSendMessageDialog(BuildContext context, {required bool isAll}) {
    final messageController = TextEditingController();
    DateTime? selectedDateTime;
    String? formattedDateTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: AppStyle.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                title: Row(
                  children: [
                    Icon(isAll ? Icons.campaign_rounded : Icons.send_rounded,
                        color: AppStyle.primaryColor),
                    const SizedBox(width: 10),
                    Text(
                      isAll
                          ? "ارسال پیام همگانی"
                          : "ارسال پیام به انتخاب شده ها",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: messageController,
                      maxLines: 6,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "متن پیام خود را اینجا بنویسید...",
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color:
                                  AppStyle.primaryColor.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "زمان ارسال:",
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  selectedDateTime == null
                                      ? "بلافاصله"
                                      : "${selectedDateTime!.toPersianDate()} ${selectedDateTime!.hour}:${selectedDateTime!.minute}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final DateTime? date =
                                  await showPersianDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                              );
                              if (date != null) {
                                if (!context.mounted) return;
                                final TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  setDialogState(() {
                                    selectedDateTime = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      time.hour,
                                      time.minute,
                                    );
                                    formattedDateTime =
                                        selectedDateTime!.toIso8601String();
                                  });
                                }
                              }
                            },
                            icon: Icon(Icons.calendar_month_rounded,
                                size: 18, color: AppStyle.primaryColor),
                            label: Text(
                              "زمانبندی",
                              style: TextStyle(color: AppStyle.primaryColor),
                            ),
                          ),
                          if (selectedDateTime != null)
                            IconButton(
                              onPressed: () {
                                setDialogState(() {
                                  selectedDateTime = null;
                                  formattedDateTime = null;
                                });
                              },
                              icon: const Icon(Icons.close_rounded,
                                  color: Colors.redAccent, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "انصراف",
                      style:
                          TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyle.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (messageController.text.isEmpty) {
                        showMsg(
                            msg: "لطفا متن پیام را وارد کنید",
                            context: context,
                            type: "error");
                        return;
                      }

                      EasyLoading.show(status: 'در حال ثبت در صف...');
                      bool success = false;
                      if (isAll) {
                        success = await sendAdminMessageToAllUsers(
                          message: messageController.text,
                          scheduledAt: formattedDateTime,
                        );
                      } else {
                        success = await sendAdminMessageToSelectedUsers(
                          userIds: _selectedUserAccountIds.toList(),
                          message: messageController.text,
                          scheduledAt: formattedDateTime,
                        );
                      }
                      EasyLoading.dismiss();

                      if (success) {
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        showMsg(
                            msg: "پیام با موفقیت در صف ارسال قرار گرفت",
                            context: context);
                        setState(() {
                          _selectedUserAccountIds.clear();
                        });
                      } else {
                        if (!context.mounted) return;
                        showMsg(
                            msg: "متاسفانه خطایی در ارسال پیام رخ داد",
                            context: context,
                            type: "error");
                      }
                    },
                    child: const Text(
                      "تایید و ارسال",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    Color? color,
  }) {
    final bool isMobile = Responsive.isMobile(context);
    final themeColor = color ?? AppStyle.primaryColor;

    return Tooltip(
      message: tooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              themeColor.withValues(alpha: 0.15),
              themeColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: themeColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          hoverColor: themeColor.withValues(alpha: 0.1),
          splashColor: themeColor.withValues(alpha: 0.2),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyle.defaultPadding,
              vertical: AppStyle.defaultPadding / (isMobile ? 1.5 : 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: themeColor),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  __filtersCardWidget(BuildContext context) {
    List<Widget> operationWidgetList = [];
    operationWidgetList.add(_buildModernButton(
      context: context,
      label: "10 کاربر آخر",
      icon: Icons.history,
      tooltip: "نمایش ۱۰ کاربر اخیراً ثبت نام شده",
      onPressed: () async {
        EasyLoading.show();
        setState(() {
          _lastPage = 1;
          _showData = false;
        });

        await getLast10BotUser().then((val) {}).whenComplete(() {
          setState(() {
            _showData = true;
          });
        }).onError((e, s) {
          debugPrint(e.toString());
        });
        EasyLoading.dismiss();
      },
    ));

    operationWidgetList.add(_buildModernButton(
      context: context,
      label: "هفته گذشته",
      icon: Icons.calendar_view_week,
      tooltip: "کاربران ثبت نام شده در هفته گذشته",
      onPressed: () async {
        EasyLoading.show();
        setState(() {
          _lastPage = 1;
          _showData = false;
        });

        await getUsersByPastDays(days: 7).then((val) {}).whenComplete(() {
          setState(() {
            _showData = true;
          });
        }).onError((e, s) {
          debugPrint(e.toString());
        });
        EasyLoading.dismiss();
      },
    ));

    operationWidgetList.add(_buildModernButton(
      context: context,
      label: "ماه گذشته",
      icon: Icons.calendar_month,
      tooltip: "کاربران ثبت نام شده در ماه گذشته",
      onPressed: () async {
        EasyLoading.show();
        setState(() {
          _lastPage = 1;
          _showData = false;
        });

        await getUsersByPastDays(days: 30).then((val) {}).whenComplete(() {
          setState(() {
            _showData = true;
          });
        }).onError((e, s) {
          debugPrint(e.toString());
        });
        EasyLoading.dismiss();
      },
    ));

    operationWidgetList.add(_buildModernButton(
      context: context,
      label: "بدون اکانت",
      icon: Icons.no_accounts_outlined,
      tooltip: "کاربرانی که هیچ سرویسی دریافت نکرده‌اند",
      onPressed: () async {
        EasyLoading.show();
        setState(() {
          _lastPage = 1;
          _showData = false;
        });

        await getUsersWithZeroConfigs().then((val) {}).whenComplete(() {
          setState(() {
            _showData = true;
          });
        }).onError((e, s) {
          debugPrint(e.toString());
        });
        EasyLoading.dismiss();
      },
    ));

    operationWidgetList.add(_buildModernButton(
      context: context,
      label: "موجودی صفر/منفی",
      icon: Icons.account_balance_wallet_outlined,
      tooltip: "کاربرانی که موجودی کیف پول آنها صفر یا منفی است",
      onPressed: () async {
        EasyLoading.show();
        setState(() {
          _lastPage = 1;
          _showData = false;
        });

        await getUsersWithZeroBallance().then((val) {}).whenComplete(() {
          setState(() {
            _showData = true;
          });
        }).onError((e, s) {
          debugPrint(e.toString());
        });
        EasyLoading.dismiss();
      },
      color: Colors.amber,
    ));

    operationWidgetList.add(_buildModernButton(
      context: context,
      label: "دستیاران فروش",
      icon: Icons.support_agent,
      tooltip: "نمایش لیست دستیاران فروش",
      onPressed: () async {
        EasyLoading.show();
        setState(() {
          _lastPage = 1;
          _showData = false;
        });

        await getAgentRoleBotUsers().then((val) {}).whenComplete(() {
          setState(() {
            _showData = true;
          });
        }).onError((e, s) {
          debugPrint(e.toString());
        });
        EasyLoading.dismiss();
      },
      color: Colors.purpleAccent,
    ));

    operationWidgetList.add(_buildModernButton(
      context: context,
      label: "ارسال به انتخاب شده‌ها (${_selectedUserAccountIds.length})",
      icon: Icons.send_rounded,
      tooltip: "ارسال پیام به کاربران تیک خورده",
      color: Colors.cyanAccent,
      onPressed: _selectedUserAccountIds.isEmpty
          ? null
          : () => _showSendMessageDialog(context, isAll: false),
    ));

    operationWidgetList.add(_buildModernButton(
      context: context,
      label: "ارسال همگانی",
      icon: Icons.campaign_rounded,
      tooltip: "ارسال پیام به تمامی کاربران ربات",
      color: Colors.orangeAccent,
      onPressed: () => _showSendMessageDialog(context, isAll: true),
    ));

    return Container(
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (value) {
            setState(() {
              _isFiltersExpanded = value;
            });
          },
          initiallyExpanded: _isFiltersExpanded,
          trailing: AnimatedRotation(
            turns: _isFiltersExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppStyle.primaryColor,
              size: 28,
            ),
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppStyle.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.tune_rounded,
                color: AppStyle.primaryColor, size: 24),
          ),
          title: Text(
            "ابزارهای مدیریتی و فیلترها",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppStyle.defaultPadding,
                0,
                AppStyle.defaultPadding,
                AppStyle.defaultPadding,
              ),
              child: Responsive(
                mobile: widgetsGridview(
                    childAspectRatio: 2.8,
                    context: context,
                    crossAxisCount: 2,
                    importedList: operationWidgetList),
                tablet: widgetsGridview(
                    context: context,
                    childAspectRatio: 2.8,
                    crossAxisCount: 2,
                    importedList: operationWidgetList),
                desktop: widgetsGridview(
                    importedList: operationWidgetList,
                    context: context,
                    childAspectRatio: 3.5,
                    crossAxisCount: 4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
