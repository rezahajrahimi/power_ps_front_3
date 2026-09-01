import 'package:flutter/material.dart';

import 'package:powerps/styles/app_theme.dart';

class DrawerListTileV4 extends StatelessWidget {
  const DrawerListTileV4(
      {super.key,
      required this.title,
      required this.icon,
      required this.press,
      required this.isSelected});
  final String title;
  final IconData icon;
  final VoidCallback press;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: Icon(
        icon,
        size: 16,
        color: isSelected ? AppStyle.activeStatus : AppStyle.deactiveStatus,
      ),
      // leading: SvgPicture.asset(
      //   svgSrc,
      //   color: Colors.white54,
      //   height: 16,
      // ),
      title: Text(
        title,
        style: TextStyle(
            color:
                isSelected ? AppStyle.activeStatus : AppStyle.deactiveStatus),
      ),
    );
  }
}
