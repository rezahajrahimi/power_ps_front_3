import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/repositories/panel_user_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/appbar_with_back_buttun.dart';
import 'package:powerps/widgets/public/custome_text_from_field_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _showData = false;
  bool _loadFailed = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  User? _currentUserData;
  String _originalName = '';

  final _name = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool get _isAdmin => _currentUserData?.role == 'admin';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          bottomNavigationBar: Responsive.isMobile(context) && _showData
              ? _buildBottomNavigationBar(context)
              : null,
          appBar: appBarWithBackButton(context: context, title: 'پروفایل شما'),
          body: SafeArea(
            child: _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loadFailed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.white54),
            SizedBox(height: AppStyle.defaultPadding),
            const Text('بارگذاری اطلاعات کاربری ناموفق بود'),
            SizedBox(height: AppStyle.defaultPadding),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    if (!_showData) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      primary: false,
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              children: [
                _profileHeaderCard(context),
                SizedBox(height: AppStyle.defaultPadding),
                _accountInfoCard(context),
                SizedBox(height: AppStyle.defaultPadding),
                _passwordChangeCard(context),
              ],
            ),
          ),
          if (!Responsive.isMobile(context)) ...[
            SizedBox(width: AppStyle.defaultPadding),
            Expanded(
              flex: 2,
              child: _submitActionCard(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _profileHeaderCard(BuildContext context) {
    final user = _currentUserData!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppStyle.defaultPadding * 1.25),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppStyle.primaryColor.withValues(alpha: 0.2),
            child: Icon(
              Icons.person,
              size: 36,
              color: AppStyle.primaryColor,
            ),
          ),
          SizedBox(width: AppStyle.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: AppStyle.defaultPadding / 4),
                Text(
                  'شناسه حساب: ${user.accountId}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          _roleBadge(user.role),
        ],
      ),
    );
  }

  Widget _roleBadge(String role) {
    final label = _roleLabel(role);
    final color = switch (role) {
      'admin' => AppStyle.primaryColor,
      'agent' => Colors.orangeAccent,
      _ => Colors.greenAccent,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyle.defaultPadding * 0.75,
        vertical: AppStyle.defaultPadding / 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _roleLabel(String role) {
    return switch (role) {
      'admin' => 'مدیر',
      'agent' => 'نماینده',
      'user' => 'کاربر',
      _ => role,
    };
  }

  Widget _accountInfoCard(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final fieldMaxWidth = isMobile ? double.infinity : 400.0;

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('اطلاعات حساب', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppStyle.defaultPadding / 2),
          Text(
            _isAdmin
                ? 'نام کاربری قابل ویرایش است.'
                : 'نام کاربری فقط خواندنی است. برای تغییر رمز، بخش پایین را تکمیل کنید.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                ),
          ),
          SizedBox(height: AppStyle.defaultPadding / 2),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: fieldMaxWidth),
              child: CustomTextFromFieldWidget(
                controller: _name,
                textHint: 'نام کاربری',
                validationError: 'نام کاربری را وارد کنید.',
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                enable: _isAdmin,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordChangeCard(BuildContext context) {
    final fields = <Widget>[
      _passwordField(
        controller: _password,
        hint: 'رمز عبور جدید',
        obscure: _obscurePassword,
        onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      _passwordField(
        controller: _confirmPassword,
        hint: 'تکرار رمز عبور جدید',
        obscure: _obscureConfirmPassword,
        onToggle: () =>
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
      ),
    ];

    return _sectionCard(
      context: context,
      title: 'تغییر رمز عبور',
      subtitle: 'در صورت عدم نیاز به تغییر رمز، این فیلدها را خالی بگذارید.',
      fields: fields,
      crossAxisCount: Responsive.isMobile(context) ? 1 : 2,
      childAspectRatio: Responsive.isMobile(context) ? 2.9 : 4,
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: AppStyle.primaryColor.withValues(alpha: 0.15),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(AppStyle.defaultPadding),
        ),
      ),
      child: TextFormField(
        controller: controller,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          labelText: hint,
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: onToggle,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 1),
          ),
          fillColor: AppStyle.secondaryColor,
          filled: true,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<Widget> fields,
    required int crossAxisCount,
    required double childAspectRatio,
  }) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppStyle.defaultPadding / 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                ),
          ),
          SizedBox(height: AppStyle.defaultPadding / 2),
          SizedBox(
            width: double.infinity,
            child: Responsive(
              mobile: widgetsGridview(
                childAspectRatio: childAspectRatio,
                context: context,
                importedList: fields,
                crossAxisCount: crossAxisCount,
              ),
              tablet: widgetsGridview(
                context: context,
                childAspectRatio: childAspectRatio,
                importedList: fields,
                crossAxisCount: crossAxisCount,
              ),
              desktop: widgetsGridview(
                importedList: fields,
                context: context,
                childAspectRatio: size.width < 1400 ? childAspectRatio : 5.5,
                crossAxisCount: crossAxisCount,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : () => _submitData(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyle.primaryColor,
          disabledBackgroundColor: AppStyle.primaryColor.withValues(alpha: 0.5),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done, color: Colors.white),
                  SizedBox(width: 4),
                  Text('ثبت تغییرات', style: TextStyle(color: Colors.white)),
                ],
              ),
      ),
    );
  }

  Widget _submitActionCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('عملیات', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppStyle.defaultPadding),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : () => _submitData(context),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.done),
            label: Text(_isSubmitting ? 'در حال ذخیره...' : 'ثبت تغییرات'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserData() async {
    setState(() {
      _showData = false;
      _loadFailed = false;
    });

    final value = await getUserInfo();
    if (!mounted) return;

    if (value == null) {
      setState(() => _loadFailed = true);
      return;
    }

    setState(() {
      _currentUserData = value;
      _originalName = value.name;
      _name.text = value.name;
      _showData = true;
    });
  }

  String? _validatePasswordChange() {
    final hasPassword = _password.text.isNotEmpty;
    final hasConfirm = _confirmPassword.text.isNotEmpty;

    if (!hasPassword && !hasConfirm) return null;

    if (hasPassword != hasConfirm) {
      return 'هر دو فیلد رمز عبور باید تکمیل شوند';
    }

    if (_password.text != _confirmPassword.text) {
      return 'رمز عبور و تکرار آن باید یکسان باشند';
    }

    if (_password.text.length < 8) {
      return 'رمز عبور باید حداقل ۸ کاراکتر باشد';
    }

    return null;
  }

  Future<void> _submitData(BuildContext context) async {
    if (_currentUserData == null || _isSubmitting) return;

    final passwordError = _validatePasswordChange();
    if (passwordError != null) {
      showMsg(msg: passwordError, context: context, type: 'error');
      return;
    }

    final wantsPasswordChange =
        _password.text.isNotEmpty || _confirmPassword.text.isNotEmpty;
    final wantsNameChange = _isAdmin && _name.text.trim() != _originalName;

    if (!wantsPasswordChange && !wantsNameChange) {
      showMsg(
        msg: 'تغییری برای ذخیره وجود ندارد',
        context: context,
        type: 'error',
      );
      return;
    }

    if (_isAdmin && _name.text.trim().isEmpty) {
      showMsg(
        msg: 'نام کاربری نمی‌تواند خالی باشد',
        context: context,
        type: 'error',
      );
      return;
    }

    if (!_isAdmin && !wantsPasswordChange) {
      showMsg(
        msg: 'برای ذخیره، رمز عبور جدید را وارد کنید',
        context: context,
        type: 'error',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    EasyLoading.show();

    try {
      final success = await _performUpdate(wantsNameChange, wantsPasswordChange);
      if (!context.mounted) return;

      if (success) {
        _password.clear();
        _confirmPassword.clear();
        if (wantsNameChange) {
          _originalName = _name.text.trim();
        }
        showMsg(msg: 'تغییرات با موفقیت ذخیره شد', context: context);
      } else {
        showMsg(
          msg: 'ذخیره تغییرات ناموفق بود. لطفاً دوباره تلاش کنید',
          context: context,
          type: 'error',
        );
      }
    } finally {
      EasyLoading.dismiss();
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _performUpdate(
    bool wantsNameChange,
    bool wantsPasswordChange,
  ) async {
    final user = _currentUserData!;

    if (_isAdmin) {
      return updateUser(
        user: User(
          id: user.id,
          name: _name.text.trim(),
          accountId: user.accountId,
          role: user.role,
        ),
        password: wantsPasswordChange ? _password.text : null,
      );
    }

    if (user.role == 'agent') {
      return changeAgentPassword(password: _password.text);
    }

    return updateUserPassword(password: _password.text);
  }
}
