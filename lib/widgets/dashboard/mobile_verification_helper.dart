import 'package:flutter/material.dart';
import 'package:powerps/repositories/webapp_user_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileVerificationStatus {
  const MobileVerificationStatus({
    required this.required,
    required this.verified,
    this.iranOnly = false,
    this.phoneNumber,
    this.botUsername,
    this.message,
  });

  final bool required;
  final bool verified;
  final bool iranOnly;
  final String? phoneNumber;
  final String? botUsername;
  final String? message;

  bool get needsAction => required && !verified;

  factory MobileVerificationStatus.fromJson(Map<String, dynamic> json) {
    return MobileVerificationStatus(
      required: json['required'] == true,
      verified: json['verified'] == true,
      iranOnly: json['iran_only'] == true,
      phoneNumber: json['phone_number']?.toString(),
      botUsername: json['bot_username']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

class MobileVerificationHelper {
  static Future<MobileVerificationStatus?> fetchStatus() async {
    final data = await getWebAppMobileVerificationStatus();
    if (data == null) return null;
    return MobileVerificationStatus.fromJson(data);
  }

  static Future<bool> ensureVerifiedForPurchase(BuildContext context) async {
    final status = await fetchStatus();
    if (!context.mounted) return false;
    if (status == null || !status.needsAction) {
      return true;
    }

    await showMobileVerificationDialog(context, status);
    return false;
  }

  static Future<void> showMobileVerificationDialog(
    BuildContext context,
    MobileVerificationStatus status,
  ) async {
    final bot = status.botUsername?.trim();
    final botUrl = bot != null && bot.isNotEmpty ? 'https://t.me/$bot' : null;

    await showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تایید موبایل لازم است'),
          content: Text(
            status.message ??
                'برای خرید باید ابتدا شماره موبایل خود را در ربات تلگرام تایید کنید.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('بستن'),
            ),
            if (botUrl != null)
              ElevatedButton(
                onPressed: () async {
                  await launchUrl(
                    Uri.parse(botUrl),
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: const Text('باز کردن ربات'),
              ),
          ],
        ),
      ),
    );
  }

  static bool isVerificationError(dynamic response) {
    if (response is Map) {
      return response['code'] == 'mobile_verification_required';
    }
    return false;
  }

  static String verificationErrorMessage(dynamic response) {
    if (response is Map && response['message'] != null) {
      return response['message'].toString();
    }
    return 'برای خرید باید ابتدا شماره موبایل خود را در ربات تلگرام تایید کنید.';
  }
}

class MobileVerificationBanner extends StatefulWidget {
  const MobileVerificationBanner({super.key, this.userRole = 'user'});

  final String userRole;

  @override
  State<MobileVerificationBanner> createState() =>
      _MobileVerificationBannerState();
}

class _MobileVerificationBannerState extends State<MobileVerificationBanner> {
  MobileVerificationStatus? _status;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.userRole != 'user') {
      if (mounted) {
        setState(() {
          _loading = false;
          _status = null;
        });
      }
      return;
    }

    final status = await MobileVerificationHelper.fetchStatus();
    if (!mounted) return;
    setState(() {
      _status = status;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _status == null || !_status!.needsAction) {
      return const SizedBox.shrink();
    }

    final bot = _status!.botUsername?.trim();
    final botUrl = bot != null && bot.isNotEmpty ? 'https://t.me/$bot' : null;

    return Container(
      margin: EdgeInsets.only(bottom: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.phone_android, color: Colors.orangeAccent),
          SizedBox(width: AppStyle.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _status!.iranOnly ? 'تایید موبایل (فقط ایران)' : 'تایید موبایل',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  _status!.message ??
                      'برای خرید از وب‌اپ، ابتدا در ربات تلگرام شماره تماس خود را ارسال کنید.',
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
          if (botUrl != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => launchUrl(
                Uri.parse(botUrl),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text('رفتن به ربات'),
            ),
          ],
        ],
      ),
    );
  }
}
