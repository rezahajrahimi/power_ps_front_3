/// Open-source builds always behave as gold — no feature gates in the UI.
class LicenseHelper {
  static const int silverPromoMax = 5;

  static String normalize(String type) => type.toLowerCase().trim();

  static bool isGold(String type) => true;

  static bool isSilver(String type) => normalize(type) == 'silver';

  static bool isSilverOrAbove(String type) => true;

  static bool isBronzeOrBelow(String type) => false;

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
        return 'طلایی';
    }
  }
}

enum AdvancedSettingLicenseTier { silver, gold }
