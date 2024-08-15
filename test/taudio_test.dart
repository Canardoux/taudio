import 'package:flutter_test/flutter_test.dart';
import 'package:taudio/taudio.dart';
import 'package:taudio/taudio_platform_interface.dart';
import 'package:taudio/taudio_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTaudioPlatform
    with MockPlatformInterfaceMixin
    implements TaudioPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TaudioPlatform initialPlatform = TaudioPlatform.instance;

  test('$MethodChannelTaudio is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTaudio>());
  });

  test('getPlatformVersion', () async {
    Taudio taudioPlugin = Taudio();
    MockTaudioPlatform fakePlatform = MockTaudioPlatform();
    TaudioPlatform.instance = fakePlatform;

    expect(await taudioPlugin.getPlatformVersion(), '42');
  });
}
