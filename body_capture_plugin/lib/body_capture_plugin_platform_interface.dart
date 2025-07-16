import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'body_capture_plugin_method_channel.dart';

abstract class BodyCapturePluginPlatform extends PlatformInterface {
  /// Constructs a BodyCapturePluginPlatform.
  BodyCapturePluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static BodyCapturePluginPlatform _instance = MethodChannelBodyCapturePlugin();

  /// The default instance of [BodyCapturePluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelBodyCapturePlugin].
  static BodyCapturePluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BodyCapturePluginPlatform] when
  /// they register themselves.
  static set instance(BodyCapturePluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
