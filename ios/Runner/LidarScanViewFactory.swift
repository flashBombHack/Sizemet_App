// LidarScanViewFactory.swift
import Flutter
import UIKit

// MARK: - LidarScanViewFactory (This is the factory that creates LidarScanView instances)
class LidarScanViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    // The factory's initializer only needs the messenger
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    // This method is called by the Flutter engine to create your native view
    @MainActor func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        // Here, you create and return an instance of your actual view (LidarScanView)
        // Pass all the necessary parameters.
        return LidarScanView( // Call the initializer of LidarScanView
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            messenger: messenger
        )
    }
}
