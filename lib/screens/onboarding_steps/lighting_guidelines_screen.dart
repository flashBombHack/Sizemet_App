import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/onboarding_progress_bar.dart';

class LightingGuidelinesScreen extends StatefulWidget {
  final VoidCallback onNext;
  final int currentStep;
  final int totalSteps;

  const LightingGuidelinesScreen({
    super.key,
    required this.onNext,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  State<LightingGuidelinesScreen> createState() => _LightingGuidelinesScreenState();
}

class _LightingGuidelinesScreenState extends State<LightingGuidelinesScreen> {
  bool _guidelinesConfirmed = false;
  static const String _prefKey = 'onboarding_lighting_guidelines_confirmed';

  @override
  void initState() {
    super.initState();
    _loadConfirmationStatus();
  }

  Future<void> _loadConfirmationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _guidelinesConfirmed = prefs.getBool(_prefKey) ?? false;
    });
  }

  Future<void> _saveConfirmationStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Text(
                'Measurement Guidelines',
                style: GoogleFonts.nunitoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please ensure to follow the below requirements',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              OnboardingProgressBar(
                currentStep: widget.currentStep,
                totalSteps: widget.totalSteps,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/onboarding_steps/audio_icon.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(Color(0xFF2323FF), BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Audio guidance: Ensure your volume is turned up.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Ensure proper lighting with no shadows',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Using the new helper function for the image grid
                      _buildImageGrid(
                        'assets/images/onboarding_steps/lighting_bright.png',
                        'assets/images/onboarding_steps/lighting_shadows.png',
                        'assets/images/onboarding_steps/lighting_good.png',
                        'assets/images/onboarding_steps/lighting_fair.png',
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _guidelinesConfirmed,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _guidelinesConfirmed = newValue ?? false;
                            });
                            _saveConfirmationStatus(newValue ?? false);
                          },
                          activeColor: const Color(0xFF2323FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Please confirm all guidelines before proceeding',
                            style: GoogleFonts.nunitoSans(fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guidelinesConfirmed ? widget.onNext : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2323FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: GoogleFonts.nunitoSans(fontSize: 18, fontWeight: FontWeight.w600),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build the 2x2 image grid
  Widget _buildImageGrid(String image1, String image2, String image3, String image4) {
    return Column(
      children: [
        Row(
          children: [
            _buildImageExample(image1),
            _buildImageExample(image2),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildImageExample(image3),
            _buildImageExample(image4),
          ],
        ),
      ],
    );
  }

  // Helper widget for a single image with responsive aspect ratio
  Widget _buildImageExample(String imagePath) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 0.8,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
