import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/onboarding_progress_bar.dart';
import 'positioning_guidance_screen.dart'; // Import the new screen

class ScanningMethodScreen extends StatefulWidget {
  final VoidCallback onProceed;
  final int currentStep;
  final int totalSteps;

  const ScanningMethodScreen({
    super.key,
    required this.onProceed,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  State<ScanningMethodScreen> createState() => _ScanningMethodScreenState();
}

class _ScanningMethodScreenState extends State<ScanningMethodScreen> {
  String? _selectedMethod;
  static const String _prefKey = 'onboarding_scanning_method';

  @override
  void initState() {
    super.initState();
    _loadSelectedMethod();
  }

  Future<void> _loadSelectedMethod() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedMethod = prefs.getString(_prefKey);
    });
  }

  Future<void> _saveSelectedMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, method);
  }

  void _handleMethodSelection(String method) {
    setState(() {
      _selectedMethod = method;
    });
    _saveSelectedMethod(method);
  }

  // New navigation function to proceed to the next screen
  void _navigateToNextScreen() {
    if (_selectedMethod != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PositioningGuidanceScreen(
            onProceed: widget.onProceed,
            currentStep: widget.currentStep + 1, // Move to the next step
            totalSteps: widget.totalSteps,
            selectedMethod: _selectedMethod!, // Pass the selected method
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canProceed = _selectedMethod != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Scanning Method',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick the method that works best for your situation.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              OnboardingProgressBar(
                currentStep: widget.currentStep,
                totalSteps: widget.totalSteps,
              ),
              const SizedBox(height: 30),
              _buildMethodOption(
                context,
                'Handheld Scanning',
                'Have someone help you hold your phone.',
                'assets/images/onboarding_steps/male_icon.svg',
                'handheld',
              ),
              const SizedBox(height: 16),
              _buildMethodOption(
                context,
                'Tripod/Stand Setup',
                'Place phone on a tripod or stable surface.',
                'assets/images/onboarding_steps/male_icon.svg',
                'tripod',
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canProceed ? _navigateToNextScreen : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2323FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: GoogleFonts.nunitoSans(fontSize: 18, fontWeight: FontWeight.w600),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Proceed'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodOption(
      BuildContext context, String title, String subtitle, String iconPath, String value) {
    final bool isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => _handleMethodSelection(value),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2323FF).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2323FF) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            SvgPicture.asset(
              iconPath,
              width: 80,
              height: 80,
              colorFilter: ColorFilter.mode(
                isSelected ? const Color(0xFF2323FF) : Colors.black87,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF2323FF) : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                color: isSelected ? const Color(0xFF2323FF) : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
