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

//import 'package:web/web.dart';

import '../../src/dummy.dart'
    if (dart.library.html) 'package:web/web.dart'
    if (dart.library.io) '../../src/temp.dart';
import 'package:web/web.dart';

abstract class TaudioDestination {
  AudioNode get node;
  late AudioContext context;
  /* ctor */ TaudioDestination({required this.context});
  Future<void> open() => Future.value();
}

enum TaudioDeviceType {
  defaultDevice,
  speaker,
  earPhone,
  blueToothHeadPhone,
}

class OutputDevice extends TaudioDestination {
  TaudioDeviceType type = TaudioDeviceType.defaultDevice;
  /* ctor */ OutputDevice(
      {required super.context, this.type = TaudioDeviceType.defaultDevice});
  factory OutputDevice.speaker(AudioContext context) =>
      OutputDevice(context: context, type: TaudioDeviceType.speaker);
  @override
  AudioNode get node => context.destination;
}
