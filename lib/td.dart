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

// The three interfaces to the platform
// ------------------------------------

/// ------------------------------------------------------------------
/// # The Flutter Sound library
///
/// Flutter Sound is composed with six main modules/classes
/// - `FlutterSound`. This is the main Flutter Sound module.
/// - [FlutterSoundPlayer]. Everything about the playback functions
/// - [FlutterSoundRecorder]. Everything about the recording functions
/// - [FlutterSoundHelper]. Some utilities to manage audio data.
/// And two modules for the Widget UI
/// - [SoundPlayerUI]
/// - [SoundRecorderUI]
/// ------------------------------------------------------------------
/// {@category Main}
library tau;

//import 'src/dummy.dart'
//if (dart.library.html) 'src/taudio_web.dart'
//if (dart.library.io) 'src/taudio_nat.dart';
//    if (dart.library.html) 'package:web/web.dart'
//    if (dart.library.io) 'package:tauwa/tauwa.dart';
//import 'package:web/web.dart';
//import 'td.dart';
import 'dart:typed_data' show Uint8List;
import 'taudio.dart';

import 'src/dummy.dart'
    if (dart.library.html) 'src/taudio_web.dart'
    if (dart.library.io) 'src/taudio_nat.dart';

/// The possible states of the Player.
enum TaudioState {
  /// Taudio not open or has been closed
  ///
  closed,

  /// Taudio is stopped
  stopped,

  /// Taudio is playing
  playing,

  /// Taudio is paused
  paused,

  /// Taudio is recording
  recording,
}

//typedef TWhenFinished = void Function();

class Taudio {
  TaudioState _taudioState = TaudioState.closed;

  TaudioSource? source;
  TaudioDestination? destination;
  AudioContext context = AudioContext();
  /* ctor */ Taudio();

  Future<TaudioBuffer> decode(
          {required Uint8List buffer, required TaudioCodec codec}) =>
      TaudioBuffer.decode(context: context, buffer: buffer, codec: codec);
  FromUri fromUri({required TaudioCodec codec, required String path}) =>
      FromUri(context: context, path: path, codec: codec);

  OutputDevice speaker() =>
      OutputDevice(context: context, type: TaudioDeviceType.speaker);

  //TaudioState getState() => _taudioState;
  TaudioState getState() {
    if (context.state == "closed") {
      return TaudioState.closed;
    }
    if (context.state == "suspended") {
      return TaudioState.stopped;
    }
    if (context.state == "running") {
//TODO
    }
    return TaudioState.stopped; // TODO
  }

  bool isPlaying() => _taudioState == TaudioState.playing;
  bool isRecording() => _taudioState == TaudioState.recording;
  bool isOpen() => _taudioState != TaudioState.closed;
  bool isStopped() => _taudioState == TaudioState.stopped;
  bool isPaused() => _taudioState == TaudioState.paused;

  Future<void> open({
    //{isBGService = false}
    required TaudioSource from,
    required TaudioDestination to,
  }) async {
    source = from;
    destination = to;
    await to.open();
    await from.open();
    from.node!.connect(to.node!);
  }

  Future<void> close() => (context.close()).toDart;

  Future<void> suspend() => (context.suspend()).toDart;
  Future<void> resume() => (context.resume()).toDart;

  // Future<void> play() => (context.play()).toDart;
  // Future<void> pause() => (context.pause()).toDart;

  void start() => (source!.node! as AudioScheduledSourceNode).start();
  void stop() => (source!.node! as AudioScheduledSourceNode).stop();

  Future<void> record() {
    // TODO
    return Future.value();
  }

  Future<void> rewind() {
    // TODO
    return Future.value();
  }
}

abstract class TaudioNode {
  late AudioContext context;
  AudioNode? node;

  /* ctor */ TaudioNode({required this.context});
}
