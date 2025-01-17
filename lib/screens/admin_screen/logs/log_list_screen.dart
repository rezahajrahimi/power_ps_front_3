import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/repositories/log_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/log/recent_events_list_widget.dart';

class LogsListScreen extends StatefulWidget {
  const LogsListScreen({super.key});

  @override
  State<LogsListScreen> createState() => _LogsListScreenState();
}

class _LogsListScreenState extends State<LogsListScreen> {
  BuildContext? myContext;
  bool _showEvents = false;

  @override
  void initState() {
    _retriveData();
    super.initState();
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
                  // const Header(title: "رخدادها"),
                  // SizedBox(height: AppStyle.defaultPadding),
                  _showEvents == false
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

  void _retriveData() async {
    await getAllLogs(count: 400);
    setState(() {
      if (lastLogList.isNotEmpty) {
        _showEvents = true;
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
                  RecentEvents(type: "fullList", events: lastLogList),
                ],
              ),
            ),
            if (!Responsive.isMobile(context))
              SizedBox(width: AppStyle.defaultPadding),
          ],
        )
      ],
    );
  }
}
