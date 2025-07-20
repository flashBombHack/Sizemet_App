import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      let messenger = self.window?.rootViewController as! FlutterBinaryMessenger

          // Register the LidarScanViewFactory with the Flutter engine.
          // The string "com.yourcompany.bodyscan/LidarScanView" is the unique viewType identifier.
          // This MUST match the viewType you will use in your Dart code.
          self.registrar(forPlugin: "LidarScanViewFactory")!.register(
              LidarScanViewFactory(messenger: messenger),
              withId: "com.yourcompany.bodyscan/LidarScanView"
          )
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
