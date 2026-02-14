import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/used_test_account_model.dart';
import 'package:powerps/repositories/test_account_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';

class TestUsersListScreen extends StatefulWidget {
  const TestUsersListScreen({super.key});

  @override
  State<TestUsersListScreen> createState() => _TestUsersListScreenState();
}

class _TestUsersListScreenState extends State<TestUsersListScreen> {
  bool _showData = false;
  List<UsedTestAccount> _testUsers = [];

  @override
  void initState() {
    super.initState();
    _fillData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _showData == true
            ? Scaffold(
                appBar: appBarWithBackButton(
                    context: context, title: "لیست کاربران تست"),
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
    List<UsedTestAccount>? res = await getTestUsers();
    if (res != null) {
      setState(() {
        _testUsers = res;
        _showData = true;
      });
    } else {
      if (!mounted) return;
      showMsg(msg: "خطا در دریافت داده‌ها", context: context, type: "error");
      setState(() {
        _showData = true;
      });
    }
  }

  _content(BuildContext context) {
    return Column(
      children: [
        _usersListCard(context),
      ],
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
          Text(
            "کاربران تست",
            style: Theme.of(context).textTheme.titleMedium,
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
            subtitle: Text("Account ID: ${user.accountId}"),
            leading: const Icon(Icons.person),
          ),
        );
      },
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('نام')),
          DataColumn(label: Text('Account ID')),
          DataColumn(label: Text('نقش')),
        ],
        rows: _testUsers.map((user) {
          return DataRow(cells: [
            DataCell(Text(user.user?.name ?? "نامشخص")),
            DataCell(Text(user.accountId.toString())),
            DataCell(Text(user.user?.role ?? "نامشخص")),
          ]);
        }).toList(),
      ),
    );
  }
}
