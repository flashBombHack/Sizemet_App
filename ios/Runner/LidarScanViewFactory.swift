import Flutter
import UIKit
import SwiftUI // Essential for UIHostingController and SwiftUI Views
import ARKit    // Necessary for ARSession and ARView
import RealityKit // Necessary for ARView and PhotogrammetrySession
import Combine  // Required for @Published and Sink if AppDataModel uses ObservableObject

// MARK: - LidarScanViewFactory
// This class is responsible for creating instances of our native UI view (LidarScanView).
// It conforms to FlutterPlatformViewFactory, which Flutter uses to instantiate the native view.
class LidarScanViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    // Initialize the factory with the FlutterBinaryMessenger, which is used for communication
    // between Dart and native code.
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    // This method is called by Flutter to create a new instance of our native view.
    // It returns an object that conforms to FlutterPlatformView.
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        // Create and return an instance of LidarScanView, passing necessary parameters.
        return LidarScanView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            messenger: messenger
        )
    }
    
    // This method specifies the codec used for encoding/decoding arguments passed
    // from Flutter to the native view. FlutterStandardMessageCodec is commonly used.
    // It's required by the FlutterPlatformViewFactory protocol.
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - LidarScanView
// This is the actual UIView that Flutter embeds into the Flutter widget tree.
// It acts as a container for our SwiftUI-based Lidar capture interface.
class LidarScanView: NSObject, FlutterPlatformView {
    private let _view: UIView // The base UIView that Flutter will render.
    private var methodChannel: FlutterMethodChannel // Channel for Dart-to-Native method calls.
    private var eventChannel: FlutterEventChannel   // Channel for Native-to-Dart event streams.
    private var eventSink: FlutterEventSink?        // The sink to send events back to Flutter.

    // An instance of AppDataModel from Apple's sample.
    // This model will hold the state and data related to the Lidar capture process.
    // We assume AppDataModel.swift has been copied into the Runner project.
    private var appDataModel: AppDataModel = AppDataModel.instance // Use the singleton instance if available

    // A set to store Combine cancellables to manage subscriptions to @Published properties.
    // This is crucial for observing changes in AppDataModel if it uses Combine.
    private var cancellables = Set<AnyCancellable>()

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        _view = UIView() // Initialize the base UIView that will hold our SwiftUI content.
        _view.backgroundColor = .clear // Ensure background is clear to show Flutter content underneath if desired

        // Initialize MethodChannel with a unique name. This name MUST match the Dart side.
        methodChannel = FlutterMethodChannel(name: "com.yourcompany.bodyscan/bodyCaptureMethod", binaryMessenger: messenger)
        // Initialize EventChannel with a unique name. This name MUST match the Dart side.
        eventChannel = FlutterEventChannel(name: "com.yourcompany.bodyscan/bodyCaptureEvents", binaryMessenger: messenger)

        super.init()

        // Set this class as the stream handler for the EventChannel, enabling native-to-Dart streaming.
        eventChannel.setStreamHandler(self)

        // Set the method call handler for the MethodChannel, enabling Dart-to-native calls.
        methodChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self?.handle(call: call, result: result)
        })

        // Embed the main SwiftUI capture view (PrimaryView) into a UIHostingController.
        // PrimaryView is identified as the root SwiftUI View from the GuidedCaptureSample.
        // We pass the `appDataModel` instance as an environment object, as `PrimaryView` expects it.
        let captureSwiftUIMainView = PrimaryView()
            .environment(appDataModel) // Pass the appDataModel instance to the SwiftUI environment

        let hostingController = UIHostingController(rootView: captureSwiftUIMainView)
        
        // Add the UIHostingController's view as a subview to our Flutter platform view's base UIView.
        _view.addSubview(hostingController.view)
        
        // Set up Auto Layout constraints to make the hosted SwiftUI view fill the entire frame
        // of our native UIView (_view).
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: _view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: _view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: _view.trailingAnchor)
        ])
        
        // IMPORTANT: Observe changes in AppDataModel and send them to Flutter.
        // This assumes AppDataModel uses Combine's @Published for its properties
        // and conforms to ObservableObject (or is an @Observable class in iOS 17+).
        
        // Observe scan progress
        appDataModel.$currentCaptureProgress
            .sink { [weak self] progress in
                self?.sendEvent(eventName: "progress", data: progress)
            }
            .store(in: &cancellables) // Store the subscription to prevent it from being deallocated
        
        // Observe scan status messages
        appDataModel.$state
            .sink { [weak self] state in
                // Convert the AppDataModel.State enum to a String for Flutter
                self?.sendEvent(eventName: "status", data: "\(state)")
            }
            .store(in: &cancellables)
        
        // Observe USDZ export path
        appDataModel.$usdzExportPath
            .sink { [weak self] path in
                if let usdzPath = path?.path { // Convert URL to String path
                    self?.sendEvent(eventName: "usdzExportPath", data: usdzPath)
                }
            }
            .store(in: &cancellables)
            
        // Observe error messages
        appDataModel.$errorMessage
            .sink { [weak self] message in
                if let errorMessage = message {
                    self?.sendEvent(eventName: "error", data: errorMessage)
                }
            }
            .store(in: &cancellables)
    }

    // This method is required by FlutterPlatformView and returns the UIView to be embedded.
    func view() -> UIView {
        return _view
    }

    // Handles method calls received from the Flutter (Dart) side.
    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startBodyCaptureScan":
            print("Native: Received startBodyCaptureScan call from Flutter.")
            // Trigger the start of the capture session via AppDataModel.
            // This method needs to exist and correctly initiate the Lidar capture process
            // within the logic copied from Apple's sample.
            appDataModel.startCaptureSession()
            result(nil) // Return nil immediately; the USDZ path will be sent via event channel later.
            
        case "stopBodyCaptureScan":
            print("Native: Received stopBodyCaptureScan call from Flutter.")
            // Trigger the stopping of the capture session via AppDataModel.
            appDataModel.stopCaptureSession()
            result(nil)
            
        default:
            // If the method call is not recognized, inform Flutter.
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Helper function to send events back to the Flutter (Dart) side.
    private func sendEvent(eventName: String, data: Any?) {
        guard let eventSink = eventSink else {
            print("Native: Event sink not available for event '\(eventName)'.")
            return
        }
        // Send a dictionary where the key is the event name and the value is the data.
        // This mirrors the structure expected by the Dart EventChannel listener.
        eventSink([eventName: data])
    }
}

// MARK: - FlutterStreamHandler
// This extension makes LidarScanView conform to FlutterStreamHandler,
// allowing it to manage the lifecycle of the EventChannel stream.
extension LidarScanView: FlutterStreamHandler {
    // Called when Flutter starts listening to the EventChannel.
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events // Store the event sink to send events later.
        print("Native: Flutter is listening to EventChannel.")
        // Optionally, send an initial status event when the listener is set up.
        sendEvent(eventName: "status", data: "Native Lidar view initialized. Ready to scan.")
        return nil
    }

    // Called when Flutter stops listening to the EventChannel.
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil // Clear the event sink.
        print("Native: Flutter stopped listening to EventChannel.")
        return nil
    }
}
