import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/onboarding_progress_bar.dart';

class ClothingGuidelinesScreen extends StatefulWidget {
  final VoidCallback onNext;
  final int currentStep;
  final int totalSteps;

  const ClothingGuidelinesScreen({
    super.key,
    required this.onNext,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  State<ClothingGuidelinesScreen> createState() => _ClothingGuidelinesScreenState();
}

class _ClothingGuidelinesScreenState extends State<ClothingGuidelinesScreen> {
  bool _guidelinesConfirmed = false;
  static const String _prefKey = 'onboarding_clothing_guidelines_confirmed';

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
              Flexible(
                child: Text(
                  'Measurement Guidelines',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  'Please ensure to follow the below requirements',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 5),
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
                  Flexible(
                    child: Text(
                      'Audio guidance: Ensure your volume is turned up.',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Moved this text to be part of the main column and not the SingleChildScrollView
              Flexible(
                child: Text(
                  'Wear fitted clothing (not loose or baggy!)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Re-factored the image examples into a single container for better layout control
                      // and to match the Figma design's spacing and relative sizes.
                      _buildImageGrid(
                        'assets/images/onboarding_steps/clothing_fitted_male.png',
                        'assets/images/onboarding_steps/clothing_fitted_female.png',
                        'assets/images/onboarding_steps/clothing_baggy_male.png',
                        'assets/images/onboarding_steps/clothing_baggy_female.png',
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

  // A new widget to build the 2x2 image grid
  Widget _buildImageGrid(String image1, String image2, String image3, String image4) {
    return Column(
      children: [
        Row(
          children: [
            _buildImageExample(image1),
            _buildImageExample(image3),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildImageExample(image2),
            _buildImageExample(image4),
          ],
        ),
      ],
    );
  }

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
            aspectRatio: 0.75, // This is key to making the images relative and square
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
