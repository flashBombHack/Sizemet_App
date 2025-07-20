import 'package:flutter/material.dart';
// Ensure this import path matches your new plugin name!
import 'package:body_capture_plugin/body_capture_plugin.dart';

void main() {
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
  // Instantiate your plugin. This will set up the EventChannel listener.
  final BodyCapturePlugin _bodyCapturePlugin = BodyCapturePlugin();

  String _statusMessage = "Ready to scan.";
  String _errorMessage = "";
  String? _usdzPath;
  double _progress = 0.0;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    // Listen to the streams for updates from the native side
    _bodyCapturePlugin.scanProgress.listen((progress) {
      setState(() {
        _progress = progress;
      });
    });

    _bodyCapturePlugin.scanStatus.listen((status) {
      setState(() {
        _statusMessage = status;
      });
    });

    _bodyCapturePlugin.usdzExportPath.listen((path) {
      setState(() {
        _usdzPath = path;
        _isScanning = false; // Scan finished
        _statusMessage = "Scan completed! USDZ saved.";
      });
    });

    _bodyCapturePlugin.scanError.listen((error) {
      setState(() {
        _errorMessage = "Error: $error";
        _isScanning = false; // Scan failed
        _statusMessage = "Scan failed.";
      });
    });
  }

  @override
  void dispose() {
    _bodyCapturePlugin.dispose(); // Clean up streams
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

    // Call the native method to start the scan
    final String? path = await _bodyCapturePlugin.startObjectCaptureScan();
    if (path != null) {
      setState(() {
        _usdzPath = path;
        _isScanning = false;
        _statusMessage = "Scan completed! USDZ saved at: $path";
      });
    } else {
      // If path is null, it means there was an error or it was cancelled
      // The error stream will handle setting _errorMessage
      setState(() {
        _isScanning = false;
        if (_errorMessage.isEmpty) { // If no specific error from stream, set a generic one
          _errorMessage = "Scan did not complete or was cancelled.";
          _statusMessage = "Scan aborted.";
        }
      });
    }
  }

  Future<void> _stopScan() async {
    setState(() {
      _isScanning = false;
      _statusMessage = "Scan stopped.";
      _errorMessage = ""; // Clear any previous errors on stop
    });
    await _bodyCapturePlugin.stopObjectCaptureScan();
  }

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