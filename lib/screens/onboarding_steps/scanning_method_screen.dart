import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/onboarding_progress_bar.dart';

class ScanningMethodScreen extends StatefulWidget {
  final VoidCallback onProceed; // Changed to onProceed as it's the last step
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
  String? _selectedMethod; // Nullable to indicate no selection initially
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
    _saveSelectedMethod(method); // Save immediately on selection
  }

  @override
  Widget build(BuildContext context) {
    final bool canProceed = _selectedMethod != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            OnboardingProgressBar(
              currentStep: widget.currentStep,
              totalSteps: widget.totalSteps,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Scanning Method',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pick the method that works best for your situation.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Column(
                children: [
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canProceed ? widget.onProceed : null, // Disable if no selection
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
    );
  }

  Widget _buildMethodOption(
      BuildContext context, String title, String subtitle, String iconPath, String value) {
    final bool isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => _handleMethodSelection(value),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2323FF).withOpacity(0.1) : Colors.white,
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
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 40,
              height: 40,
              colorFilter: ColorFilter.mode(
                isSelected ? const Color(0xFF2323FF) : Colors.black87,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF2323FF) : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2323FF),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
