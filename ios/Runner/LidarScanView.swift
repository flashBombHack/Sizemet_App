// LidarScanView.swift
import Flutter
import UIKit
import SwiftUI
import ARKit
import RealityKit
import Observation

// MARK: - LidarScanView (This is the actual native view)
@MainActor // Crucial for UI operations
class LidarScanView: NSObject, FlutterPlatformView {
    private let _view: UIView // The actual UIKit view
    private var methodChannel: FlutterMethodChannel
    private var eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?

    private var appDataModel: AppDataModel = AppDataModel.instance

    // This initializer is called by your LidarScanViewFactory
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        _view.backgroundColor = .clear

        methodChannel = FlutterMethodChannel(name: "com.yourcompany.bodyscan/bodyCaptureMethod", binaryMessenger: messenger)
        eventChannel = FlutterEventChannel(name: "com.yourcompany.bodyscan/bodyCaptureEvents", binaryMessenger: messenger)

        super.init()

        eventChannel.setStreamHandler(self) // LidarScanView must conform to FlutterStreamHandler

        methodChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self?.handle(call: call, result: result)
        })

        // Your SwiftUI content embedded
        let captureSwiftUIMainView = PrimaryView() // Ensure PrimaryView is defined
            .environment(appDataModel)

        let hostingController = UIHostingController(rootView: captureSwiftUIMainView)
        _view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: _view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: _view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: _view.trailingAnchor)
        ])
    }

    func view() -> UIView {
        return _view
    }

    // --- All your native method handlers and event sending logic belong here ---
    // These methods should be part of LidarScanView, NOT LidarScanViewFactory
    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // ... your handle logic ...
        switch call.method {
        case "startBodyCaptureScan":
            print("Native: Received startBodyCaptureScan call from Flutter.")
            appDataModel.reset()
            sendCurrentStateToFlutter()
            result(nil)
            
        case "stopBodyCaptureScan":
            print("Native: Received stopBodyCaptureScan call from Flutter.")
            appDataModel.objectCaptureSession?.cancel()
            appDataModel.reset()
            sendCurrentStateToFlutter()
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func sendEvent(eventName: String, data: Any?) {
        guard let eventSink = eventSink else {
            print("Native: Event sink not available for event '\(eventName)'.")
            return
        }
        eventSink([eventName: data])
    }
    
    private func sendCurrentStateToFlutter() {
        sendEvent(eventName: "status", data: "\(appDataModel.state)")

        //if let session = appDataModel.objectCaptureSession {
        //    sendEvent(eventName: "progress", data: session.progress.fractionCompleted)
       // } else {
        //    sendEvent(eventName: "progress", data: 0.0)
       // }
        //if let usdzPathURL = appDataModel.usdzExportPath {
         //   sendEvent(eventName: "usdzExportPath", data: usdzPathURL.path)
        //} else {
          //  sendEvent(eventName: "usdzExportPath", data: nil)
       // }
        if let errorMessage = appDataModel.error?.localizedDescription {
            sendEvent(eventName: "error", data: errorMessage)
        } else {
            sendEvent(eventName: "error", data: nil)
        }
    }
}

// MARK: - FlutterStreamHandler (Must be an extension of LidarScanView)
extension LidarScanView: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        print("Native: Flutter is listening to EventChannel.")
        sendEvent(eventName: "status", data: "Native Lidar view initialized. Ready to scan.")
        sendCurrentStateToFlutter()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        print("Native: Flutter stopped listening to EventChannel.")
        return nil
    }
}
