import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding/onboarding_flow_manager.dart';
import '../screens/lidar_scanner_screen.dart';
import '../screens/results_screen.dart';
import '../screens/auth/sign_up_screen.dart'; // Correct import for SignUpScreen
import '../screens/auth/sign_in_screen.dart'; // Correct import for SignInScreen

// Placeholder for your main app's home screen
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: const Center(
        child: Text('Welcome to the main app!'),
      ),
    );
  }
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget Function(BuildContext, Animation<double>, Animation<double>) pageBuilder;

    switch (settings.name) {
      case '/':
        pageBuilder = (_, __, ___) => const SplashScreen();
        break;
      case '/onboarding':
        pageBuilder = (_, __, ___) => const OnboardingFlowManager();
        break;
      case '/lidar':
        pageBuilder = (_, __, ___) => const LidarScannerScreen();
        break;
      case '/results':
        pageBuilder = (_, __, ___) => const ResultsScreen();
        break;
      case '/signup': // Route for Sign Up
        pageBuilder = (_, __, ___) => SignUpScreen(
          onSignInClicked: () {
            // Use pushReplacementNamed to navigate to sign-in and replace current route
            Navigator.pushReplacementNamed(_, '/signin');
          },
        );
        break;
      case '/signin': // Route for Sign In
        pageBuilder = (_, __, ___) => SignInScreen(
          onSignUpClicked: () {
            // Use pushReplacementNamed to navigate to sign-up and replace current route
            Navigator.pushReplacementNamed(_, '/signup');
          },
        );
        break;
      case '/home':
        pageBuilder = (_, __, ___) => const PlaceholderHomeScreen();
        break;
      default:
        pageBuilder = (_, __, ___) => Scaffold(
          body: Center(child: Text('No route defined for [${settings.name}]')),
        );
        break;
    }

    return PageRouteBuilder(
      pageBuilder: pageBuilder,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      settings: settings,
    );
  }
}
