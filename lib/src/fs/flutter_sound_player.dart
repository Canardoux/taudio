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

/// **THE** Flutter Sound Player
/// {@category Main}
library player;

import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:io' show Platform;
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show kIsWeb;
//import 'package:flutter_sound_platform_interface/flutter_sound_player_platform_interface.dart';
import 'package:logger/logger.dart' show Level, Logger;
//import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'fs.dart';
//import 'package:flutter/src/services/platform_channel.dart';
//import '../flutter_sound.dart';

/// The possible states of the Player.
enum PlayerState {
  /// Player is stopped
  isStopped,

  /// Player is playing
  isPlaying,

  /// Player is paused
  isPaused,
}

/// Playback function type for [FlutterSoundPlayer.startPlayer()].
///
/// Note : this type must include a parameter with a reference to the FlutterSoundPlayer object involved.
typedef TWhenFinished = void Function();

//--------------------------------------------------------------------------------------------------------------------------------------------

/// A Player is an object that can playback from various sources.
///
/// ----------------------------------------------------------------------------------------------------
///
/// Using a player is very simple :
///
/// 1. Create a new `FlutterSoundPlayer`
///
/// 2. Open it with [openAudioSession()]
///
/// 3. Start your playback with [startPlayer()].
///
/// 4. Use the various verbs (optional):
///    - [pausePlayer()]
///    - [resumePlayer()]
///    - ...
///
/// 5. Stop your player : [stopPlayer()]
///
/// 6. Release your player when you have finished with it : [closeAudioSession()].
/// This verb will call [stopPlayer()] if necessary.
///
/// ----------------------------------------------------------------------------------------------------
class FlutterSoundPlayer {
  /// The FlutterSoundPlayerLogger
  Logger _logger = Logger(level: Level.debug);
  Level _logLevel = Level.debug;

  /// The default blocksize used when playing from Stream.
  int _bufferSize = 8192;

  /// The FlutterSoundPlayerLogger Logger getter
  Logger get logger => _logger;

  /// Are we waiting for needsForFood completer ?
  bool _waitForFood = false;

  /// Used if the App wants to dynamically change the Log Level.
  /// Seldom used. Most of the time the Log Level is specified during the constructor.
  void setLogLevel(Level aLevel) async {
    _logLevel = aLevel;
    _logger = Logger(level: aLevel);
    //if (_isInited != Initialized.notInitialized) {
    //  FlutterSoundPlayerPlatform.instance.setLogLevel(
    //    this,
    //    aLevel,
    //  );
    //}
  }

  final _lock = Lock();
  static bool _reStarted = true;

  ///
  StreamSubscription<Food>?
      _foodStreamSubscription; // ignore: cancel_subscriptions

  ///
  StreamController<Food>? _foodStreamController; //ignore: close_sinks

  ///
  Completer<int>? _needSomeFoodCompleter;

  ///
  Completer<Duration>? _startPlayerCompleter;
  Completer<void>? _pausePlayerCompleter;
  Completer<void>? _resumePlayerCompleter;
  Completer<void>? _stopPlayerCompleter;
  Completer<FlutterSoundPlayer>? _openPlayerCompleter;

  /// Instanciate a new Flutter Sound player.
  /// The optional paramater `Level logLevel` specify the Logger Level you are interested by.
  /// The optional parameter `bool voiceProcessing` is used to activate the VoiceProcessingIO AudioUnit (only for iOS)
  /* ctor */ FlutterSoundPlayer(
      {Level logLevel = Level.debug, bool voiceProcessing = false}) {
    _logger = Logger(level: logLevel);
    _logger.d('ctor: FlutterSoundPlayer()');
  }

  //===============================================================================================================

  /// Do not use. Should be a private variable
  /// @nodoc
  //Initialized _isInited = Initialized.notInitialized;
  int oldPosition = 0;

  ///
  final PlayerState _playerState = PlayerState.isStopped;

  /// The current state of the Player
  PlayerState get playerState => _playerState;

  /// The food Controller
  StreamController<PlaybackDisposition>? _playerController;

  /// The sink side of the Food Controller
  ///
  /// This the output stream that you use when you want to play asynchronously live data.
  /// This StreamSink accept two kinds of objects :
  /// - FoodData (the buffers that you want to play)
  /// - FoodEvent (a call back to be called after a resynchronisation)
  ///
  /// *Example:*
  ///
  /// `This example` shows how to play Live data, without Back Pressure from Flutter Sound
  /// ```dart
  /// await myPlayer.startPlayerFromStream(codec: Codec.pcm16, numChannels: 1, sampleRate: 48000);
  ///
  /// myPlayer.foodSink.add(FoodData(aBuffer));
  /// myPlayer.foodSink.add(FoodData(anotherBuffer));
  /// myPlayer.foodSink.add(FoodData(myOtherBuffer));
  /// myPlayer.foodSink.add(FoodEvent((){_mPlayer.stopPlayer();}));
  /// ```
  StreamSink<Food>? get foodSink => _foodStreamController?.sink;

  /// The stream side of the Food Controller
  ///
  /// This is a stream on which FlutterSound will post the player progression.
  /// You may listen to this Stream to have feedback on the current playback.
  ///
  /// PlaybackDisposition has two fields :
  /// - Duration duration  (the total playback duration)
  /// - Duration position  (the current playback position)
  ///
  /// *Example:*
  /// ```dart
  ///         _playerSubscription = myPlayer.onProgress.listen((e)
  ///         {
  ///                 Duration maxDuration = e.duration;
  ///                 Duration position = e.position;
  ///                 ...
  ///         }
  /// ```
  Stream<PlaybackDisposition>? get onProgress => _playerController?.stream;

  /// Return true if the Player has been open
  bool isOpen() {
    return true;
  }

  /// Provides a stream of dispositions which
  /// provide updated position and duration
  /// as the audio is played.
  ///
  /// The duration may start out as zero until the
  /// media becomes available.
  /// The `interval` dictates the minimum interval between events
  /// being sent to the stream.
  ///
  /// The minimum interval supported is 100ms.
  ///
  /// Note: the underlying stream has a minimum frequency of 100ms
  /// so multiples of 100ms will give you the most consistent timing
  /// source.
  ///
  /// Note: all calls to [dispositionStream] against this player will
  /// share a single interval which will controlled by the last
  /// call to this method.
  ///
  /// If you pause the audio then no updates will be sent to the
  /// stream.
  Stream<PlaybackDisposition>? dispositionStream() {
    return _playerController?.stream;
  }

  /// User callback "whenFinished:"
  TWhenFinished? _audioPlayerFinishedPlaying;

  /// Test the Player State
  bool get isPlaying => _playerState == PlayerState.isPlaying;

  /// Test the Player State
  bool get isPaused => _playerState == PlayerState.isPaused;

  /// Test the Player State
  bool get isStopped => _playerState == PlayerState.isStopped;

  Future<void> _waitOpen() async {
    while (_openPlayerCompleter != null) {
      _logger.d('Waiting for the player being opened');
      await _openPlayerCompleter!.future;
    }
  }

  /// Open the Player.
  ///
  /// A player must be opened before used.
  /// Opening a player takes resources inside the OS. Those resources are freed with the verb `closePlayer()`.
  /// Returns a Future, but the App does not need to wait the completion of this future before doing a [startPlayer()].
  /// The Future will be automaticaly waited by [startPlayer()]
  ///
  /// On iOS you can pass the `enableVoiceProcessing` parameter to `true` to enable the VoiceProcessingIO AudioUnit, this
  /// is useful to improving speech audio or VoIP applications.
  ///
  /// *Example:*
  /// ```dart
  ///     myPlayer = await FlutterSoundPlayer().openPlayer();
  ///
  ///     ...
  ///     (do something with myPlayer)
  ///     ...
  ///
  ///     await myPlayer.closePlayer();
  ///     myPlayer = null;
  /// ```
  Future<FlutterSoundPlayer?> openPlayer({isBGService = false}) async {
    //if (!Platform.isIOS && enableVoiceProcessing) {
    //throw ('VoiceProcessing is only available on iOS');
    //}

    if (isBGService) {}

    Future<FlutterSoundPlayer?>? r;
    await _lock.synchronized(() async {
      r = _openAudioSession();
    });
    return r;
  }

  Future<FlutterSoundPlayer> _openAudioSession() async {
    _logger.d('FS:---> openAudioSession');
    while (_openPlayerCompleter != null) {
      _logger.w('Another openPlayer() in progress');
      await _openPlayerCompleter!.future;
    }

    if (_reStarted && Foundation.kDebugMode) {
      // Perhaps a Hot Restart ?  We must reset the plugin
      _logger.d('Resetting flutter_sound Player Plugin');
      _reStarted = false;
      //await FlutterSoundPlayerPlatform.instance.resetPlugin(this);
    }
    //FlutterSoundPlayerPlatform.instance.openSession(this);
    _setPlayerCallback();
    assert(_openPlayerCompleter == null);
    _openPlayerCompleter = Completer<FlutterSoundPlayer>();
    //completer = _openPlayerCompleter;
    try {
      //var state = await FlutterSoundPlayerPlatform.instance
      //.openPlayer(this, logLevel: _logLevel);
      //_playerState = PlayerState.values[state];
      //isInited = success ?  Initialized.fullyInitialized : Initialized.notInitialized;
    } on Exception {
      _openPlayerCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- openAudioSession');
    return this;
    //return completer!.future;
  }

  /// Close an open session.
  ///
  /// Must be called when finished with a Player, to release all the resources.
  /// It is safe to call this procedure at any time.
  /// - If the Player is not open, this verb will do nothing
  /// - If the Player is currently in play or pause mode, it will be stopped before.
  ///
  /// example:
  /// ```dart
  /// @override
  /// void dispose()
  /// {
  ///         if (myPlayer != null)
  ///         {
  ///             myPlayer.closeAudioSession();
  ///             myPlayer = null;
  ///         }
  ///         super.dispose();
  /// }
  /// ```
  Future<void> closePlayer() async {
    await _lock.synchronized(() {
      return _closeAudioSession();
    });
  }

  Future<void> _closeAudioSession() async {
    _logger.d('FS:---> closeAudioSession ');

    await _stop(); // Stop the player if running
    //_isInited = Initialized.initializationInProgress; // BOF
    //_cleanCompleters();
    _removePlayerCallback();
    //await FlutterSoundPlayerPlatform.instance.closePlayer(this);

    //FlutterSoundPlayerPlatform.instance.closeSession(this);
    //_isInited = Initialized.notInitialized;
    _logger.d('FS:<--- closeAudioSession ');
  }

  /// Query the current state to the Tau Core layer.
  ///
  /// Most of the time, the App will not use this verb,
  /// but will use the [playerState] variable.
  /// This is seldom used when the App wants to get
  /// an updated value the background state.
  Future<PlayerState> getPlayerState() async {
    await _waitOpen();
    //var state = await FlutterSoundPlayerPlatform.instance.getPlayerState(this);
    //_playerState = PlayerState.values[state];
    return _playerState;
  }

  /// Get the current progress of a playback.
  ///
  /// It returns a `Map` with two Duration entries : `'progress'` and `'duration'`.
  /// Remark : actually only implemented on iOS.
  ///
  /// *Example:*
  /// ```dart
  ///         Duration progress = (await getProgress())['progress'];
  ///         Duration duration = (await getProgress())['duration'];
  /// ```
  Future<Map<String, Duration>> getProgress() async {
    await _waitOpen();
    return <String, Duration>{};
    //return FlutterSoundPlayerPlatform.instance.getProgress(this);
  }

  /// Returns true if the specified decoder is supported by flutter_sound on this platform
  ///
  /// *Example:*
  /// ```dart
  ///         if ( await myPlayer.isDecoderSupported(Codec.opusOGG) ) doSomething;
  /// ```
  Future<bool> isDecoderSupported(Codec codec) async {
    var result = false;
    _logger.d('FS:---> isDecoderSupported ');
    await _waitOpen();
    // For decoding ogg/opus on ios, we need to support two steps :
    // - remux OGG file format to CAF file format (with ffmpeg)
    // - decode CAF/OPPUS (with native Apple AVFoundation)

    //result = await FlutterSoundPlayerPlatform.instance
    //.isDecoderSupported(this, codec: codec);
    _logger.d('FS:<--- isDecoderSupported ');
    return result;
  }

  /// Specify the callbacks frenquency, before calling [startPlayer].
  ///
  /// The default value is 0 (zero) which means that there is no callbacks.
  ///
  /// This verb will be Deprecated soon.
  ///
  /// *Example:*
  /// ```dart
  /// myPlayer.setSubscriptionDuration(Duration(milliseconds: 100));
  /// ```
  Future<void> setSubscriptionDuration(Duration duration) async {
    _logger.d('FS:---> setSubscriptionDuration ');
    await _waitOpen();
    //var state = await FlutterSoundPlayerPlatform.instance
    //.setSubscriptionDuration(this, duration: duration);
    _logger.d('FS:<---- setSubscriptionDuration ');
  }

  ///
  void _setPlayerCallback() {
    _playerController ??= StreamController<PlaybackDisposition>.broadcast();
  }

  void _removePlayerCallback() {
    _playerController?.close();
    _playerController = null;
  }

  /// Used to play a sound.
  //
  /// - `startPlayer()` has three optional parameters, depending on your sound source :
  ///    - `fromUri:`  (if you want to play a file or a remote URI)
  ///    - `fromDataBuffer:` (if you want to play from a data buffer)
  ///    - `sampleRate` is mandatory if `codec` == `Codec.pcm16`. Not used for other codecs.
  ///
  /// You must specify one or the three parameters : `fromUri`, `fromDataBuffer`, `fromStream`.
  ///
  /// - You use the optional parameter`codec:` for specifying the audio and file format of the file. Please refer to the [Codec compatibility Table](/guides_codec.html) to know which codecs are currently supported.
  ///
  /// - `whenFinished:()` : A lambda function for specifying what to do when the playback will be finished.
  ///
  /// Very often, the `codec:` parameter is not useful. Flutter Sound will adapt itself depending on the real format of the file provided.
  /// But this parameter is necessary when Flutter Sound must do format conversion (for example to play opusOGG on iOS).
  ///
  /// `startPlayer()` returns a Duration Future, which is the record duration.
  ///
  /// The `fromUri` parameter, if specified, can be one of three posibilities :
  /// - The URL of a remote file
  /// - The path of a local file
  /// - The name of a temporary file (without any slash '/')
  ///
  /// Hint: [path_provider](https://pub.dev/packages/path_provider) can be useful if you want to get access to some directories on your device.
  ///
  ///
  /// *Example:*
  /// ```dart
  ///         Duration d = await myPlayer.startPlayer(fromURI: 'foo', codec: Codec.aacADTS); // Play a temporary file
  ///
  ///         _playerSubscription = myPlayer.onProgress.listen((e)
  ///         {
  ///                 // ...
  ///         });
  /// }
  /// ```
  ///
  /// *Example:*
  /// ```dart
  ///     final fileUri = "https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3";
  ///
  ///     Duration d = await myPlayer.startPlayer
  ///     (
  ///                 fromURI: fileUri,
  ///                 codec: Codec.mp3,
  ///                 whenFinished: ()
  ///                 {
  ///                          logger.d( 'I hope you enjoyed listening to this song' );
  ///                 },
  ///     );
  /// ```
  Future<Duration?> startPlayer({
    String? fromURI,
    Uint8List? fromDataBuffer,
    Codec codec = Codec.aacADTS,
    int sampleRate = 16000, // Used only with codec == Codec.pcm16
    int numChannels = 1, // Used only with codec == Codec.pcm16
    TWhenFinished? whenFinished,
  }) async {
    Duration? r;
    await _lock.synchronized(() async {
      r = await _startPlayer(
        fromURI: fromURI,
        fromDataBuffer: fromDataBuffer,
        codec: codec,
        sampleRate: sampleRate,
        numChannels: numChannels,
        whenFinished: whenFinished,
      );
    });
    return r;
  }

  Future<Duration> _startPlayer({
    String? fromURI,
    Uint8List? fromDataBuffer,
    Codec codec = Codec.aacADTS,
    int sampleRate = 16000, // Used only with codec == Codec.pcm16
    int numChannels = 1, // Used only with codec == Codec.pcm16
    TWhenFinished? whenFinished,
  }) async {
    _logger.d('FS:---> startPlayer ');
    await _waitOpen();
    oldPosition = 0;

    if (codec == Codec.pcm16 && fromURI != null) {
      /*
      //var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound_tmp.wav';
      await flutterSoundHelper.pcmToWave(
        inputFile: fromURI,
        outputFile: path,
        numChannels: 1,
        //bitsPerSample: 16,
        sampleRate: sampleRate,
      );
      fromURI = path;
      codec = Codec.pcm16WAV;

       */
    } else if (codec == Codec.pcm16 && fromDataBuffer != null) {
      fromDataBuffer = await flutterSoundHelper.pcmToWaveBuffer(
          inputBuffer: fromDataBuffer,
          sampleRate: sampleRate,
          numChannels: numChannels);
      codec = Codec.pcm16WAV;
    }
    Completer<Duration>? completer;

    await _stop(); // Just in case

    if (_playerState != PlayerState.isStopped) {
      throw Exception('Player is not stopped');
    }
    _audioPlayerFinishedPlaying = whenFinished;
    if (_startPlayerCompleter != null) {
      _logger.w('Killing another startPlayer()');
      _startPlayerCompleter!.completeError('Killed by another startPlayer()');
    }
    try {
      _startPlayerCompleter = Completer<Duration>();
      completer = _startPlayerCompleter;
      //var state = await FlutterSoundPlayerPlatform.instance.startPlayer(
      //this,
      //codec: codec,
      //fromDataBuffer: fromDataBuffer,
      //fromURI: fromURI,
      //);
      //_playerState = PlayerState.values[state];
    } on Exception {
      _startPlayerCompleter = null;
      rethrow;
    }
    //Duration duration = Duration(milliseconds: retMap['duration'] as int);
    _logger.d('FS:<--- startPlayer ');
    return completer!.future;
  }

  /// Starts the Microphone and plays what is recorded.
  ///
  /// The Speaker is directely linked to the Microphone.
  /// There is no processing between the Microphone and the Speaker.
  /// If you want to process the data before playing them, actually you must define a loop between a [FlutterSoundPlayer] and a [FlutterSoundRecorder].
  /// (Please, look to [this example](http://www.canardoux.xyz/flutter_sound/doc/pages/flutter-sound/api/topics/flutter_sound_examples_stream_loop.html)).
  ///
  /// Later, we will implement the _Tau Audio Graph_ concept, which will be a more general object.
  ///
  /// - `startPlayerFromMic()` has two optional parameters :
  ///    - `sampleRate:` the Sample Rate used. Optional. Only used on Android. The default value is probably a good choice and the App can ommit this optional parameter.
  ///    - `numChannels:` 1 for monophony, 2 for stereophony. Optional. Actually only monophony is implemented.
  ///
  /// `startPlayerFromMic()` returns a Future, which is completed when the Player is really started.
  ///
  /// *Example:*
  /// ```dart
  ///     await myPlayer.startPlayerFromMic();
  ///     ...
  ///     myPlayer.stopPlayer();
  /// ```
  Future<void> startPlayerFromMic(
      {int sampleRate = 44000, // The default value is probably a good choice.
      int numChannels =
          1, // 1 for monophony, 2 for stereophony (actually only monophony is supported).
      int bufferSize = 8192,
      enableVoiceProcessing = false}) async {
    await _lock.synchronized(() async {
      await _startPlayerFromMic(
        sampleRate: sampleRate,
        numChannels: numChannels,
        bufferSize: bufferSize,
        enableVoiceProcessing: enableVoiceProcessing,
      );
    });
  }

  Future<Duration> _startPlayerFromMic(
      {int sampleRate = 44000, // The default value is probably a good choice.
      int numChannels =
          1, // 1 for monophony, 2 for stereophony (actually only monophony is supported).
      int bufferSize = 8192,
      enableVoiceProcessing = false}) async {
    _logger.d('FS:---> startPlayerFromMic ');
    await _waitOpen();
    oldPosition = 0;

    Completer<Duration>? completer;
    await _stop(); // Just in case
    try {
      if (_startPlayerCompleter != null) {
        _logger.w('Killing another startPlayer()');
        _startPlayerCompleter!.completeError('Killed by another startPlayer()');
      }
      _startPlayerCompleter = Completer<Duration>();
      completer = _startPlayerCompleter;
      //var state = await FlutterSoundPlayerPlatform.instance.startPlayerFromMic(
      //this,
      //numChannels: numChannels,
      //sampleRate: sampleRate,
      //bufferSize: bufferSize,
      //enableVoiceProcessing: enableVoiceProcessing,
      //);
    } on Exception {
      _startPlayerCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- startPlayerFromMic ');
    return completer!.future;
  }

  /// Used to play something from a Dart stream
  ///
  /// **This functionnality needs, at least, and Android SDK >= 21**
  ///
  ///   - The only codec supported is actually `Codec.pcm16`.
  ///   - The only value possible for `numChannels` is actually 1.
  ///   - SampleRate is the sample rate of the data you want to play.
  ///
  ///   Please look to [the following notice](codec.md#playing-pcm-16-from-a-dart-stream)
  ///
  ///   *Example*
  ///   You can look to the three provided examples :
  ///
  ///   - [This example](../flutter_sound/example/example.md#liveplaybackwithbackpressure) shows how to play Live data, with Back Pressure from Flutter Sound
  ///   - [This example](../flutter_sound/example/example.md#liveplaybackwithoutbackpressure) shows how to play Live data, without Back Pressure from Flutter Sound
  ///   - [This example](../flutter_sound/example/example.md#soundeffect) shows how to play some real time sound effects.
  ///
  ///   *Example 1:*
  ///   ```dart
  ///   await myPlayer.startPlayerFromStream(codec: Codec.pcm16, numChannels: 1, sampleRate: 48000);
  ///
  ///   await myPlayer.feedFromStream(aBuffer);
  ///   await myPlayer.feedFromStream(anotherBuffer);
  ///   await myPlayer.feedFromStream(myOtherBuffer);
  ///
  ///   await myPlayer.stopPlayer();
  ///   ```
  ///   *Example 2:*
  ///   ```dart
  ///   await myPlayer.startPlayerFromStream(codec: Codec.pcm16, numChannels: 1, sampleRate: 48000);
  ///
  ///   myPlayer.foodSink.add(FoodData(aBuffer));
  ///  myPlayer.foodSink.add(FoodData(anotherBuffer));
  ///   myPlayer.foodSink.add(FoodData(myOtherBuffer));
  ///
  ///   myPlayer.foodSink.add(FoodEvent((){_mPlayer.stopPlayer();}));
  ///   ```
  Future<void> startPlayerFromStream({
    Codec codec = Codec.pcm16,
    int numChannels = 1,
    int sampleRate = 16000,
    int bufferSize = 8192,
    TWhenFinished? whenFinished,
  }) async {
    await _lock.synchronized(() async {
      await _startPlayerFromStream(
        codec: codec,
        sampleRate: sampleRate,
        numChannels: numChannels,
        bufferSize: bufferSize,
        whenFinished: whenFinished,
      );
    });
  }

  Future<Duration> _startPlayerFromStream({
    Codec codec = Codec.pcm16,
    int numChannels = 1,
    int sampleRate = 16000,
    int bufferSize = 8192,
    TWhenFinished? whenFinished,
  }) async {
    _logger.d('FS:---> startPlayerFromStream ');
    await _waitOpen();
    Completer<Duration>? completer;
    _bufferSize = bufferSize;
    await _stop(); // Just in case
    _foodStreamController = StreamController();
    _foodStreamSubscription = _foodStreamController!.stream.listen((food) {
      _foodStreamSubscription!.pause(food.exec(this));
      //if (Platform.isAndroid && !_waitForFood) {
      //audioPlayerFinished(PlayerState.isPaused.index);
      //}
    });
    if (_startPlayerCompleter != null) {
      _logger.w('Killing another startPlayer()');
      _startPlayerCompleter!.completeError('Killed by another startPlayer()');
    }
    _audioPlayerFinishedPlaying = whenFinished;

    try {
      _startPlayerCompleter = Completer<Duration>();
      completer = _startPlayerCompleter;
      //var state = await FlutterSoundPlayerPlatform.instance.startPlayer(
      ///this,
      //codec: codec,
      //fromDataBuffer: null,
      //fromURI: null,
      //numChannels: numChannels,
      //sampleRate: sampleRate,
      //bufferSize: bufferSize,
      //);
    } on Exception {
      _startPlayerCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- startPlayerFromStream ');
    return completer!.future;
  }

  ///  Used when you want to play live PCM data synchronously.
  ///
  ///  This procedure returns a Future. It is very important that you wait that this Future is completed before trying to play another buffer.
  ///
  ///  *Example:*
  ///
  ///  - [This example](../flutter_sound/example/example.md#liveplaybackwithbackpressure) shows how to play Live data, with Back Pressure from Flutter Sound
  ///  - [This example](../flutter_sound/example/example.md#soundeffect) shows how to play some real time sound effects synchronously.
  ///
  ///  ```dart
  ///  await myPlayer.startPlayerFromStream(codec: Codec.pcm16, numChannels: 1, sampleRate: 48000);
  ///
  ///  await myPlayer.feedFromStream(aBuffer);
  ///  await myPlayer.feedFromStream(anotherBuffer);
  ///  await myPlayer.feedFromStream(myOtherBuffer);
  ///
  ///  await myPlayer.stopPlayer();
  ///  ```
  Future<void> feedFromStream(Uint8List buffer) async {
    await _feedFromStream(buffer);
  }

  Future<void> _feedFromStream(Uint8List buffer) async {
    var lnData = 0;
    var totalLength = buffer.length;
    while (totalLength > 0 && !isStopped) {
      var bsize = totalLength > _bufferSize ? _bufferSize : totalLength;
      _waitForFood = true;
      var ln = await _feed(buffer.sublist(lnData, lnData + bsize));
      _waitForFood = false;
      assert(ln >= 0);
      lnData += ln;
      totalLength -= ln;
    }
  }

  ///
  Future<int> _feed(Uint8List data) async {
    await _waitOpen();
    if (isStopped) {
      return 0;
    }
    _needSomeFoodCompleter =
        Completer<int>(); // Not completed until the device accept new data
    try {
      /*
      var ln = await (FlutterSoundPlayerPlatform.instance.feed(
        this,
        data: data,
      ));
      assert(ln >= 0); // feedFromStream() is not happy if < 0
      if (ln != 0) {
        // If the device accepted some data, then no need to wait
        // It is the tau_core responsability to send a "needSomeFood" then it is again available for new data
        _needSomeFoodCompleter = null;
        return (ln);
      } else {
        //logger.i("The device has enough data");
      }

       */
    } on Exception {
      _needSomeFoodCompleter = null;
      if (isStopped) {
        return 0;
      }
      rethrow;
    }

    if (_needSomeFoodCompleter != null) {
      return _needSomeFoodCompleter!.future;
    }
    return 0;
  }

  /// Stop a playback.
  ///
  /// This verb never throw any exception. It is safe to call it everywhere,
  /// for example when the App is not sure of the current Audio State and want to recover a clean reset state.
  ///
  /// *Example:*
  /// ```dart
  ///         await myPlayer.stopPlayer();
  ///         if (_playerSubscription != null)
  ///         {
  ///                 _playerSubscription.cancel();
  ///                 _playerSubscription = null;
  ///         }
  /// ```
  Future<void> stopPlayer() async {
    await _lock.synchronized(() async {
      await _stopPlayer();
    });
  }

  Future<void> _stopPlayer() async {
    _logger.d('FS:---> _stopPlayer ');
    while (_openPlayerCompleter != null) {
      _logger.w('Waiting for the recorder being opened');
      await _openPlayerCompleter!.future;
    }
    try {
      //_removePlayerCallback(); // playerController is closed by this function
      await _stop();
    } on Exception catch (e) {
      _logger.e(e);
    }
    _logger.d('FS:<--- stopPlayer ');
  }

  Future<void> _stop() async {
    _logger.d('FS:---> _stop ');
    if (_foodStreamSubscription != null) {
      await _foodStreamSubscription!.cancel();
      _foodStreamSubscription = null;
    }
    _needSomeFoodCompleter = null;
    if (_foodStreamController != null) {
      await _foodStreamController!.sink.close();
      //await foodStreamController.stream.drain<bool>();
      await _foodStreamController!.close();
      _foodStreamController = null;
    }
    Completer<void>? completer;
    _stopPlayerCompleter = Completer<void>();
    try {
      completer = _stopPlayerCompleter;
      //var state = await FlutterSoundPlayerPlatform.instance.stopPlayer(this);

      if (_playerState != PlayerState.isStopped) {
        _logger.d('Player is not stopped!');
      }
    } on Exception {
      _stopPlayerCompleter = null;
      rethrow;
    }

    _logger.d('FS:<--- _stop ');
    return completer!.future;
  }

  /// Pause the current playback.
  ///
  /// An exception is thrown if the player is not in the "playing" state.
  ///
  /// *Example:*
  /// ```dart
  /// await myPlayer.pausePlayer();
  /// ```
  Future<void> pausePlayer() async {
    _logger.d('FS:---> pausePlayer ');
    await _lock.synchronized(() async {
      await _pausePlayer();
    });
    _logger.d('FS:<--- pausePlayer ');
  }

  Future<void> _pausePlayer() async {
    _logger.d('FS:---> _pausePlayer ');
    await _waitOpen();
    Completer<void>? completer;
    if (_pausePlayerCompleter != null) {
      _logger.w('Killing another pausePlayer()');
      _pausePlayerCompleter!.completeError('Killed by another pausePlayer()');
    }
    try {
      _pausePlayerCompleter = Completer<void>();
      completer = _pausePlayerCompleter;
      //_playerState = PlayerState
      //.values[await FlutterSoundPlayerPlatform.instance.pausePlayer(this)];
      //if (_playerState != PlayerState.isPaused) {
      //throw _PlayerRunningException(
      //'Player is not paused.'); // I am not sure that it is good to throw an exception here
      //}
    } on Exception {
      _pausePlayerCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- _pausePlayer ');
    return completer!.future;
  }

  /// Resume the current playback.
  ///
  /// An exception is thrown if the player is not in the "paused" state.
  ///
  /// *Example:*
  /// ```dart
  /// await myPlayer.resumePlayer();
  /// ```
  Future<void> resumePlayer() async {
    _logger.d('FS:---> resumePlayer');
    await _lock.synchronized(() async {
      await _resumePlayer();
    });
    _logger.d('FS:<--- resumePlayer');
  }

  Future<void> _resumePlayer() async {
    _logger.d('FS:---> _resumePlayer');
    await _waitOpen();
    Completer<void>? completer;
    if (_resumePlayerCompleter != null) {
      _logger.w('Killing another resumePlayer()');
      _resumePlayerCompleter!.completeError('Killed by another resumePlayer()');
    }
    _resumePlayerCompleter = Completer<void>();
    try {
      completer = _resumePlayerCompleter;
      //var state = await FlutterSoundPlayerPlatform.instance.resumePlayer(this);
      //if (_playerState != PlayerState.isPlaying) {
      //throw _PlayerRunningException(
      //'Player is not resumed.'); // I am not sure that it is good to throw an exception here
      //}
    } on Exception {
      _resumePlayerCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- _resumePlayer');
    return completer!.future;
  }

  /// To seek to a new location.
  ///
  /// The player must already be playing or paused. If not, an exception is thrown.
  ///
  /// *Example:*
  /// ```dart
  /// await myPlayer.seekToPlayer(Duration(milliseconds: milliSecs));
  /// ```
  Future<void> seekToPlayer(Duration duration) async {
    await _lock.synchronized(() async {
      await _seekToPlayer(duration);
    });
  }

  Future<void> _seekToPlayer(Duration duration) async {
    _logger.t('FS:---> seekToPlayer ');
    await _waitOpen();
    //var state = await FlutterSoundPlayerPlatform.instance.seekToPlayer(
    //this,
    //duration: duration,
    //);
    oldPosition = 0;
    _logger.t('FS:<--- seekToPlayer ');
  }

  /// Change the output volume
  ///
  /// The parameter is a floating point number between 0 and 1.
  /// Volume can be changed when player is running or before [startPlayer].
  ///
  /// *Example:*
  /// ```dart
  /// await myPlayer.setVolume(0.1);
  /// ```
  Future<void> setVolume(double volume) async {
    await _lock.synchronized(() async {
      await _setVolume(volume);
    });
  }

  Future<void> _setVolume(double volume) async {
    _logger.d('FS:---> setVolume ');
    await _waitOpen();
    //var indexedVolume = (!kIsWeb) && Platform.isIOS ? volume * 100 : volume;
    if (volume < 0.0 || volume > 1.0) {
      throw RangeError('Value of volume should be between 0.0 and 1.0.');
    }

    //var state = await FlutterSoundPlayerPlatform.instance.setVolume(
    //this,
    //volume: volume,
    //);
    _logger.d('FS:<--- setVolume ');
  }

  /// Change the playback speed
  ///
  /// The parameter is a floating point number between 0 and 1.0 to slow the speed,
  /// or 1.0 to n to accelerate the speed.
  ///
  /// Speed can be changed when player is running, or before [startPlayer].
  ///
  /// *Example:*
  /// ```dart
  /// await myPlayer.setSpeed(0.8);
  /// ```
  Future<void> setSpeed(double speed) async {
    await _lock.synchronized(() async {
      await _setSpeed(speed);
    });
  }

  Future<void> _setSpeed(double speed) async {
    _logger.d('FS:---> _setSpeed ');
    await _waitOpen();
    if (speed < 0.0) {
      throw RangeError('Value of speed should be between 0.0 and n.');
    }

    //var state = await FlutterSoundPlayerPlatform.instance.setSpeed(
    //this,
    //speed: speed,
    //);
    _logger.d('FS:<--- _setSpeed ');
  }

  /// Get the resource path.
  ///
  /// This verb should probably not be here...
  Future<String?> getResourcePath() async {
    await _waitOpen();
    if (kIsWeb) {
      return null;
    } else if (Platform.isIOS) {
      //var s = await FlutterSoundPlayerPlatform.instance.getResourcePath(this);
      //return s;
    } else {
      //return (await getApplicationDocumentsDirectory()).path;
    }
    return '';
  }
}

/// Used to stream data about the position of the
/// playback as playback proceeds.
class PlaybackDisposition {
  /// The duration of the media.
  final Duration duration;

  /// The current position within the media
  /// that we are playing.
  final Duration position;

  /// A convenience ctor. If you are using a stream builder
  /// you can use this to set initialData with both duration
  /// and postion as 0.
  PlaybackDisposition.zero()
      : position = const Duration(seconds: 0),
        duration = const Duration(seconds: 0);

  /// The constructor
  PlaybackDisposition({
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  ///
  @override
  String toString() {
    return 'duration: $duration, '
        'position: $position';
  }
}
