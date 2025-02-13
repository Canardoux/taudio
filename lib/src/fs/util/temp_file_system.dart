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

/// -------
///
/// A very basic module to access temporary files.
///
/// ----------
///
/// {@category Utilities}
library temp_file_system;

import 'dart:async';
import 'dart:io';

import 'package:uuid/uuid.dart';

///
enum TempFileLocations {
  ///
  recordings
}

///
class TempFiles {
  static TempFiles? _self;
  static const _rootDir = 'square_phone';

  ///
  factory TempFiles() {
    _self ??= TempFiles._internal();
    return _self!;
  }

  TempFiles._internal() {
    // _mfs = MemoryFileSystem(style: FileSystemStyle.posix);
  }

  ///
  /// Creates a temporary file in the systems temp directory.
  /// @param subdirectory - the directory (under the temp file system)
  /// to place the file in.
  /// @param prefix - an optional prefix to prepend to the randomly
  ///  generated filename.
  ///
  /// Example:
  ///    File tmpRecording = await TempFiles()
  ///        .create(TempFileLocations.RECORDINGS);
  ///
  Future<File> create(TempFileLocations location, [String prefix = '']) async {
    var derivedPath = '${Directory.systemTemp.path}'
        '/'
        '$_rootDir'
        '/'
        '${location.toString().split('.').last}';

    var directory = await Directory(derivedPath).create(recursive: true);

    // make certain we have a random filename that doesn't already exist.
    String path;
    do {
      var fileName = prefix + generateRandomFileName();
      path = '${directory.path}/$fileName}';
    } while (File(path).existsSync());

    var tmpFile = File(path);
    await tmpFile.create();

    return tmpFile;
  }

  ///
  String generateRandomFileName() {
    return const Uuid().toString();
  }
}
