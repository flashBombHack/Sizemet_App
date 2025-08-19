import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/onboarding_progress_bar.dart';

class ColorGuidelinesScreen extends StatefulWidget {
  final VoidCallback onNext;
  final int currentStep;
  final int totalSteps;

  const ColorGuidelinesScreen({
    super.key,
    required this.onNext,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  State<ColorGuidelinesScreen> createState() => _ColorGuidelinesScreenState();
}

class _ColorGuidelinesScreenState extends State<ColorGuidelinesScreen> {
  bool _guidelinesConfirmed = false;
  static const String _prefKey = 'onboarding_color_guidelines_confirmed';

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
        backgroundColor: Colors.transparent, // Making the AppBar transparent
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
              const SizedBox(height: 16),
              OnboardingProgressBar(
                currentStep: widget.currentStep,
                totalSteps: widget.totalSteps,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/onboarding_steps/audio_icon.svg', // Assuming this asset exists
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
              Flexible(
                child: Text(
                  'Clothing should be solid colors',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildImageGrid(
                        'assets/images/onboarding_steps/clothing_solid_male.png',
                        'assets/images/onboarding_steps/clothing_solid_female.png',
                        'assets/images/onboarding_steps/clothing_pattern_male.png',
                        'assets/images/onboarding_steps/clothing_pattern_female.png',
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
            aspectRatio: 0.75, // Adjust this to change the size
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
