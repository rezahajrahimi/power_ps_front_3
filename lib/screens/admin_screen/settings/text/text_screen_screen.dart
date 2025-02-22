import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/custom_text_model.dart';
import 'package:powerps/repositories/custom_text_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/formatted_text_editor_widget.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class TextScreenScreen extends StatefulWidget {
  const TextScreenScreen({super.key});

  @override
  State<TextScreenScreen> createState() => _TextScreenScreenState();
}

class _TextScreenScreenState extends State<TextScreenScreen> {
  bool _showData = true;
  List<CustomTextModel> _customTextModelList = [];
  final List<Widget> _customTextModelWidgetList = [];
  @override
  void initState() {
    _fillData();
    super.initState();
  }

  void _fillData() async {
    _customTextModelList = await getCustomTexts().then(
      (value) {
        if (value.isNotEmpty) {
          _customTextModelList = value;
          for (var i in _customTextModelList) {
            _customTextModelWidgetList.add(FormattedTextEditorWidget(
              customTextModel: i,
              isJsonFormat: true,
              onTextChanged: (String newText) {},
            ));
            setState(() {
              _showData = true;
            });
          }
        }
        return [];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBarWithBackButton(context: context, title: "متن و پیام ها"),
        body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            child: Column(
              children: [_showCustomTextModelWidgetList()],
            ),
          ),
        ),
        bottomNavigationBar: Responsive.isMobile(context)
            ? _buildBottomNavigationBar(context)
            : const Opacity(opacity: 1),
      ),
    );
  }

  Widget _showCustomTextModelWidgetList() {
    return _showData
        ? Container(
            padding: EdgeInsets.all(AppStyle.defaultPadding),
            decoration: BoxDecoration(
              color: AppStyle.secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "متن ها",
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
                        importedList: _customTextModelWidgetList),
                    tablet: widgetsGridview(
                        context: context,
                        childAspectRatio: 2.5,
                        crossAxisCount: 1,
                        importedList: _customTextModelWidgetList),
                    desktop: widgetsGridview(
                        importedList: _customTextModelWidgetList,
                        context: context,
                        childAspectRatio: 5,
                        crossAxisCount: 2),
                  ),
                ),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
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
}
