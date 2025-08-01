import 'package:shared_preferences/shared_preferences.dart';

class OnboardingManager {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  // You can add other keys here for individual step data if you want to centralize them,
  // but for now, individual screens handle their own specific step data.

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the boolean value. If not found, default to false.
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  static Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    // Set the boolean value to true to mark onboarding as complete.
    await prefs.setBool(_onboardingCompleteKey, true);
  }

  // Optional: A method to reset onboarding status for testing
  static Future<void> resetOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompleteKey);
    // Also remove the current step from the flow manager if it exists
    await prefs.remove('onboarding_flow_current_step');
  }
}
