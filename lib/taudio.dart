export 'src/fs/fs.dart';
export 'public/td/td.dart';



import 'taudio_platform_interface.dart';

class Taudio {
  Future<String?> getPlatformVersion() {
    return TaudioPlatform.instance.getPlatformVersion();
  }
}
