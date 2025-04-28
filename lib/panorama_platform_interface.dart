import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'panorama_method_channel.dart';

abstract class PanoramaPlatform extends PlatformInterface {
  /// Constructs a PanoramaPlatform.
  PanoramaPlatform() : super(token: _token);

  static final Object _token = Object();

  static PanoramaPlatform _instance = MethodChannelPanorama();

  /// The default instance of [PanoramaPlatform] to use.
  ///
  /// Defaults to [MethodChannelPanorama].
  static PanoramaPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PanoramaPlatform] when
  /// they register themselves.
  static set instance(PanoramaPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
