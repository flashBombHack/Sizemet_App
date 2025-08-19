import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

class LidarScannerScreen extends StatefulWidget {
  const LidarScannerScreen({super.key});

  @override
  State<LidarScannerScreen> createState() => _LidarScannerScreenState();
}

class _LidarScannerScreenState extends State<LidarScannerScreen> {
  static const MethodChannel _methodChannel = MethodChannel('com.yourcompany.bodyscan/bodyCaptureMethod');
  static const EventChannel _eventChannel = EventChannel('com.yourcompany.bodyscan/bodyCaptureEvents');
  static const String _viewType = 'com.yourcompany.bodyscan/lidarScanView';

  String _statusMessage = "Ready to scan.";
  String _errorMessage = "";
  String? _usdzPath;
  double _progress = 0.0;
  bool _isScanning = false;

  late StreamSubscription<dynamic> _eventSubscription;

  @override
  void initState() {
    super.initState();
    _listenToNativeEvents();
  }

  void _listenToNativeEvents() {
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        if (event.containsKey('status')) {
          setState(() {
            _statusMessage = event['status'] as String;
          });
        } else if (event.containsKey('progress')) {
          setState(() {
            _progress = (event['progress'] as num).toDouble();
          });
        } else if (event.containsKey('usdzExportPath')) {
          setState(() {
            _usdzPath = event['usdzExportPath'] as String?;
            _isScanning = false;
            _statusMessage = "Scan completed! USDZ saved.";
          });
        } else if (event.containsKey('error')) {
          setState(() {
            _errorMessage = "Error:  [${event['error']}";
            _isScanning = false;
            _statusMessage = "Scan failed.";
          });
        }
      }
    }, onError: (error) {
      setState(() {
        _errorMessage = "Stream Error:  [${error.message}";
        _isScanning = false;
        _statusMessage = "Scan stream error.";
      });
    });
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _statusMessage = "Starting scan...";
      _errorMessage = "";
      _usdzPath = null;
      _progress = 0.0;
    });

    try {
      await _methodChannel.invokeMethod('startBodyCaptureScan');
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = "Failed to start scan: ' [${e.message}'";
        _isScanning = false;
        _statusMessage = "Scan failed.";
      });
    }
  }

  Future<void> _stopScan() async {
    setState(() {
      _isScanning = false;
      _statusMessage = "Scan stopped.";
      _errorMessage = "";
    });
    try {
      await _methodChannel.invokeMethod('stopBodyCaptureScan');
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = "Failed to stop scan: ' [${e.message}'";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD), // Light blue background
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Scanning in Progress',
          style: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Body Coverage Progress Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              children: [
                Text(
                  'Body Coverage',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2323FF)),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${(_progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // Full-screen Method Channel View
          Expanded(
            child: Container(
              color: const Color(0xFF424242), // Dark grey background
              child: Stack(
                children: [
                  // Method Channel View (iOS Swift code)
                  if (defaultTargetPlatform == TargetPlatform.iOS)
                    UiKitView(
                      viewType: _viewType,
                      layoutDirection: TextDirection.ltr,
                      creationParams: const <String, dynamic>{},
                      creationParamsCodec: const StandardMessageCodec(),
                    )
                  else if (defaultTargetPlatform == TargetPlatform.android)
                    const Center(
                      child: Text(
                        'Android Platform View not implemented yet',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  
                  // Overlay for scan controls (only show when not scanning)
                  if (!_isScanning)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: ElevatedButton(
                        onPressed: _startScan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2323FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Start Scan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  
                  // Overlay for stop button (only show when scanning)
                  if (_isScanning)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: ElevatedButton(
                        onPressed: _stopScan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Stop Scan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Instruction Box at the bottom
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                // Rotation icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2323FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.rotate_right,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                // Instruction text
                Text(
                  'Okay, start slowly rotating clockwise. Just a nice, smooth spin! Keep your arms slightly away from your body, and try to stay super still.',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 