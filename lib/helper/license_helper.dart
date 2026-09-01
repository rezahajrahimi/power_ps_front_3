class LicenseHelper {
  static const int silverPromoMax = 5;

  static String normalize(String type) => type.toLowerCase().trim();

  static bool isGold(String type) => normalize(type) == 'gold';

  static bool isSilver(String type) => normalize(type) == 'silver';

  static bool isSilverOrAbove(String type) {
    final t = normalize(type);
    return t == 'silver' || t == 'gold';
  }

  static bool isBronzeOrBelow(String type) {
    return [
      'false',
      'trial',
      'boronze',
      'bronze',
      'free',
    ].contains(normalize(type));
  }

  static String displayName(String type) {
    switch (normalize(type)) {
      case 'gold':
        return 'طلایی';
      case 'silver':
        return 'نقره‌ای';
      case 'boronze':
      case 'bronze':
      case 'free':
        return 'برنز';
      case 'trial':
        return 'آزمایشی';
      default:
        return 'آزمایشی';
    }
  }
}

enum AdvancedSettingLicenseTier { silver, gold }
