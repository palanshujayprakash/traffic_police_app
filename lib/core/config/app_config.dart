/// Application Configuration
/// Handles environment-driven variables securely without hardcoded credentials.
class AppConfig {
  AppConfig._();

  /// Supabase project URL loaded via:
  /// flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase anon public key loaded via:
  /// flutter run --dart-define=SUPABASE_ANON_KEY=your-anon-key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Check if live Supabase cloud backend is configured
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Default OTP Expiry Duration: 5 minutes
  static const Duration otpExpiryDuration = Duration(minutes: 5);

  /// Maximum allowed invalid OTP attempts before security lockout
  static const int maxOtpAttempts = 3;

  /// Lockout duration after 3 failed attempts: 15 minutes
  static const Duration lockoutDuration = Duration(minutes: 15);
}
