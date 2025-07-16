
import 'body_capture_plugin_platform_interface.dart';

class BodyCapturePlugin {
  Future<String?> getPlatformVersion() {
    return BodyCapturePluginPlatform.instance.getPlatformVersion();
  }
}
