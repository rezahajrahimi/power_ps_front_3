import 'package:powerps/helper/responsive.dart';
import 'package:powerps/provider/menu_provider.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/profile_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;

  const Header({
    super.key,
    required this.title,
    this.height = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!Responsive.isDesktop(context))
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: context.read<MenuAppController>().controlMenu,
            ),
          if (!Responsive.isMobile(context))
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          // if (!Responsive.isMobile(context))
          //   Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
          // Expanded(
          //     child: SearchField(
          //   autoFocousEnable: false,
          //   callBack: (val) {
          //     // Navigator.push(
          //     //     context,
          //     //     MaterialPageRoute(
          //     //       builder: (context) => const SearchScreen(),
          //     //     ));
          //   },
          // )),
          SizedBox(
            width: AppStyle.defaultPadding,
          ),
          const ProfileCard()
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
