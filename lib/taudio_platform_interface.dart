import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'taudio_method_channel.dart';

abstract class TaudioPlatform extends PlatformInterface {
  /// Constructs a TaudioPlatform.
  TaudioPlatform() : super(token: _token);

  static final Object _token = Object();

  static TaudioPlatform _instance = MethodChannelTaudio();

  /// The default instance of [TaudioPlatform] to use.
  ///
  /// Defaults to [MethodChannelTaudio].
  static TaudioPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TaudioPlatform] when
  /// they register themselves.
  static set instance(TaudioPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
