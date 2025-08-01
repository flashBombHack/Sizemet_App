import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Commented out for mock
// import 'package:google_sign_in/google_sign_in.dart'; // Commented out for mock
import 'package:flutter/gestures.dart'; // Import for TapGestureRecognizer
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../../utils/onboarding_manager.dart'; // Import OnboardingManager

class SignInScreen extends StatefulWidget {
  final VoidCallback onSignUpClicked;
  const SignInScreen({super.key, required this.onSignUpClicked});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  // final FirebaseAuth _auth = FirebaseAuth.instance; // Commented out for mock
  // final GoogleSignIn _googleSignIn = GoogleSignIn(); // Commented out for mock

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    // For a real app, you'd add validation here
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage(context, 'Please enter email and password.');
      return;
    }

    // Simulate API call and success
    _showMessage(context, 'Signing in...');
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    if (mounted) {
      // Mark initial onboarding as complete
      await OnboardingManager.setOnboardingComplete();
      // Set the current step in OnboardingFlowManager to the first of the new steps (Gender Selection)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('onboarding_flow_current_step', 3); // Step 3 for GenderSelectionScreen

      // Navigate to the onboarding flow, which will now start from step 3
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }

    /* Original Firebase Auth code (commented out for mock)
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _showMessage(context, 'Sign In Successful!');
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      _showMessage(context, 'Failed to sign in: ${e.message}');
    } catch (e) {
      _showMessage(context, 'An unexpected error occurred: $e');
    }
    */
  }

  Future<void> _signInWithGoogle() async {
    // Simulate API call and success
    _showMessage(context, 'Signing in with Google...');
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    if (mounted) {
      // Mark initial onboarding as complete
      await OnboardingManager.setOnboardingComplete();
      // Set the current step in OnboardingFlowManager to the first of the new steps (Gender Selection)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('onboarding_flow_current_step', 3); // Step 3 for GenderSelectionScreen

      // Navigate to the onboarding flow, which will now start from step 3
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }

    /* Original Firebase Auth code (commented out for mock)
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      _showMessage(context, 'Signed in with Google successfully!');
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      _showMessage(context, 'Failed to sign in with Google: ${e.message}');
    } catch (e) {
      _showMessage(context, 'An unexpected error occurred: $e');
    }
    */
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        color: const Color(0xFFFBFBFD),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/app_logo.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome Back',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Glad to have you back!',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.0), // Added gray border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.0), // Added gray border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2323FF), width: 2.0), // Focused border
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  style: GoogleFonts.nunitoSans(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.0), // Added gray border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.0), // Added gray border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2323FF), width: 2.0), // Focused border
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  style: GoogleFonts.nunitoSans(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _rememberMe = newValue ?? false;
                            });
                          },
                          activeColor: const Color(0xFF2323FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Text(
                          'Remember me',
                          style: GoogleFonts.nunitoSans(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password logic
                        _showMessage(context, 'Forgot password clicked!');
                      },
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2323FF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signInWithEmailAndPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2323FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: GoogleFonts.nunitoSans(fontSize: 18, fontWeight: FontWeight.w600),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sign in'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Or',
                        style: GoogleFonts.nunitoSans(color: Colors.grey),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.grey, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/google_logo.png',
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text('Sign In with Google'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    children: [
                      const TextSpan(text: 'Don\'t have an account? '),
                      TextSpan(
                        text: 'Sign up',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2323FF),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.onSignUpClicked,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
