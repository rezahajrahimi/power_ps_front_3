import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/pannel_model.dart';
import 'package:powerps/models/used_test_account_model.dart';
import 'package:powerps/repositories/pannel_repository.dart';
import 'package:powerps/repositories/test_account_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class TestAccountManagementScreen extends StatefulWidget {
  const TestAccountManagementScreen({super.key});

  @override
  State<TestAccountManagementScreen> createState() =>
      _TestAccountManagementScreenState();
}

class _TestAccountManagementScreenState
    extends State<TestAccountManagementScreen> {
  bool _showData = false;
  final _volTxtEdit = TextEditingController();
  final _expireDayTxtEdit = TextEditingController();
  String _selectedPannelName = "";
  final List<Widget> _infoWidgetList = [];
  final List<String> _pannelNameList = [];
  List<UsedTestAccount> _testUsers = [];

  @override
  void initState() {
    super.initState();
    _fillData();
  }

  @override
  void dispose() {
    super.dispose();
    _infoWidgetList.clear();
    _pannelNameList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _showData == true
            ? Scaffold(
                appBar: appBarWithBackButton(
                    context: context, title: "مدیریت اکانت آزمایشی"),
                bottomNavigationBar: Responsive.isMobile(context)
                    ? _buildBottomNavigationBar(context)
                    : const Opacity(opacity: 1),
                body: SingleChildScrollView(
                  primary: false,
                  padding: EdgeInsets.all(AppStyle.defaultPadding),
                  child: _content(context),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  void _fillData() async {
    List<UsedTestAccount>? usersRes = await getTestUsers();
    if (usersRes != null) {
      _testUsers = usersRes;
    }

    List<Pannel> resPannel = await getPannels();
    await getTestAccountDetails().then((res) async {
      if (res != null) {
        _infoWidgetList.clear();
        _volTxtEdit.text = res.volume;
        _expireDayTxtEdit.text = res.expireDay;

        setState(() {
          _infoWidgetList.add(CustomTextFromFieldWidget(
            controller: _volTxtEdit,
            textDirection: TextDirection.ltr,
            textHint: "حجم اکانت",
            validationError: "حجم اکانت را وارد کنید.",
          ));
          _infoWidgetList.add(CustomTextFromFieldWidget(
            controller: _expireDayTxtEdit,
            textDirection: TextDirection.ltr,
            textHint: "تعداد روز",
            validationError: "تعداد روز را وارد کنید.",
          ));
          if (resPannel.isNotEmpty) {
            setState(() {
              _pannelNameList.clear();
              for (var i in resPannel) {
                if (i.type != "custom") {
                  _pannelNameList.add(
                      "${i.id}: ${getPannelName(name: i.type)} - ${i.location}");
                }

                if (i.id == res.pannelId) {
                  _selectedPannelName =
                      "${i.id}: ${getPannelName(name: i.type)} - ${i.location}";
                }
              }

              _infoWidgetList.add(DropdownButtonFormField(
                isExpanded: true,
                hint: const Text('نوع پنل'),
                initialValue: _selectedPannelName,
                alignment: Alignment.centerRight,
                onChanged: (newValue) {
                  setState(() {
                    _selectedPannelName = newValue.toString();
                  });
                },
                items: _pannelNameList.map((clType) {
                  return DropdownMenuItem(
                    value: clType,
                    alignment: Alignment.centerRight,
                    child: Text(clType),
                  );
                }).toList(),
              ));
            });
          }
          _showData = true;
        });
      } else {
        if (!mounted) return;
        showMsg(msg: "خطا", context: context, type: "error");
        showMsg(
            msg:
                "در صورتیکه به تازگی ربات را راه‌اندازی کرده اید، ابتدا می بایست یک پنل ایجاد کنید.",
            context: context,
            type: "error");

        Navigator.pop(context);
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
                    _accountInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                    _usersListCard(context),
                  ],
                )),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
            // side windows
            if (!Responsive.isMobile(context))
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _actionInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        ),
      ],
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
                  Icons.edit,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 4.0,
                ),
                Text(
                  "ویرایش",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ));
  }

  _accountInfoCard(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          color: AppStyle.secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "اطلاعات اکانت",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 2.9,
                  context: context,
                  importedList: _infoWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 4.5,
                  importedList: _infoWidgetList),
              desktop: widgetsGridview(
                  importedList: _infoWidgetList,
                  context: context,
                  childAspectRatio: 4.5,
                  crossAxisCount: 2),
            ),
          )
        ]));
  }

  _submitData(BuildContext context) async {
    EasyLoading.show();
    int pannelID = 1;
    if (_selectedPannelName != "") {
      pannelID = int.parse(_selectedPannelName.split(":")[0]);
    }
    if (_expireDayTxtEdit.text.isNotEmpty && _volTxtEdit.text.isNotEmpty) {
      await updateTestAccountDetails(
              pannelID: pannelID,
              expireDays: int.parse(_expireDayTxtEdit.text),
              volume: double.parse(_volTxtEdit.text))
          .then((value) {
        if (!context.mounted) return;

        if (value != null) {
          showMsg(msg: "ویرایش شد.", context: context);
          _fillData();
        } else {
          showMsg(msg: "خطا", context: context, type: "error");
        }
      });
    } else {
      showMsg(msg: "اطلاعات درخواست شده را وارد کنید.", context: context);
    }
    EasyLoading.dismiss();
  }

  _actionInfoCard(BuildContext context) {
    List<Widget> actionsWidgetList = [];

    setState(() {
      actionsWidgetList.add(ElevatedButton.icon(
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
        icon: const Icon(Icons.edit),
        label: const Text("ویرایش"),
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
            "عملیات ها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                  childAspectRatio: 5,
                  context: context,
                  crossAxisCount: 1,
                  importedList: actionsWidgetList),
              tablet: widgetsGridview(
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 1,
                  importedList: actionsWidgetList),
              desktop: widgetsGridview(
                  importedList: actionsWidgetList,
                  context: context,
                  childAspectRatio: 2.5,
                  crossAxisCount: 2),
            ),
          ),
        ],
      ),
    );
  }

  _usersListCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "کاربران تست",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton.icon(
                onPressed: _clearAllUsers,
                icon: const Icon(Icons.clear),
                label: const Text("خالی کردن لیست"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyle.defaultPadding),
          _testUsers.isEmpty
              ? const Text("هیچ کاربری یافت نشد.")
              : Responsive(
                  mobile: _buildMobileList(),
                  tablet: _buildMobileList(),
                  desktop: _buildTable(),
                ),
        ],
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _testUsers.length,
      itemBuilder: (context, index) {
        final user = _testUsers[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(user.user?.name ?? "نامشخص"),
            subtitle: Text(
                "Account ID: ${user.accountId} - تاریخ: ${user.createdAt ?? ''}"),
            leading: const Icon(Icons.person),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteUser(user.id),
            ),
          ),
        );
      },
    );
  }

  void _deleteUser(String id) async {
    bool? result = await deleteTestUser(id);
    if (result == true) {
      showMsg(msg: "کاربر حذف شد.", context: context);
      _fillData();
    } else {
      showMsg(msg: "خطا در حذف", context: context, type: "error");
    }
  }

  void _clearAllUsers() async {
    bool? result = await clearTestUsers();
    if (result == true) {
      showMsg(msg: "لیست خالی شد.", context: context);
      setState(() {
        _testUsers.clear();
      });
    } else {
      showMsg(msg: "خطا در خالی کردن لیست", context: context, type: "error");
    }
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('نام')),
          DataColumn(label: Text('Account ID')),
          DataColumn(label: Text('تاریخ ایجاد')),
          DataColumn(label: Text('اکشن')),
        ],
        rows: _testUsers.map((user) {
          return DataRow(cells: [
            DataCell(Text(user.user?.name ?? "نامشخص")),
            DataCell(Text(user.accountId.toString())),
            DataCell(Text(user.createdAt ?? '')),
            DataCell(IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteUser(user.id),
            )),
          ]);
        }).toList(),
      ),
    );
  }
}
