import 'package:flutter/services.dart';
import 'dart:async'; // Import for StreamController

class BodyCapturePlugin { // Changed class name
  // Define the MethodChannel for invoking methods on the native side.
  // The channel name must match what you will define in your Swift code.
  // Changed channel name for consistency
  static const MethodChannel _methodChannel =
      MethodChannel('com.yourcompany.bodyscan/bodyCaptureMethod'); 

  // Define the EventChannel for receiving events (e.g., progress, status)
  // from the native side. The channel name must match what you will define in Swift.
  // Changed channel name for consistency
  static const EventChannel _eventChannel =
      EventChannel('com.yourcompany.bodyscan/bodyCaptureEvents');

  // Private stream controllers to expose the native events as Dart streams.
  static final StreamController<double> _progressStreamController =
      StreamController<double>.broadcast();
  static final StreamController<String> _statusStreamController =
      StreamController<String>.broadcast();
  static final StreamController<String> _usdzPathStreamController =
      StreamController<String>.broadcast();
  static final StreamController<String> _errorStreamController =
      StreamController<String>.broadcast();

  BodyCapturePlugin() { // Changed constructor name
    // Listen to the native event channel and distribute events to the correct streams.
    _eventChannel.receiveBroadcastStream().listen((dynamic event) {
      if (event is Map) {
        if (event.containsKey('progress')) {
          _progressStreamController.add(event['progress'] as double);
        } else if (event.containsKey('status')) {
          _statusStreamController.add(event['status'] as String);
        } else if (event.containsKey('usdzExportPath')) {
          _usdzPathStreamController.add(event['usdzExportPath'] as String);
        } else if (event.containsKey('error')) {
          _errorStreamController.add(event['error'] as String);
        }
      }
    });
  }

  /// Initiates the body capture scan process on the native side.
  /// Returns the USDZ export path upon successful completion, or null if cancelled/failed.
  Future<String?> startBodyCaptureScan() async { // Changed method name for consistency
    try {
      final String? usdzPath =
          await _methodChannel.invokeMethod('startBodyCaptureScan'); // Changed method call name
      return usdzPath;
    } on PlatformException catch (e) {
      _errorStreamController.add("Failed to start scan: '${e.message}'.");
      print("Failed to start scan: '${e.message}'.");
      return null;
    }
  }

  /// Stops the ongoing body capture scan process on the native side.
  Future<void> stopBodyCaptureScan() async { // Changed method name for consistency
    try {
      await _methodChannel.invokeMethod('stopBodyCaptureScan'); // Changed method call name
    } on PlatformException catch (e) {
      _errorStreamController.add("Failed to stop scan: '${e.message}'.");
      print("Failed to stop scan: '${e.message}'.");
    }
  }

  /// Stream to listen for scan progress updates (double from 0.0 to 1.0).
  Stream<double> get scanProgress => _progressStreamController.stream;

  /// Stream to listen for scan status messages (e.g., "Scanning...", "Processing...").
  Stream<String> get scanStatus => _statusStreamController.stream;

  /// Stream to listen for the final USDZ export path upon successful completion.
  Stream<String> get usdzExportPath => _usdzPathStreamController.stream;

  /// Stream to listen for any errors occurring during the scan process.
  Stream<String> get scanError => _errorStreamController.stream;

  // Don't forget to close the stream controllers when the plugin is no longer needed
  // (e.g., in a dispose method of a stateful widget or when the app exits,
  // though for a global plugin instance, this might not be strictly necessary
  // until app shutdown).
  void dispose() {
    _progressStreamController.close();
    _statusStreamController.close();
    _usdzPathStreamController.close();
    _errorStreamController.close();
  }
}