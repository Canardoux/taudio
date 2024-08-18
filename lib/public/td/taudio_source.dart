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

import 'dart:typed_data' show Uint8List;

//import '../../src/dummy.dart'
//    if (dart.library.html) 'package:web/web.dart'
//    if (dart.library.io) '../../src/temp.dart';
import '../../taudio.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart';

abstract class TaudioSource {
  late AudioContext context;
  AudioNode get node;
  /* ctor */ TaudioSource({required this.context});
  Future<void> open();
}

class FromBuffer extends TaudioSource {
  Future<void> open() async {
    //AudioBuffer audioBuffer = await context.decodeAudioData(buf);
    var n = context.createBufferSource();
    _node = n;
    //n.buffer = audioBuffer;
  }

  Uint8List? buf;
  late AudioNode _node;
  /* ctor */ FromBuffer({required super.context, this.buf}) {
    //audioBuffer.dispose();
  }
  AudioNode get node => _node;
}

class FromAsset {
  Future<void> open() => Future.value();
  late AudioNode _node;
  /* ctor */ FromAsset();
  AudioNode get node => _node;
}

class FromUrl extends FromBuffer {
  String path = '';
  TaudioCodec codec;
  //late AudioNode _node;
  /* ctor */ FromUrl(
      {required super.context,
      required String this.path,
      required TaudioCodec this.codec});

  Future<Uint8List?> fetch() async {
    var f = await http.get(Uri.parse(path));
    buf = f.bodyBytes;
    return buf;
  }

  Future<void> open() async {
    buf = await fetch();
    return super.open();
  }
}
