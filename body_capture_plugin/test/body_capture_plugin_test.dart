import 'package:flutter_test/flutter_test.dart';
import 'package:body_capture_plugin/body_capture_plugin.dart';
import 'package:body_capture_plugin/body_capture_plugin_platform_interface.dart';
import 'package:body_capture_plugin/body_capture_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBodyCapturePluginPlatform
    with MockPlatformInterfaceMixin
    implements BodyCapturePluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BodyCapturePluginPlatform initialPlatform = BodyCapturePluginPlatform.instance;

  test('$MethodChannelBodyCapturePlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBodyCapturePlugin>());
  });

  test('getPlatformVersion', () async {
    BodyCapturePlugin bodyCapturePlugin = BodyCapturePlugin();
    MockBodyCapturePluginPlatform fakePlatform = MockBodyCapturePluginPlatform();
    BodyCapturePluginPlatform.instance = fakePlatform;

    expect(await bodyCapturePlugin.getPlatformVersion(), '42');
  });
}
