import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'taudio_platform_interface.dart';

/// An implementation of [TaudioPlatform] that uses method channels.
class MethodChannelTaudio extends TaudioPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('taudio');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
