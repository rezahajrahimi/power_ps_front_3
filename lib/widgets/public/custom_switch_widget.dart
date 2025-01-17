import 'package:powerps/helper/public.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';

class CustomSwitchWidget extends StatelessWidget {
  const CustomSwitchWidget(
      {super.key, required this.val, required this.title, this.callback});

  final bool val;
  final String title;
  final Function(bool)? callback;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(
            width: 2, color: AppStyle.primaryColor.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.all(
          Radius.circular(AppStyle.defaultPadding),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            height: 20,
            width: 20,
            child: Icon(Icons.check_box),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
              height: 20,
              width: 20,
              child: Switch(
                  value: val,
                  onChanged: (bool newValue) async {
                    if (newValue) {
                      showMsg(msg: "فعال شد.", context: context);
                    } else {
                      showMsg(msg: "غیر فعال شد.", context: context);
                    }
                    callback!(newValue);
                  }))
        ],
      ),
    );
  }
}
