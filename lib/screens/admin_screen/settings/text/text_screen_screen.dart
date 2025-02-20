import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/formatted_text_editor.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class TextScreenScreen extends StatefulWidget {
  const TextScreenScreen({super.key});

  @override
  State<TextScreenScreen> createState() => _TextScreenScreenState();
}

class _TextScreenScreenState extends State<TextScreenScreen> {
  bool _showData = true;
  @override
  void initState() {
    _fillData();
    super.initState();
  }

  void _fillData() async {}

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBarWithBackButton(context: context, title: "متن و پیام ها"),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppStyle.defaultPadding),
                    decoration: BoxDecoration(
                      color: AppStyle.secondaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: FormattedTextEditor(
                      initialText: 'متن اولیه',
                      onTextChanged: (String newText) {
                        print('متن جدید: $newText');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Responsive.isMobile(context)
            ? _buildBottomNavigationBar(context)
            : const Opacity(opacity: 1),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyle.defaultPadding,
        vertical: AppStyle.defaultPadding / 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("ثبت"),
            ),
          ),
        ],
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
                    _textListCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
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
                    _operationInfoCard(context),
                    SizedBox(height: AppStyle.defaultPadding),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  _operationInfoCard(BuildContext context) {
    List<Widget> actionsWidgetList = [];
    actionsWidgetList.add(ElevatedButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppStyle.defaultPadding * 1.5,
          vertical:
              AppStyle.defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
        ),
      ),
      onPressed: () async {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => const AddNewPanelScreen(),
        //     )).then((value) => {_fillData()});
      },
      icon: const Icon(Icons.save),
      label: const Text("ذخیره"),
    ));
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

  _textListCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          // Text("متن و پیام ها"),
          // FormattedTextEditor(
          //   initialText: 'متن اولیه',
          //   onTextChanged: (String newText) {
          //     // اینجا می‌توانید متن تغییر یافته را مدیریت کنید
          //     print('متن جدید: $newText');
          //   },
          // )
        ],
      ),
    );
  }
}
