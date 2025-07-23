import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_start_screen.dart';
import '../screens/lidar_scanner_screen.dart';
import '../screens/results_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingStartScreen());
      case '/lidar':
        return MaterialPageRoute(builder: (_) => const LidarScannerScreen());
      case '/results':
        return MaterialPageRoute(builder: (_) => const ResultsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for  [${settings.name}')),
          ),
        );
    }
  }
} 