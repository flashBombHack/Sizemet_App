// main.dart
import 'dart:async'; // FOR StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For MethodChannel, EventChannel, PlatformViews
import 'package:flutter/foundation.dart'; // For TargetPlatform checks
import 'package:flutter/rendering.dart'; // For UiKitView

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Body Scanner App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Define your MethodChannel and EventChannel directly with the exact names used in Swift
  static const MethodChannel _methodChannel = MethodChannel('com.yourcompany.bodyscan/bodyCaptureMethod');
  static const EventChannel _eventChannel = EventChannel('com.yourcompany.bodyscan/bodyCaptureEvents');

  String _statusMessage = "Ready to scan.";
  String _errorMessage = "";
  String? _usdzPath;
  double _progress = 0.0;
  bool _isScanning = false;

  // Stream subscriptions to manage lifecycle
  late StreamSubscription<dynamic> _eventSubscription;

  @override
  void initState() {
    super.initState();
    _listenToNativeEvents();
  }

  void _listenToNativeEvents() {
    // Listen to all events from the single EventChannel
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
            _isScanning = false; // Scan finished
            _statusMessage = "Scan completed! USDZ saved.";
          });
        } else if (event.containsKey('error')) {
          setState(() {
            _errorMessage = "Error: ${event['error']}";
            _isScanning = false; // Scan failed
            _statusMessage = "Scan failed.";
          });
        }
      }
    }, onError: (error) {
      setState(() {
        _errorMessage = "Stream Error: ${error.message}";
        _isScanning = false;
        _statusMessage = "Scan stream error.";
      });
    });
  }

  @override
  void dispose() {
    _eventSubscription.cancel(); // Cancel the single stream subscription
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
      await _methodChannel.invokeMethod('startBodyCaptureScan'); // Call native method
      // Updates will come via the EventChannel listeners
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = "Failed to start scan: '${e.message}'";
        _isScanning = false;
        _statusMessage = "Scan failed.";
      });
    }
  }

  Future<void> _stopScan() async {
    setState(() {
      _isScanning = false;
      _statusMessage = "Scan stopped.";
      _errorMessage = ""; // Clear any previous errors on stop
    });
    try {
      await _methodChannel.invokeMethod('stopBodyCaptureScan'); // Call native method
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = "Failed to stop scan: '${e.message}'";
      });
    }
  }

  // Define the view type string, MUST match the ID registered in AppDelegate.swift
  static const String _viewType = 'com.yourcompany.bodyscan/lidarScanView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Scanner App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Your native LidarScanView integrated into the Flutter widget tree
              if (defaultTargetPlatform == TargetPlatform.iOS)
                Expanded(
                  child: UiKitView(
                    viewType: _viewType,
                    layoutDirection: TextDirection.ltr,
                    creationParams: const <String, dynamic>{}, // Optional: pass parameters
                    creationParamsCodec: const StandardMessageCodec(),
                  ),
                )
              else if (defaultTargetPlatform == TargetPlatform.android)
              // Placeholder for Android: You'll need to implement an AndroidView for Android
                const Text('Android Platform View not implemented yet'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isScanning ? null : _startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Start Body Scan'),
              ),
              const SizedBox(height: 20),
              if (_isScanning)
                ElevatedButton(
                  onPressed: _stopScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('Stop Scan'),
                ),
              const SizedBox(height: 30),
              Text(
                'Status: $_statusMessage',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: _progress),
              Text('${(_progress * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              if (_usdzPath != null)
                Column(
                  children: [
                    const Text(
                      'Scan Result (USDZ):',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SelectableText(
                      _usdzPath!,
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}