import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'body_capture_plugin_platform_interface.dart';

/// An implementation of [BodyCapturePluginPlatform] that uses method channels.
class MethodChannelBodyCapturePlugin extends BodyCapturePluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('body_capture_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
