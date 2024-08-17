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

import 'dart:ffi';

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

class Taudio {
  TaudioState _taudioState = TaudioState.isClosed;

  /* ctor */ Taudio();

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
  }) {return Future.value();}

  Future<void> close() {return Future.value(); }

  Future<void> play() {return Future.value();}

  Future<void> record() {return Future.value();}

  Future<void> stop() {return Future.value();}

  Future<void> rewind() {return Future.value();}
}
