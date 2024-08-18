/*
 * Copyright 2024 Canardoux.
 *
 * This file is part of the τ project.
 *
 * τ is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 (GPL3), as published by
 * the Free Software Foundation.
 *
 * τ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with τ.  If not, see <https://www.gnu.org/licenses/>.
 */
export 'src/fs/fs.dart';
export 'public/td/td.dart';

//export 'src/dummy.dart'
    //if (dart.library.html) 'package:web/web.dart'
    //if (dart.library.io) 'src/temp.dart';

//export 'src/dummy.dart'
    //if (dart.library.html) 'src/permission_handler_web.dart'
    //if (dart.library.io) 'package:permission_handler/permission_handler.dart';

import 'src/dummy.dart'
    if (dart.library.html) 'package:web/web.dart'
    if (dart.library.io) 'src/temp.dart';
import 'package:web/web.dart';
import 'public/td/taudio_source.dart';
import 'public/td/taudio_destination.dart';

/// The possible states of the Player.
enum TaudioState {
  /// Taudio not open or has been closed
  ///
  isClosed,

  /// Taudio is stopped
  isStopped,

  /// Taudio is playing
  isPlaying,

  /// Taudio is paused
  isPaused,

  /// Taudio is recording
  isRecording,
}

typedef TWhenFinished = void Function();

class TaudioCodec {
  String get type => 'audio/mpeg';
}

class Taudio {
  TaudioState _taudioState = TaudioState.isClosed;

  AudioContext context = AudioContext();
  /* ctor */ Taudio();

  FromUrl fromUrl({required TaudioCodec codec, required String path}) =>
      FromUrl(context: context, path: path, codec: codec);

  OutputDevice speaker() =>
      OutputDevice(context: context, type: TaudioDeviceType.speaker);

  TaudioState getState() => _taudioState;
  bool isPlaying() => _taudioState == TaudioState.isPlaying;
  bool isRecording() => _taudioState == TaudioState.isRecording;
  bool isOpen() => _taudioState != TaudioState.isClosed;
  bool isStopped() => _taudioState == TaudioState.isStopped;
  bool isPaused() => _taudioState == TaudioState.isPaused;

  Future<void> open({
    //{isBGService = false}
    required TaudioSource from,
    required TaudioDestination to,
  }) {
    AudioNode source = from.node;
    AudioNode destination = to.node;
    source.connect(destination);
    return to.open().then((value) {
      from.open();
    }).then((value) {});
  }

  Future<void> close() {
    return Future.value();
  }

  Future<void> play() {
    return Future.value();
  }

  Future<void> record() {
    return Future.value();
  }

  Future<void> stop() {
    return Future.value();
  }

  Future<void> rewind() {
    return Future.value();
  }
}
