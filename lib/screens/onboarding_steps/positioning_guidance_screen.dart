import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../widgets/onboarding_progress_bar.dart'; // Ensure this import is correct
import '../lidar_scanner_screen.dart'; // Import the Lidar scanner screen

class PositioningGuidanceScreen extends StatefulWidget {
  final VoidCallback onProceed;
  final int currentStep;
  final int totalSteps;
  final String selectedMethod;

  const PositioningGuidanceScreen({
    super.key,
    required this.onProceed,
    required this.currentStep,
    required this.totalSteps,
    required this.selectedMethod,
  });

  @override
  State<PositioningGuidanceScreen> createState() => _PositioningGuidanceScreenState();
}

class _PositioningGuidanceScreenState extends State<PositioningGuidanceScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  String? _error;

  // Define video URLs for each scanning method.
  // IMPORTANT: The provided URLs are examples and may not be accessible.
  // Please replace them with your actual, publicly accessible video URLs (e.g., from an S3 bucket, your web server, or a CDN).
  final Map<String, String> _videoUrls = {
    'handheld': 'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'tripod': 'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
  };

  final Map<String, String> _guidanceText = {
    'handheld': 'Time to get a friend! Have someone hold your phone for you. They should stand about 2 meters, or 6 feet, away from you. Make sure your whole body fits nicely in the camera\'s view!',
    'tripod': 'Time to set up! Place your phone on a stable surface, like a tripod or table, right around your waist or face height. Now, stand about 2 meters, or 6 feet, away from the phone. Make sure your whole body fits nicely in the camera\'s view!',
  };

  @override
  void initState() {
    super.initState();
    _initializeAndPlayVideo();
  }

  Future<void> _initializeAndPlayVideo() async {
    final videoUrl = Uri.parse(_videoUrls[widget.selectedMethod]!);
    _controller = VideoPlayerController.networkUrl(videoUrl);

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (mounted) {
        _controller.play();
        _controller.setLooping(true);
        _controller.setVolume(0.0); // Start muted
        setState(() {});
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load video. Please check your internet connection and the video URL.';
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // New method to navigate to Lidar scanner screen
  void _navigateToLidarScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LidarScannerScreen(),
      ),
    );
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Check if OnboardingProgressBar exists before using
              // OnboardingProgressBar(
              //   currentStep: widget.currentStep,
              //   totalSteps: widget.totalSteps,
              // ),
              const SizedBox(height: 16),
              Text(
                'Positioning Guidance',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (_error != null) {
                      return _buildErrorContainer(_error!);
                    }
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: VideoPlayer(_controller),
                        ),
                      );
                    } else {
                      return _buildLoadingContainer();
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _guidanceText[widget.selectedMethod]!,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToLidarScanner, // Updated to navigate to Lidar scanner
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2323FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: GoogleFonts.nunitoSans(fontSize: 18, fontWeight: FontWeight.w600),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    label: const Text('Ready to Scan'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContainer() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorContainer(String errorMessage) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            errorMessage,
            style: GoogleFonts.nunitoSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
