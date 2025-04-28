import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'panorama_platform_interface.dart';

/// An implementation of [PanoramaPlatform] that uses method channels.
class MethodChannelPanorama extends PanoramaPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('panorama');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
