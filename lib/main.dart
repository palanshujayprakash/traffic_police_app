import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/localization/app_localization.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/mobile_device_frame.dart';
import 'presentation/screens/auth/inspector_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safely initialize Supabase if environment variables are configured
  if (AppConfig.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
    } catch (_) {
      // Continue in offline / mock mode
    }
  }

  runApp(const TrafficPoliceApp());
}

class TrafficPoliceApp extends StatelessWidget {
  final bool? enableMobileFrame;

  const TrafficPoliceApp({
    super.key,
    this.enableMobileFrame,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLocalizationService.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'app_title'.tr(fallback: 'Traffic Police Assistant'),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          builder: (context, child) {
            return MobileDeviceFrame(
              enableFrame: enableMobileFrame ?? kIsWeb,
              child: child ?? const SizedBox(),
            );
          },
          home: const InspectorLoginScreen(),
        );
      },
    );
  }
}
