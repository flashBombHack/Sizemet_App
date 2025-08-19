import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingResultScreen extends StatelessWidget {
  final VoidCallback onSignUp; // This callback is now unused directly, but kept for signature
  final VoidCallback onSignIn; // This callback is now unused directly, but kept for signature
  const OnboardingResultScreen({super.key, required this.onSignUp, required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD), // Updated background color
      body: Column(
        children: [
          Expanded(
            child: SvgPicture.asset(
              'assets/images/size_result_card.svg',
              fit: BoxFit.fitWidth,
              width: double.infinity,
              height: double.infinity,
              placeholderBuilder: (BuildContext context) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Flexible(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.nunitoSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(text: 'Welcome To '),
                          TextSpan(
                            text: 'Sizemet',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              foreground: Paint()..shader = const LinearGradient(
                                colors: <Color>[
                                  Color(0xFF2323FF),
                                  Color(0xFF151599),
                                ],
                              ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: Text(
                      'Your one-stop solution for finding your perfect fit, shop smarter, look better, feel confident.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Changed to pushNamed to allow back navigation
                        Navigator.pushNamed(context, '/signup');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2323FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        textStyle: GoogleFonts.nunitoSans(fontSize: 18, fontWeight: FontWeight.w600),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Sign up'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Changed to pushNamed to allow back navigation
                        Navigator.pushNamed(context, '/signin');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2323FF),
                        side: const BorderSide(color: Color(0xFF2323FF), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        textStyle: GoogleFonts.nunitoSans(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Sign in'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
