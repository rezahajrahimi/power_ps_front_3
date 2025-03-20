import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/repositories/panel_user_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _showData = false;
  User? _currentUserData;

  final _name = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void initState() {
    _name.clear();
    _password.clear();
    _confirmPassword.clear();

    _getUserData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        bottomNavigationBar: Responsive.isMobile(context)
            ? _buildBottomNavigationBar(context)
            : const Opacity(opacity: 1),
        appBar: appBarWithBackButton(context: context, title: "پروفایل شما"),
        body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: _showData
                ? _content(context)
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ),
      ),
    );
  }

  void _getUserData() async {
    await getUserInfo().then((value) {
      if (value != null) {
        setState(() {
          _currentUserData = value;
        });
        _name.text = _currentUserData!.name;

        setState(() {
          _showData = true;
        });
      }
    });
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
                  _userCard(context),
                ],
              ),
            ),
            SizedBox(width: AppStyle.defaultPadding),
            // On Mobile means if the screen is less than 850 we dont want to show it
            if (!Responsive.isMobile(context)) // side windows
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _submitActionCard(context),
                    SizedBox(width: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        )
      ],
    );
  }

  _userCard(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    List<Widget> myList = [];
    setState(() {
      myList.add(CustomTextFromFieldWidget(
        controller: _name,
        textHint: "نام کاربری",
        validationError: "نام کاربری را وارد کنید.",
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
      ));
      myList.add(CustomTextFromFieldWidget(
        controller: _password,
        textHint: "رمز عبور",
        validationError: "رمز عبور را وارد کنید",
        keyboardType: TextInputType.text,
        obscureText: true,
        validatorType: "password",
      ));
      myList.add(CustomTextFromFieldWidget(
        controller: _confirmPassword,
        textHint: "تکرار رمز عبور",
        validationError: "تکرار رمز عبور را وارد کنید",
        keyboardType: TextInputType.text,
        obscureText: true,
        validatorType: "password",
      ));
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
            "اطلاعات کاربری شما",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: myList,
                  crossAxisCount: 1),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4,
                  importedList: myList,
                  crossAxisCount: 2),
              desktop: widgetsGridview(
                  importedList: myList,
                  context: context,
                  childAspectRatio: size.width < 1400 ? 4 : 5.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        child: ElevatedButton(
          onPressed: () {
            _submitData(context);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: AppStyle.secondaryColor),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.done,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 4.0,
                ),
                Text(
                  "ثبت تغییرات",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ));
  }

  void _submitData(BuildContext context) async {
    // بررسی خالی بودن همه فیلدها
    if (_name.text.isEmpty &&
        _password.text.isEmpty &&
        _confirmPassword.text.isEmpty) {
      showMsg(
          msg: "اطلاعات درخواستی را وارد کنید",
          context: context,
          type: "error");
      return;
    }
    
    // بررسی رمز عبور
    if (_password.text.isNotEmpty || _confirmPassword.text.isNotEmpty) {
      // بررسی یکسان بودن رمز عبور و تکرار آن
      if (_password.text != _confirmPassword.text) {
        showMsg(
            msg: "رمز عبور و تکرار آن باید یکسان باشند",
            context: context,
            type: "error");
        return;
      }
      
      // بررسی طول رمز عبور
      if (_password.text.length < 8) {
        showMsg(
            msg: "رمز عبور باید حداقل 8 کاراکتر باشد",
            context: context,
            type: "error");
        return;
      }
    }
    
    // اعتبارسنجی نام کاربری
    if (_name.text.isEmpty) {
      showMsg(
          msg: "نام کاربری نمی‌تواند خالی باشد",
          context: context,
          type: "error");
      return;
    }
    
    // اگر همه شرایط برقرار بود، به‌روزرسانی را انجام بده
    if (_currentUserData!.role == "admin") {
      if (!context.mounted) return;
      EasyLoading.show();

      await updateUser(
              user: User(
                  id: _currentUserData!.id,
                  name: _name.text,
                  accountId: _currentUserData!.accountId,
                  role: _currentUserData!.role),
              password: _password.text)
          .then((value) {
        if (!context.mounted) return;
        if (value) {
          showMsg(msg: "با موفقیت انجام شد", context: context);
          return;
        }
        showMsg(msg: "خطا", context: context, type: "error");
      });
      EasyLoading.dismiss();
    } else {
      await updateUserPassword(password: _password.text).then((value) {
        if (!context.mounted) return;
        if (value) {
          showMsg(msg: "با موفقیت انجام شد", context: context);
          return;
        }
        showMsg(msg: "خطا", context: context, type: "error");
      });
    }
  }

  _submitActionCard(BuildContext context) {
    List<Widget> myList = [];
    final Size size = MediaQuery.of(context).size;
    setState(() {
      myList.add(ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding * 1.5,
            vertical: AppStyle.defaultPadding /
                (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () async {
          _submitData(context);
        },
        icon: const Icon(Icons.done),
        label: const Text("ثبت تغییرات"),
      ));
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
            "عملیات‌ها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
              width: double.infinity,
              child: Responsive(
                mobile: widgetsGridview(
                    context: context,
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    importedList: myList),
                tablet: widgetsGridview(
                    context: context,
                    crossAxisCount: 1,
                    childAspectRatio: size.width < 1400 ? 3 : 4.5,
                    importedList: myList),
                desktop: widgetsGridview(
                    importedList: myList,
                    context: context,
                    childAspectRatio: size.width < 1400 ? 3 : 4.5,
                    crossAxisCount: 2),
              )),
        ],
      ),
    );
  }
}
