// AppDelegate.swift
import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Get the registrar for your plugin (use a unique identifier here)
    if let registrar = self.registrar(forPlugin: "LidarScanViewPlugin") {

        // Instantiate your factory
        let factory = LidarScanViewFactory(messenger: registrar.messenger())

        // Register the *factory* instance with the Flutter engine
        // "com.yourcompany.bodyscan/lidarScanView" is the unique view type ID used in Dart
        registrar.register(factory, withId: "com.yourcompany.bodyscan/lidarScanView")
    } else {
        print("Error: Could not get registrar for plugin 'LidarScanViewPlugin'")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
