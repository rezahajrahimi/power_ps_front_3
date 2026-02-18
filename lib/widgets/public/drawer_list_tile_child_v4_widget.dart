import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';

class DrawerListTileChildV4 extends StatelessWidget {
  const DrawerListTileChildV4({
    super.key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.press,
    required this.icon,
    required this.isSelected,
  });

  final String title;
  final IconData icon;
  final VoidCallback press;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ListTile(
        onTap: press,
        horizontalTitleGap: 0.0,
        leading: Icon(icon,
            size: 16,
            color:
                isSelected ? AppStyle.activeStatus : AppStyle.deactiveStatus),
        title: Text(
          title,
          style: TextStyle(
              color:
                  isSelected ? AppStyle.activeStatus : AppStyle.deactiveStatus),
        ),
      ),
    );
  }
}
