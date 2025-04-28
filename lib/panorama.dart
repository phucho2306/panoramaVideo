
import 'panorama_platform_interface.dart';

class Panorama {
  Future<String?> getPlatformVersion() {
    return PanoramaPlatform.instance.getPlatformVersion();
  }
}
