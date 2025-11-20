import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/colors.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/chat/providers/chat_provider.dart';
import 'features/matching/providers/matching_provider.dart';
import 'features/matching/providers/matching_filter_provider.dart';
import 'features/trust_score/providers/trust_score_provider.dart';
import 'features/heart_temperature/providers/heart_temperature_provider.dart';
import 'features/avatar/providers/avatar_provider.dart';
import 'features/subscription/providers/subscription_provider.dart';
import 'features/safety/providers/safety_provider.dart';
import 'features/item_shop/providers/item_shop_provider.dart';
import 'features/verification/providers/verification_provider.dart';
import 'features/notification/providers/notification_settings_provider.dart';
import 'features/profile_photo/providers/profile_photo_provider.dart';
import 'features/mission/providers/daily_mission_provider.dart';
import 'features/referral/providers/referral_provider.dart';
import 'features/gacha/providers/gacha_provider.dart';
import 'features/onboarding/providers/daily_question_provider.dart';
import 'features/chat/providers/chat_intimacy_provider.dart';
import 'features/streak/providers/streak_provider.dart';
import 'features/popularity/providers/popularity_provider.dart';
import 'features/auth/screens/auth_wrapper.dart';
import 'features/main/screens/main_screen.dart';
import 'features/profile/screens/profile_setup_screen.dart';
import 'features/onboarding/screens/daily_mission_screen.dart';
import 'features/onboarding/screens/initial_onboarding_screen.dart';
import 'features/referral/screens/referral_screen.dart';
import 'features/referral/screens/referral_dashboard_screen.dart';
import 'features/gacha/screens/daily_attendance_screen.dart';
import 'features/gacha/screens/gacha_hub_screen.dart';

class MannaBollaeApp extends StatelessWidget {
  const MannaBollaeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => MatchingProvider()),
        ChangeNotifierProvider(create: (_) => MatchingFilterProvider()),
        ChangeNotifierProvider(create: (_) => TrustScoreProvider()),
        ChangeNotifierProvider(create: (_) => HeartTemperatureProvider()),
        ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => SafetyProvider()),
        ChangeNotifierProvider(create: (_) => ItemShopProvider()),
        ChangeNotifierProvider(create: (_) => VerificationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationSettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProfilePhotoProvider()),
        ChangeNotifierProvider(create: (_) => DailyMissionProvider()),
        ChangeNotifierProvider(create: (_) => ReferralProvider()),
        ChangeNotifierProvider(create: (_) => GachaProvider()),
        ChangeNotifierProvider(create: (_) => DailyQuestionProvider()),
        ChangeNotifierProvider(create: (_) => ChatIntimacyProvider()),
        ChangeNotifierProvider(create: (_) => StreakProvider()),
        ChangeNotifierProvider(create: (_) => PopularityProvider()),
        // More providers will be added here
      ],
      child: MaterialApp(
        title: '만나볼래',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const AuthWrapper(),
        routes: {
          '/home': (context) => const MainScreen(),
          '/profile-setup': (context) => const ProfileSetupScreen(),
          '/initial-onboarding': (context) => const InitialOnboardingScreen(),
          '/daily-mission': (context) => const DailyMissionScreen(),
          '/referral': (context) => const ReferralScreen(),
          '/referral-dashboard': (context) => const ReferralDashboardScreen(),
          '/daily-attendance': (context) => const DailyAttendanceScreen(),
          '/gacha-hub': (context) => const GachaHubScreen(),
        },
      ),
    );
  }
}
