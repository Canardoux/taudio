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

import 'dart:typed_data' show Uint8List;
import 'package:logger/logger.dart' show Level, Logger;
import 'src/fs/flutter_sound_player.dart';
import 'src/fs/flutter_sound_recorder.dart';

enum Codec {
  // this enum MUST be synchronized with fluttersound/AudioInterface.java
  // and ios/Classes/FlutterSoundPlugin.h

  /// This is the default codec. If used
  /// Flutter Sound will use the files extension to guess the codec.
  /// If the file extension doesn't match a known codec then
  /// Flutter Sound will throw an exception in which case you need
  /// pass one of the known codec.
  defaultCodec,

  /// AAC codec in an ADTS container
  aacADTS,

  /// OPUS in an OGG container
  opusOGG,

  /// Apple encapsulates its bits in its own special envelope
  /// .caf instead of a regular ogg/opus (.opus).
  /// This is completely stupid, this is Apple.
  opusCAF,

  /// For those who really insist about supporting MP3. Shame on you !
  mp3,

  /// VORBIS in an OGG container
  vorbisOGG,

  /// Linear 16 PCM, without envelope
  pcm16,

  /// Linear 16 PCM, which is a Wave file.
  pcm16WAV,

  /// Linear 16 PCM, which is a AIFF file
  pcm16AIFF,

  /// Linear 16 PCM, which is a CAF file
  pcm16CAF,

  /// FLAC
  flac,

  /// AAC in a MPEG4 container
  aacMP4,

  /// AMR-NB
  amrNB,

  /// AMR-WB
  amrWB,

  /// Raw PCM Linear 8
  pcm8,

  /// Raw PCM with 32 bits Floating Points
  pcmFloat32,

  /// PCM with a WebM format
  pcmWebM,

  /// Opus with a WebM format
  opusWebM,

  /// Vorbis with a WebM format
  vorbisWebM,
}

/// For internal code. Do not use.
///
/// The possible states of the players and recorders
/// @nodoc
enum Initialized {
  /// The object has been created but is not initialized
  notInitialized,

  /// The object is initialized and can be fully used
  fullyInitialized,
}

/// The usual file extensions used for each codecs
const List<String> ext = [
  '', // defaultCodec
  '.aac', // aacADTS
  '.opus', // opusOGG
  '.caf', // opusCAF
  '.mp3', // mp3
  '.ogg', // vorbisOGG
  '.pcm', // pcm16
  '.wav', // pcm16WAV
  '.aiff', // pcm16AIFF
  '_pcm.caf', // pcm16CAF
  '.flac', // flac
  '.mp4', // aacMP4
  '.amr', // AMR-NB
  '.amr', // amr-WB
  '.pcm', // pcm8
  '.pcm', // pcmFloat32
  '.pcm', //codec.pcmWebM,
  '.webm', // codec.opusWebM,
  '.webm', // codec.vorbisWebM,
];

/// The valid file extensions for each codecs
const List<List<String>> validExt = [
  [''], // defaultCodec
  ['.aac', '.adt', '.adts'], // aacADTS
  ['.opus', '.ogg'], // opusOGG
  ['.caf'], // opusCAF
  ['.mp3'], // mp3
  ['.ogg'], // vorbisOGG
  ['.pcm', '.aiff'], // pcm16
  ['.wav'], // pcm16WAV
  ['.aiff'], // pcm16AIFF
  ['.caf'], // pcm16CAF
  ['.flac'], // flac
  ['.mp4', '.aac', '.m4a'], // aacMP4
  ['.amr', '.3ga'], // AMR-NB
  ['.amr', '.3ga'], // amr-WB
  ['.pcm', '.aiff'], // pcm8
  ['.pcm', '.aiff'], // pcmFloat32
  ['.pcm', '.webm'], //codec.pcmWebM,
  ['.opus', '.webm'], // codec.opusWebM,
  ['.webm'], // codec.vorbisWebM,
];

var mime_types = [
  'audio/webm;codecs=opus', // defaultCodec,
  'audio/aac', // aacADTS, //*
  'audio/opus;codecs=opus', // opusOGG, // 'audio/ogg' 'audio/opus'
  'audio/x-caf', // opusCAF,
  'audio/mpeg', // mp3, //*
  'audio/ogg;codecs=vorbis', // vorbisOGG,// 'audio/ogg' // 'audio/vorbis'
  'audio/pcm', // pcm16,
  'audio/wav;codecs=1', // pcm16WAV,
  'audio/aiff', // pcm16AIFF,
  'audio/x-caf', // pcm16CAF,
  'audio/x-flac', // flac, // 'audio/flac'
  'audio/mp4', // aacMP4, //*
  'audio/AMR', // amrNB, //*
  'audio/AMR-WB', // amrWB, //*
  'audio/pcm', // pcm8,
  'audio/pcm', // pcmFloat32,
  'audio/webm;codecs=pcm', // pcmWebM,
  'audio/webm;codecs=opus', // opusWebM,
  'audio/webm;codecs=vorbis', // vorbisWebM
];

/// Food is an abstract class which represents objects that can be sent
/// to a player when playing data from astream or received by a recorder
/// when recording to a Dart Stream.
///
/// This class is extended by
/// - [FoodData] and
/// - [FoodEvent].
abstract class Food {
  /// use internally by Flutter Sound
  Future<void> exec(FlutterSoundPlayer player);

  /// use internally by Flutter Sound
  void dummy(FlutterSoundPlayer player) {} // Just to satisfy `dartanalyzer`
}

/// FoodData are the regular objects received from a recorder when recording to a Dart Stream
/// or sent to a player when playing from a Dart Stream
class FoodData extends Food {
  /// the data to be sent (or received)
  Uint8List? data;

  /// The constructor, specifying the data to be sent or that has been received
  /* ctor */ FoodData(this.data);

  /// Used internally by Flutter Sound
  @override
  Future<void> exec(FlutterSoundPlayer player) => player.feedFromStream(data!);
}

/// foodEvent is a special kind of food which allows to re-synchronize a stream
/// with a player that play from a Dart Stream
class FoodEvent extends Food {
  /// The callback to fire when this food is synchronized with the player
  Function on;

  /// The constructor, specifying the callback which must be fired when synchronization is done
  /* ctor */ FoodEvent(this.on);

  /// Used internally by Flutter Sound
  @override
  Future<void> exec(FlutterSoundPlayer player) async => on();
}

/// This is **THE** main Flutter Sound class.
///
/// For future expansion. Do not use.
/// This class is not instanciable. Use the expression [FlutterSound()] when you want to get the Singleton.
///
/// This class is used to access the main functionalities of Flutter Sound. It declares also
/// a default [FlutterSoundPlayer] and a default [FlutterSoundRecorder] that can be used
/// by the App, without having to build such objects themselves.
/// @nodoc
class FlutterSound {
  Logger _logger = Logger(level: Level.debug);

  /// The FlutterSound Logger getter
  Logger get logger => _logger;

  /// The FlutterSound Logger setter
  set logger(aLogger) {
    _logger = aLogger;
    // TODO
    // Here we must call flutter_sound_core if necessary
  }

  // ---------------------------------------------------------------------------------------------------------------------

  /// the static Singleton
  static final FlutterSound _singleton = FlutterSound._internal();

  /// The factory which returns the Singleton
  factory FlutterSound() {
    return _singleton;
  }

  /// Private constructor of the Singleton
  /* ctor */ FlutterSound._internal();

  /// This instance of [FlutterSoundPlayer] is just to be smart for the App.
  /// The Apps can use this instance without having to create a [FlutterSoundPlayer] themselves.
  FlutterSoundPlayer thePlayer = FlutterSoundPlayer();

  /// TODO
  void internalOpenSessionForRecording() {
    //todo
  }

  // ----------------------------------------------------------------------------------------------------------------------
}
