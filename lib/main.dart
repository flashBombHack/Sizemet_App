// main.dart
import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'navigation/app_router.dart';
import 'utils/onboarding_manager.dart';
import 'screens/onboarding/onboarding_welcome_screen.dart';
import 'screens/onboarding/onboarding_measurement_screen.dart';
import 'screens/onboarding/onboarding_result_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Body Scanner App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const _RootNavigator(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

class _RootNavigator extends StatefulWidget {
  const _RootNavigator();
  @override
  State<_RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<_RootNavigator> {
  late Future<bool> _onboardingCompleteFuture;
  int _onboardingStep = 0;

  @override
  void initState() {
    super.initState();
    _onboardingCompleteFuture = OnboardingManager.isOnboardingComplete();
  }

  void _nextOnboardingStep() {
    setState(() {
      _onboardingStep++;
    });
  }

  void _finishOnboarding() async {
    await OnboardingManager.setOnboardingComplete();
    if (mounted) {
      setState(() {}); // Triggers rebuild to show main app
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _onboardingCompleteFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final onboardingComplete = snapshot.data!;
        if (onboardingComplete) {
          // Show main app (splash, then main flow)
          return Navigator(
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: '/',
          );
        } else {
          // Show onboarding flow
          switch (_onboardingStep) {
            case 0:
              return OnboardingWelcomeScreen(onNext: _nextOnboardingStep);
            case 1:
              return OnboardingMeasurementScreen(onNext: _nextOnboardingStep);
            case 2:
              return OnboardingResultScreen(
                onSignUp: _finishOnboarding,
                onSignIn: _finishOnboarding,
              );
            default:
              return Navigator(
                onGenerateRoute: AppRouter.generateRoute,
                initialRoute: '/',
              );
          }
        }
      },
    );
  }
}