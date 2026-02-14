import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persian_datetimepickers/persian_datetimepickers.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/provider/user_provider.dart';
import 'package:powerps/repositories/bot_user_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/search_field_widget.dart';
import 'package:powerps/widgets/users/bot_users_info_card_widget.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Set<String> _selectedUserAccountIds = {};

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
    Size screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBarWithBackButton(context: context, title: "جستجو"),
          body: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  width: screenSize.width - 20,
                  child: SearchField(
                    autoFocousEnable: true,
                    inputTxt: "",
                    callBack: (val) {},
                  ),
                ),
                _selectedList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _selectedList() {
    return Column(
      children: [
        if (_selectedUserAccountIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
              ),
              onPressed: () => _showSendMessageDialog(context),
              icon: const Icon(Icons.send_to_mobile),
              label: Text(
                  "ارسال پیام به انتخاب شده ها (${_selectedUserAccountIds.length})"),
            ),
          ),
        Flex(
          direction: Axis.horizontal,
          children: [_searchResaultUser()],
        ),
      ],
    );
  }

  void _showSendMessageDialog(BuildContext context) {
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
                title: const Text("ارسال پیام به انتخاب شده ها"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: messageController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: "متن پیام خود را اینجا بنویسید...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDateTime == null
                                ? "زمان ارسال: بلافاصله"
                                : "زمان ارسال: ${selectedDateTime!.toPersianDate()} ${selectedDateTime!.hour}:${selectedDateTime!.minute}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final DateTime? date = await showPersianDatePicker(
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
                          icon: const Icon(Icons.calendar_month),
                          label: const Text("زمانبندی"),
                        ),
                        if (selectedDateTime != null)
                          IconButton(
                            onPressed: () {
                              setDialogState(() {
                                selectedDateTime = null;
                                formattedDateTime = null;
                              });
                            },
                            icon: const Icon(Icons.clear, color: Colors.red),
                          ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("لغو"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (messageController.text.isEmpty) {
                        showMsg(
                            msg: "لطفا متن پیام را وارد کنید",
                            context: context,
                            type: "error");
                        return;
                      }

                      EasyLoading.show(status: 'در حال ارسال...');
                      bool success = await sendAdminMessageToSelectedUsers(
                        userIds: _selectedUserAccountIds.toList(),
                        message: messageController.text,
                        scheduledAt: formattedDateTime,
                      );
                      EasyLoading.dismiss();

                      if (success) {
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        showMsg(
                            msg: "پیام در صف ارسال قرار گرفت",
                            context: context);
                        setState(() {
                          _selectedUserAccountIds.clear();
                        });
                      } else {
                        if (!context.mounted) return;
                        showMsg(
                            msg: "خطا در ارسال پیام",
                            context: context,
                            type: "error");
                      }
                    },
                    child: const Text("تایید و ارسال"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _fillSearchResaultUserList() async {
    String text = context.watch<UserProvider>().userSerchText;
    // create a interval of 2 second if search text is not empty and more than 3 characters
    if (text.isEmpty || text.length < 3) {
      if (!mounted) return;
      Future.delayed(Duration.zero).then((value) {
        if (!mounted) return;

        Provider.of<UserProvider>(context, listen: false).setBotUserList([]);
      });
      Future.delayed(Duration.zero).then((value) {
        if (!mounted) return;

        Provider.of<UserProvider>(context, listen: false).setChanged(false);
      });
      return;
    }
    await searchBotUsers(searchUserText: text).then((value) {
      if (!mounted) return;
      if (value != null) {
        Provider.of<UserProvider>(context, listen: false).setBotUserList(value);
      }
    }).whenComplete(() {
      if (!mounted) return;

      Provider.of<UserProvider>(context, listen: false).setChanged(false);
    });
  }

  _searchResaultUser() {
    bool changed = context.watch<UserProvider>().changed;
    if (!changed) {
      return Expanded(
          flex: 1,
          child: BotUsersInfoCardWidget(
            botUsers: context.watch<UserProvider>().resultBotUserList,
            title: "نتایج",
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
          ));
    } else {
      if (mounted) {
        _fillSearchResaultUserList();
        return Container();
      }
    }
  }
}
