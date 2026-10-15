import 'package:flutter/material.dart';

enum AppLanguage { english, hindi }

/// Lightweight localization dictionary and reactive language notifier for the Traffic Police Assistant.
class AppLocalizationService extends ChangeNotifier {
  static final AppLocalizationService instance = AppLocalizationService._internal();
  factory AppLocalizationService() => instance;
  AppLocalizationService._internal();

  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isHindi => _currentLanguage == AppLanguage.hindi;
  String get languageCode => _currentLanguage == AppLanguage.hindi ? 'hi' : 'en';

  void setLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    setLanguage(isHindi ? AppLanguage.english : AppLanguage.hindi);
  }

  static const Map<String, Map<AppLanguage, String>> _localizedValues = {
    // Navigation & Core App
    'app_title': {
      AppLanguage.english: 'Traffic Police Assistant',
      AppLanguage.hindi: 'ट्रैफिक पुलिस सहायक',
    },
    'home': {
      AppLanguage.english: 'Home',
      AppLanguage.hindi: 'होम',
    },
    'search': {
      AppLanguage.english: 'Search',
      AppLanguage.hindi: 'खोज',
    },
    'challan': {
      AppLanguage.english: 'Issue Challan',
      AppLanguage.hindi: 'चालान जारी करें',
    },
    'history': {
      AppLanguage.english: 'History',
      AppLanguage.hindi: 'इतिहास',
    },
    'profile': {
      AppLanguage.english: 'Profile',
      AppLanguage.hindi: 'प्रोफ़ाइल',
    },

    // VAHAN & Search
    'vahan_lookup': {
      AppLanguage.english: 'Instant VAHAN Lookup',
      AppLanguage.hindi: 'तुरंत वाहन खोज',
    },
    'registration_number': {
      AppLanguage.english: 'Registration Number',
      AppLanguage.hindi: 'पंजीकरण संख्या',
    },
    'chassis_number': {
      AppLanguage.english: 'Chassis Number',
      AppLanguage.hindi: 'चेसिस नंबर',
    },
    'engine_number': {
      AppLanguage.english: 'Engine Number',
      AppLanguage.hindi: 'इंजन नंबर',
    },
    'driver_license': {
      AppLanguage.english: 'Driver License',
      AppLanguage.hindi: 'ड्राइविंग लाइसेंस',
    },

    // Vehicle & Document Status
    'valid': {
      AppLanguage.english: 'VALID',
      AppLanguage.hindi: 'वैध',
    },
    'expiring': {
      AppLanguage.english: 'EXPIRING SOON',
      AppLanguage.hindi: 'जल्द समाप्त',
    },
    'expired': {
      AppLanguage.english: 'EXPIRED',
      AppLanguage.hindi: 'समाप्त',
    },
    'stolen_alert': {
      AppLanguage.english: 'STOLEN VEHICLE / BOLO ALERT!',
      AppLanguage.hindi: 'चोरी का वाहन / बोलो अलर्ट!',
    },
    'active': {
      AppLanguage.english: 'ACTIVE',
      AppLanguage.hindi: 'सक्रिय',
    },

    // ANPR OCR Scanner
    'anpr_scanner': {
      AppLanguage.english: 'ANPR Scanner',
      AppLanguage.hindi: 'एएनपीआर स्कैनर',
    },
    'plate_recognized': {
      AppLanguage.english: 'Plate Recognized',
      AppLanguage.hindi: 'नंबर प्लेट पहचानी गई',
    },
    'search_vahan': {
      AppLanguage.english: 'Search VAHAN',
      AppLanguage.hindi: 'वाहन खोजें',
    },
    'optical_confidence': {
      AppLanguage.english: 'Optical Confidence',
      AppLanguage.hindi: 'ऑप्टिकल सटीकता',
    },

    // Offline & Sync
    'offline_mode': {
      AppLanguage.english: 'Offline Mode Active',
      AppLanguage.hindi: 'ऑफ़लाइन मोड सक्रिय',
    },
    'sync_now': {
      AppLanguage.english: 'Sync Grid Records',
      AppLanguage.hindi: 'रिकॉर्ड सिंक करें',
    },
    'cached_hashes': {
      AppLanguage.english: 'Offline VAHAN Database',
      AppLanguage.hindi: 'ऑफ़लाइन वाहन डेटाबेस',
    },

    // Admin & HQ Command
    'admin_command': {
      AppLanguage.english: 'Command HQ Admin Panel',
      AppLanguage.hindi: 'मुख्यालय कमांड एडमिन पैनल',
    },
    'inspector_fleet': {
      AppLanguage.english: 'Inspector Fleet & Whitelist',
      AppLanguage.hindi: 'निरीक्षक सूची और श्वेतसूची',
    },
    'broadcast_alert': {
      AppLanguage.english: 'Broadcast Alert',
      AppLanguage.hindi: 'अलर्ट प्रसारित करें',
    },
  };

  /// Translates a key to the active language
  String tr(String key, {String? fallback}) {
    final entry = _localizedValues[key];
    if (entry != null) {
      return entry[_currentLanguage] ?? entry[AppLanguage.english] ?? fallback ?? key;
    }
    return fallback ?? key;
  }
}

/// Shorthand extension for easy translation lookups: `'home'.tr()`
extension AppLocalizationExtension on String {
  String tr({String? fallback}) => AppLocalizationService.instance.tr(this, fallback: fallback);
}
