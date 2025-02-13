/*
 * Copyright 2018, 2019, 2020, 2021 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the Mozilla Public License version 2 (MPL2.0),
 * as published by the Mozilla organization.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MPL General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter/material.dart';
import 'package:taudio/taudio.dart';
//import 'package:web/web.dart';
//import 'package:flutter/widgets.dart';

/*
 *
 * This is a very simple example for Flutter Sound beginners,
 * that show how to record, and then playback a file.
 *
 * This example is really basic.
 *
 */

const _exampleAudioFilePathMP3 = 'https://tau.canardoux.xyz/danku/extract/05.mp3';

///
typedef Fn = void Function();

/// Example app.
class TDSimplePlayback extends StatefulWidget {
  const TDSimplePlayback({super.key});

  @override
  State<TDSimplePlayback> createState() => _TDSimplePlayback();
}

class _TDSimplePlayback extends State<TDSimplePlayback> {
  final Taudio _player = Taudio();
  bool _playerIsInited = false;

  @override
  void initState() {
    super.initState();
    initTaudio();
  }

  @override
  void dispose() {
    // Be careful : you must `close` the audio session when you have finished with it.
    _player.close().then((value) {
      setState(() {
        _playerIsInited = false;
      });
    });
    super.dispose();
  }

  // -------  Here is the code to playback a remote file -----------------------

  Future<void> initTaudio() async {
    TaudioSource source = _player.fromUri(codec: AAC_MP4(), path: _exampleAudioFilePathMP3);
    TaudioDestination destination = _player.speaker();
    await _player.open(from: source, to: destination);
    setState(() {
      _playerIsInited = true;
    });
  }

  Future<void> start() async {
    _player.rewind().then((value) => _player.start()).then((value) {
      setState(() {});
    });
  }

  void stop() {
    _player.stop();
  }

  // --------------------- UI -------------------

  Fn? getPlaybackFn() => (_playerIsInited) ? start : null;

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              ElevatedButton(
                onPressed: getPlaybackFn(),
                //color: Colors.white,
                //disabledColor: Colors.grey,
                child: Text(_player.isPlaying() ? 'Stop' : 'Play'),
              ),
              const SizedBox(
                width: 20,
              ),
              Text(_player.isPlaying()
                  ? 'Playback in progress'
                  : 'Player is stopped'),
            ]),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Simple Playback'),
      ),
      body: makeBody(),
    );
  }
}
