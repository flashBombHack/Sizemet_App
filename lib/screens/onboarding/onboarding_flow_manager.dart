import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/onboarding_manager.dart';
import 'onboarding_welcome_screen.dart';
import 'onboarding_measurement_screen.dart';
import 'onboarding_result_screen.dart';
// Import the new onboarding step screens
import 'package:sizemet/screens/onboarding_steps/gender_selection_screen.dart';
import 'package:sizemet/screens/onboarding_steps/clothing_guidelines_screen.dart';
import 'package:sizemet/screens/onboarding_steps/color_guidelines_screen.dart';
import 'package:sizemet/screens/onboarding_steps/lighting_guidelines_screen.dart';
import 'package:sizemet/screens/onboarding_steps/scanning_method_screen.dart';


class OnboardingFlowManager extends StatefulWidget {
  const OnboardingFlowManager({super.key});

  @override
  State<OnboardingFlowManager> createState() => _OnboardingFlowManagerState();
}

class _OnboardingFlowManagerState extends State<OnboardingFlowManager> {
  int _onboardingStep = 0;
  // The total number of screens in the full onboarding flow (8)
  final int _totalOnboardingSteps = 8;
  // The total number of steps for the progress tracker (4)
  final int _totalTrackingSteps = 4;

  @override
  void initState() {
    super.initState();
    _loadCurrentStep(); // Load the current step when the manager initializes
  }

  Future<void> _loadCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    // Use a specific key for the onboarding flow manager's step
    final savedStep = prefs.getInt('onboarding_flow_current_step');
    if (savedStep != null && savedStep < _totalOnboardingSteps) {
      setState(() {
        _onboardingStep = savedStep;
      });
    }
  }

  Future<void> _saveCurrentStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onboarding_flow_current_step', step);
  }

  void _nextOnboardingStep() {
    setState(() {
      if (_onboardingStep < _totalOnboardingSteps - 1) {
        _onboardingStep++;
        _saveCurrentStep(_onboardingStep); // Save the new step
      }
    });
  }

  void _previousOnboardingStep() {
    setState(() {
      if (_onboardingStep > 0) {
        _onboardingStep--;
        _saveCurrentStep(_onboardingStep); // Save the new step
      }
    });
  }

  void _finishOnboarding() async {
    await OnboardingManager.setOnboardingComplete();
    // Clear the current step in shared preferences as onboarding is complete
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_flow_current_step');

    if (mounted) {
      // After onboarding is complete, navigate to the main app's home route.
      // This will replace the onboarding stack.
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_onboardingStep) {
      case 0:
        currentScreen = OnboardingWelcomeScreen(onNext: _nextOnboardingStep);
        break;
      case 1:
        currentScreen = OnboardingMeasurementScreen(onNext: _nextOnboardingStep);
        break;
      case 2:
        currentScreen = OnboardingResultScreen(
          onSignUp: () {
            // Navigate to signup screen, then on successful signup, finish onboarding
            Navigator.pushNamed(context, '/signup');
          },
          onSignIn: () {
            // Navigate to signin screen, then on successful signin, finish onboarding
            Navigator.pushNamed(context, '/signin');
          },
        );
        break;
      case 3:
      // Gender selection is a prerequisite but not part of the tracked steps.
      // We'll pass the total tracking steps so the screen can decide what to show
      // but the current step will be 0.
        currentScreen = GenderSelectionScreen(
          onNext: _nextOnboardingStep,
          // Pass 0 to indicate this step is not part of the progress bar
          currentStep: 0,
          totalSteps: _totalTrackingSteps,
        );
        break;
      case 4:
      // The tracker starts here. This is step 1 of 4.
        currentScreen = ClothingGuidelinesScreen(
          onNext: _nextOnboardingStep,
          currentStep: 1,
          totalSteps: _totalTrackingSteps,
        );
        break;
      case 5:
      // This is step 2 of 4.
        currentScreen = ColorGuidelinesScreen(
          onNext: _nextOnboardingStep,
          currentStep: 2,
          totalSteps: _totalTrackingSteps,
        );
        break;
      case 6:
      // This is step 3 of 4.
        currentScreen = LightingGuidelinesScreen(
          onNext: _nextOnboardingStep,
          currentStep: 3,
          totalSteps: _totalTrackingSteps,
        );
        break;
      case 7:
      // This is the final step, step 4 of 4.
        currentScreen = ScanningMethodScreen(
          onProceed: _finishOnboarding, // Final step, proceeds to home
          currentStep: 4,
          totalSteps: _totalTrackingSteps,
        );
        break;
      default:
      // If somehow _onboardingStep goes out of bounds, reset or navigate to home
        currentScreen = OnboardingWelcomeScreen(onNext: _nextOnboardingStep);
        break;
    }

    // Wrap the current screen in a PopScope to handle back navigation and update step
    return PopScope(
      canPop: _onboardingStep == 0, // Allow popping only from the very first step
      onPopInvoked: (didPop) {
        if (!didPop) { // If pop was not handled by system (e.g., canPop was false)
          _previousOnboardingStep(); // Manually go back a step
        }
      },
      child: currentScreen,
    );
  }
}
