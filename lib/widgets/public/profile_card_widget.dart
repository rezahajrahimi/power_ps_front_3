import 'package:provider/provider.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/provider/auth_provider.dart';
import 'package:powerps/screens/admin_screen/user/panel_user/user_profile_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({
    super.key,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  bool _showData = false;
  late User loggedUSer;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserProfileScreen(),
            ));
      },
      child: Container(
        margin: EdgeInsets.only(left: AppStyle.defaultPadding),
        padding: EdgeInsets.symmetric(
          horizontal: AppStyle.defaultPadding,
          vertical: AppStyle.defaultPadding / 2,
        ),
        decoration: BoxDecoration(
          color: AppStyle.secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            _profilePic(),
            if (!Responsive.isMobile(context))
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppStyle.defaultPadding / 2),
                child: _showData == true
                    ? Text(loggedUSer.name)
                    : const Opacity(opacity: 1),
              ),
            // const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  _profilePic() {
    return const Icon(Icons.manage_accounts);
  }

  void _loadData() {
    if (context.mounted) {
      setState(() {
        loggedUSer =
            Provider.of<AuthChangeController>(context, listen: false).getUser();

        _showData = true;
      });
    }
  }
}
