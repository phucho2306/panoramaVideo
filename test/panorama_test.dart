import 'package:flutter_test/flutter_test.dart';
import 'package:panorama/panorama.dart';
import 'package:panorama/panorama_platform_interface.dart';
import 'package:panorama/panorama_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPanoramaPlatform
    with MockPlatformInterfaceMixin
    implements PanoramaPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PanoramaPlatform initialPlatform = PanoramaPlatform.instance;

  test('$MethodChannelPanorama is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPanorama>());
  });

  test('getPlatformVersion', () async {
    Panorama panoramaPlugin = Panorama();
    MockPanoramaPlatform fakePlatform = MockPanoramaPlatform();
    PanoramaPlatform.instance = fakePlatform;

    expect(await panoramaPlugin.getPlatformVersion(), '42');
  });
}
