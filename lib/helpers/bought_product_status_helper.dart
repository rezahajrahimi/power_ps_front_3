import 'package:powerps/models/hiffify_config_model.dart';
import 'package:powerps/models/marzban_config_model.dart';
import 'package:powerps/models/sanaei_config_model.dart';

bool boughtProductStatusIsActive(dynamic config) {
  if (config is HiddifyConfig) {
    return config.isActive;
  }
  if (config is SanaeiConfig) {
    return config.enable;
  }
  if (config is MarzbanConfig) {
    switch (config.status?.toLowerCase()) {
      case 'active':
        return true;
      case 'disabled':
        return false;
      default:
        return false;
    }
  }
  return false;
}

double boughtProductStatusCurrentUsageGB(dynamic config) {
  if (config is HiddifyConfig) {
    return config.currentUsageGB;
  }
  if (config is SanaeiConfig) {
    return config.currentUsageGB;
  }
  if (config is MarzbanConfig) {
    return config.usedTraffic / 1024 / 1024 / 1024;
  }
  return 0;
}

double boughtProductStatusUsageLimitGB(dynamic config) {
  if (config is HiddifyConfig) {
    return config.usageLimitGB;
  }
  if (config is SanaeiConfig) {
    return config.usageLimitGB;
  }
  if (config is MarzbanConfig) {
    if (config.dataLimit <= 0) {
      return 0;
    }
    return config.dataLimit / 1024 / 1024 / 1024;
  }
  return 0;
}

String boughtProductStatusUsageLabel(dynamic config) {
  final used = boughtProductStatusCurrentUsageGB(config);
  final limit = boughtProductStatusUsageLimitGB(config);
  if (config is MarzbanConfig && limit <= 0) {
    return '${used.toStringAsFixed(2)} / نامحدود GB';
  }
  return '${used.toStringAsFixed(2)} / ${limit.toStringAsFixed(2)} GB';
}

String boughtProductStatusRemindText(dynamic config) {
  if (config is MarzbanConfig) {
    if (config.expire.millisecondsSinceEpoch <= 0 || config.expire.year <= 1970) {
      return 'نامحدود';
    }
    final diff = config.expire.difference(DateTime.now());
    if (diff.isNegative) {
      return 'منقضی شده';
    }
    if (diff.inDays < 1) {
      if (diff.inHours > 0) {
        return '${diff.inHours} ساعت دیگر';
      }
      return 'کمتر از یک ساعت';
    }
    return '${diff.inDays} روز دیگر';
  }

  try {
    if (config.startDate != null &&
        config.startDate != 'null' &&
        config.startDate.toString().isNotEmpty) {
      final expireDate = DateTime.parse(config.startDate.toString())
          .add(Duration(days: config.packageDays as int));
      final diff = expireDate.difference(DateTime.now());
      if (diff.inDays < 1) {
        if (diff.inHours > 0) {
          return '${diff.inHours} ساعت دیگر';
        }
        return 'منقضی شده';
      }
      return '${diff.inDays} روز دیگر';
    }
    return '${config.packageDays} روز دیگر';
  } catch (_) {
    return '${config.packageDays} روز دیگر';
  }
}

String boughtProductStatusLabel(dynamic config) {
  return boughtProductStatusIsActive(config) ? 'فعال' : 'غیر فعال';
}

String? boughtProductStatusLastOnlineText(dynamic config) {
  if (config is HiddifyConfig &&
      config.lastOnline != null &&
      config.lastOnline.toString() != '0001-01-01 00:00:00' &&
      !config.lastOnline!.contains('1-01-01')) {
    final diff =
        DateTime.now().difference(DateTime.parse(config.lastOnline!)).abs();
    if (diff.inSeconds < 60) {
      return 'هم اکنون';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} دقیقه پیش';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} ساعت پیش';
    }
    return config.lastOnline;
  }

  if (config is MarzbanConfig) {
    final onlineAt = config.onlineAt?.trim();
    if (onlineAt == null ||
        onlineAt.isEmpty ||
        onlineAt.contains('0001-01-01') ||
        onlineAt.contains('1-01-01')) {
      return null;
    }
    final parsed = DateTime.tryParse(onlineAt);
    if (parsed == null) {
      return onlineAt;
    }
    final diff = DateTime.now().difference(parsed).abs();
    if (diff.inSeconds < 60) {
      return 'هم اکنون';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} دقیقه پیش';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} ساعت پیش';
    }
    return onlineAt;
  }

  return null;
}

String? boughtProductStatusSubtitle(dynamic config) {
  if (config is SanaeiConfig && config.client?['email'] != null) {
    return 'ایمیل: ${config.client!['email']}';
  }
  if (config is MarzbanConfig) {
    final username = config.username?.trim();
    if (username != null && username.isNotEmpty) {
      return 'نام کاربری: $username';
    }
  }
  return null;
}

bool boughtProductSupportsActivationToggle(String? panelType) {
  return panelType == 'hiddify' ||
      panelType == 'sanaei' ||
      panelType == 'marzban' ||
      panelType == 'pasarguard';
}
