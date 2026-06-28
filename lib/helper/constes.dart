const String projectName = " Power Proxy Seller ";
const String projectVersion = "9.5.1";
const String projectDescription =
    "Best soloution for selling v2ray vpn by telegram with advanced tools";
const String appLink =
    "https://play.google.com/store/apps/details?id=com.vpn.seller";

bool isPlaceholderAppVersion(String? version) {
  final v = version?.trim().toLowerCase() ?? '';
  return v.isEmpty || v == '1.0.0' || v == '6.7.0' || v == 'unknown';
}

String resolveAppVersion(String? version) {
  if (isPlaceholderAppVersion(version)) return projectVersion;
  return version!.trim();
}
