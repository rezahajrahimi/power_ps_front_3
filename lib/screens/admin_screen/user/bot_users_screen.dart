import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/repositories/bot_user_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:pagination_flutter/pagination.dart';
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
      if (value != false && value != null) {
        setState(() {
          _lastPage = lastPage;

          _showData = true;
        });
      } else {
        if (!mounted) return;

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

  // _botUserInfoTabCard(BuildContext context) {
  //   return Container(
  //     padding: EdgeInsets.all(AppStyle.defaultPadding),
  //     decoration: BoxDecoration(
  //       color: AppStyle.secondaryColor,
  //       borderRadius: const BorderRadius.all(Radius.circular(10)),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           "کاربران",
  //           style: Theme.of(context).textTheme.titleMedium,
  //         ),
  //         SizedBox(height: AppStyle.defaultPadding),
  //         SizedBox(
  //             width: double.infinity,
  //             child: Responsive(
  //               mobile: widgetsGridview(
  //                   childAspectRatio: 2.9,
  //                   context: context,
  //                   importedList: _botUserWidgetLIst),
  //               tablet: widgetsGridview(
  //                   context: context,
  //                   childAspectRatio: 6,
  //                   importedList: _botUserWidgetLIst),
  //               desktop: widgetsGridview(
  //                   importedList: _botUserWidgetLIst,
  //                   context: context,
  //                   childAspectRatio: 6,
  //                   crossAxisCount: 2),
  //             )),
  //         Pagination(
  //           numOfPages: _lastPage,
  //           selectedPage: selectedPage,
  //           pagesVisible: 4,
  //           onPageChanged: (page) async {
  //             setState(() {
  //               selectedPage = page;
  //               _showData = false;
  //             });
  //             await getBotUserList(page: page);
  //             setState(() {
  //               _lastPage = lastPage;

  //               _showData = true;
  //             });
  //           },
  //           nextIcon: const Icon(
  //             Icons.arrow_forward_ios,
  //             color: Colors.blue,
  //             size: 14,
  //           ),
  //           previousIcon: const Icon(
  //             Icons.arrow_back_ios,
  //             color: Colors.blue,
  //             size: 14,
  //           ),
  //           activeTextStyle: const TextStyle(
  //             color: Colors.white,
  //             fontSize: 14,
  //             fontWeight: FontWeight.w700,
  //           ),
  //           activeBtnStyle: ButtonStyle(
  //             backgroundColor: WidgetStateProperty.all(Colors.blue),
  //             shape: WidgetStateProperty.all(
  //               RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(38),
  //               ),
  //             ),
  //           ),
  //           inactiveBtnStyle: ButtonStyle(
  //             shape: WidgetStateProperty.all(RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(38),
  //             )),
  //           ),
  //           inactiveTextStyle: const TextStyle(
  //             fontSize: 14,
  //             fontWeight: FontWeight.w700,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
