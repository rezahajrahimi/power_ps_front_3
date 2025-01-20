import 'package:flutter/material.dart';
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBarWithBackButton(context: context, title: "جستجو"),
        body: SafeArea(
          child: SingleChildScrollView(
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
    return Flex(
      direction: Axis.horizontal,
      children: [_searchResaultUser()],
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
          ));
    } else {
      if (mounted) {
        _fillSearchResaultUserList();
        return Container();
      }
    }
  }
}
