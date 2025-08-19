import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/onboarding_progress_bar.dart'; // Import the progress bar

class GenderSelectionScreen extends StatefulWidget {
  final VoidCallback onNext;
  final int currentStep;
  final int totalSteps;

  const GenderSelectionScreen({
    super.key,
    required this.onNext,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender; // Nullable to indicate no selection initially

  @override
  void initState() {
    super.initState();
    _loadSelectedGender();
  }

  Future<void> _loadSelectedGender() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedGender = prefs.getString('onboarding_gender');
    });
  }

  Future<void> _saveSelectedGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboarding_gender', gender);
  }

  void _handleGenderSelection(String gender) {
    setState(() {
      _selectedGender = gender;
    });
    _saveSelectedGender(gender); // Save immediately on selection
  }

  @override
  Widget build(BuildContext context) {
    final bool canProceed = _selectedGender != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFD),
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 0),
                  Text(
                    'Select your gender',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Reduced from 32
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildGenderOption(
                      context,
                      'Male',
                      'assets/images/onboarding_steps/male_icon.svg',
                      'male',
                    ),
                    const SizedBox(height: 16), // Reduced spacing
                    _buildGenderOption(
                      context,
                      'Female',
                      'assets/images/onboarding_steps/female_icon.svg',
                      'female',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Reduced vertical padding
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canProceed ? widget.onNext : null, // Disable if no selection
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2323FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: GoogleFonts.nunitoSans(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(BuildContext context, String title, String iconPath, String value) {
    final bool isSelected = _selectedGender == value;
    return Flexible( // Changed from Expanded to Flexible
      child: GestureDetector(
        onTap: () => _handleGenderSelection(value),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), // Reduced margins
          padding: const EdgeInsets.symmetric(vertical: 16), // Reduced padding
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 80, // Reduced icon size
                height: 80,
                colorFilter: ColorFilter.mode(
                  isSelected ? const Color(0xFF2323FF) : const Color(0xFF374151),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 12), // Reduced spacing
              Text(
                title,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16, // Reduced font size
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF2323FF) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
