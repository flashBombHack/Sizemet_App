class OnboardingManager {
  static bool _onboardingComplete = false;

  static Future<bool> isOnboardingComplete() async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 100));
    return _onboardingComplete;
  }

  static Future<void> setOnboardingComplete() async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 100));
    _onboardingComplete = true;
  }
} 