import 'package:provider/provider.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/provider/auth_provider.dart';
import 'package:powerps/screens/admin_screen/user/panel_user/user_profile_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  String _roleLabel(String role) {
    return switch (role) {
      'admin' => 'مدیر',
      'agent' => 'نماینده',
      'user' => 'کاربر',
      _ => role,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthChangeController>(
      builder: (context, auth, _) {
        final user = auth.getUser();
        if (user.role == 'unknown') {
          return const SizedBox.shrink();
        }

        return Tooltip(
          message: 'پروفایل شما · ${_roleLabel(user.role)}',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfileScreen(),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(left: AppStyle.defaultPadding),
                padding: EdgeInsets.symmetric(
                  horizontal: AppStyle.defaultPadding,
                  vertical: AppStyle.defaultPadding / 3,
                ),
                decoration: BoxDecoration(
                  color: AppStyle.secondaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          AppStyle.primaryColor.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.person,
                        size: 16,
                        color: AppStyle.primaryColor,
                      ),
                    ),
                    if (!Responsive.isMobile(context)) ...[
                      SizedBox(width: AppStyle.defaultPadding / 2),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(width: AppStyle.defaultPadding / 4),
                    Icon(
                      Icons.chevron_left,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
