import 'package:flutter/material.dart';
import '../utils/onboarding_manager.dart'; // Import OnboardingManager

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for fade-in effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Fade-in duration
    );

    // Define the fade animation
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn, // Smooth ease-in curve
    );

    // Start the fade-in animation
    _animationController.forward();

    // Navigate to the next screen after the total splash duration
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Wait for the total splash screen duration (5 seconds)
    await Future.delayed(const Duration(seconds: 5));

    // Check onboarding status
    final onboardingComplete = await OnboardingManager.isOnboardingComplete();

    if (mounted) {
      if (onboardingComplete) {
        // If onboarding is complete, navigate to the main app's home route
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        // If onboarding is not complete, navigate to the onboarding flow
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose the controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Apply FadeTransition to the logo
            FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 180, // Increased size
                height: 180, // Increased size
                // No placeholderBuilder needed for Image.asset as it handles errors natively
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 180, color: Colors.red); // Show error icon if image fails
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
