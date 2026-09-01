import 'package:powerps/helper/responsive.dart';
import 'package:powerps/provider/menu_provider.dart';
import 'package:powerps/screens/admin_screen/search/search_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/profile_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:powerps/widgets/public/search_field_widget.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;
  final bool showSearch;

  const Header({
    super.key,
    required this.title,
    this.height = kToolbarHeight,
    this.showSearch = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!Responsive.isDesktop(context))
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: context.read<MenuAppController>().controlMenu,
              ),
            if (!Responsive.isMobile(context) || !showSearch)
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            if (showSearch)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: SearchField(
                    autoFocousEnable: false,
                    callBack: (val) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                          ));
                    },
                  ),
                ),
              )
            else
              const Spacer(),
            SizedBox(
              width: AppStyle.defaultPadding,
            ),
            const ProfileCard()
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
