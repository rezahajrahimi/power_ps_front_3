// ignore_for_file: prefer_const_constructors

import 'package:powerps/provider/user_provider.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SearchField extends StatefulWidget {
  final TextEditingController? searchController;
  final ValueChanged? searchOnChanged;
  final Function(String)? callBack;
  final String? inputTxt;
  final bool autoFocousEnable;

  const SearchField({
    super.key,
    this.callBack,
    this.searchController,
    this.searchOnChanged,
    this.inputTxt,
    required this.autoFocousEnable,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: widget.autoFocousEnable,
      controller: widget.searchController,
      showCursor: widget.autoFocousEnable,
      readOnly: !widget.autoFocousEnable,
      onChanged: (value) {
        if (value.toString().isNotEmpty && value.toString() != "") {
          Provider.of<UserProvider>(context, listen: false)
              .setUserSerchText(value);
          Provider.of<UserProvider>(context, listen: false).setChanged(true);
        }
      },
      onTap: () {
        widget.callBack!("a");

        // widget.searchOnChanged;
      },
      decoration: InputDecoration(
        hintText: "جستجو (نام، ID، یوزرنیم، اسم مستعار...)",
        fillColor: AppStyle.secondaryColor,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(AppStyle.defaultPadding * 0.75),
            margin:
                EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding / 2),
            decoration: BoxDecoration(
              color: AppStyle.primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset("assets/images/icons/Search.svg"),
          ),
        ),
      ),
    );
  }
}
