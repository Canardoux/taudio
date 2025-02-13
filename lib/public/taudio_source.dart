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

//import 'dart:js_interop';
import 'package:taudio/src/taudio_nat.dart';

import '../../taudio.dart';
import 'dart:typed_data' show Uint8List, Float32List;
import 'package:flutter/services.dart' show rootBundle;

//import '../../src/dummy.dart'
//    if (dart.library.html) 'package:web/web.dart'
//    if (dart.library.io) '../../src/temp.dart';
import '../../taudio.dart';
import 'package:http/http.dart' as http;
//import 'package:fetch_client/fetch_client.dart' as http;
import '../../src/dummy.dart'
    if (dart.library.html) '../../src/taudio_web.dart'
    if (dart.library.io) '../../src/taudio_nat.dart';
//import 'package:web/web.dart' hide Float32List;

abstract class TaudioSource extends TaudioNode {
  /* ctor */ TaudioSource({
    required super.context,
  });
  /* abstract */ Future<void> open();
}

class FromCodeString extends taudioBufferSource {
  //late int sampleRate;
  late TaudioCodec codec; // Unused
  late Uint8List buffer;

  /* ctor */ FromCodeString(
      {required super.context, required this.codec, required this.buffer});
  // Codec is unused

  Future<void> open() async {
    super.setBuf(buffer: buffer, codec: codec);
  }
}

class FromBuffer extends taudioBufferSource {
  late TaudioCodec codec; // Unused

//late Uint8List buffer;
/* ctor */ FromBuffer(
      {required super.context, required TaudioBuffer taudioBuffer});

  Future<void> open() async {
    AudioBufferSourceNode n = context.createBufferSource();
    n.buffer = taudioBuffer!.audioBuffer;
    node = n;
  }
}

class FromPCM32 extends taudioBufferSource {
  late int sampleRate;
  late List<Float32List> data;
  /* ctor */ FromPCM32(
      {required super.context, required this.sampleRate, required this.data});

  Future<void> open() async {
    taudioBuffer = TaudioBuffer.fromPCM32(
        context: context, sampleRate: sampleRate, data: data);
  }
}

class FromAsset extends taudioBufferSource {
  late String path;
  late TaudioCodec codec;

  /* ctor */ FromAsset({
    required super.context,
    required this.codec, // Codec is unused
    required String this.path,
  });

  Future<void> open() async {
    var asset = await rootBundle.load(path);
    var buf = asset.buffer.asUint8List();
    super.setBuf(codec: codec, buffer: buf);
  }
}

class FromUri extends taudioBufferSource {
  late String path;
  late TaudioCodec codec;

  /* ctor */ FromUri(
      {required super.context,
      required String this.path,
      required this.codec // Codec is unused
      });

  Future<void> open() async {
    Uint8List buf1 = await http.readBytes(Uri.parse(path));
    var response = await http.get(Uri.parse(path));
    Uint8List buf = response.bodyBytes;
    super.setBuf(buffer: buf, codec: codec);
  }
}
